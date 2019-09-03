//
//  RawType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/29/19.
//

import Foundation
import SourceKittenFramework

/// A light wrapper around a SourceKit structure, used for the mocked module and its dependencies.
struct RawType {
  let dictionary: StructureDictionary
  let name: String
  /// Fully qualified with respect to the current module (not with respect to other modules)
  let fullyQualifiedName: String
  let containedTypes: [RawType]
  let containingTypeNames: [String]
  let containingScopes: [String] // Including the module name and any containing types.
  let kind: SwiftDeclarationKind
  let parsedFile: ParsedFile
  
  var isContainedType: Bool { return name != fullyQualifiedName }
  
  /// Fully qualified with respect to other modules.
  var fullyQualifiedModuleName: String { return parsedFile.moduleName + "." + fullyQualifiedName }
  
  /// Returns a set of qualified and optional/generic type preserving names.
  ///
  /// - Parameters:
  ///   - declaration: The actual string declaration of the `RawType`, containing full type info.
  ///   - context: The containing scope names of where the type was referenced from.
  /// - Returns: Module-qualified and context-qualified names for the type.
  func qualifiedModuleNames(from declaration: String, context: ArraySlice<String>)
    -> (moduleQualified: String, contextQualified: String) {
      let trimmedDeclaration = declaration.removingParameterAttributes()
      let groupDelimiter = (open: "<", close: ">")
      let rawComponents = trimmedDeclaration.components(separatedBy: ".",
                                                        excludingDelimiterBetween: groupDelimiter)
      let components = rawComponents[(rawComponents.count-1)...]
      
      let qualifiers = [parsedFile.moduleName] + containingTypeNames + [name]
      
      // Check if the referencing declaration is in the same scope as the type declaration.
      let lowestCommonAncestorIndex = zip(qualifiers, context)
        .map({ ($0, $1) })
        .lastIndex(where: { $0 == $1 }) ?? context.count
      let endIndex = qualifiers.count - components.count
      // If the LCA is the module then include the module name, else exclude type-scoped qualifiers.
      let startIndex = min(lowestCommonAncestorIndex + (lowestCommonAncestorIndex > 0 ? 1 : 0),
                           endIndex)
      let moduleQualified = (qualifiers[..<endIndex] + components).joined(separator: ".")
      let contextQualified = (qualifiers[startIndex..<endIndex] + components).joined(separator: ".")
      return (moduleQualified: moduleQualified, contextQualified: contextQualified)
  }
  
  init(dictionary: StructureDictionary,
       name: String,
       fullyQualifiedName: String,
       containedTypes: [RawType],
       containingTypeNames: [String],
       kind: SwiftDeclarationKind,
       parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
    self.fullyQualifiedName = fullyQualifiedName
    self.containedTypes = containedTypes
    self.containingTypeNames = containingTypeNames
    self.containingScopes = [parsedFile.moduleName] + containingTypeNames
    self.kind = kind
    self.parsedFile = parsedFile
  }
}

extension Array where Element == RawType {
  /// Given an array of partial `RawType` objects, return the root declaration (not an extension).
  func findBaseRawType() -> RawType? {
    return first(where: { $0.kind.isMockable && $0.parsedFile.shouldMock })
      ?? first(where: { !$0.kind.isMockable })
  }
}

/// Stores `RawType` partials indexed by type name indexed by module name. Partials are mainly to
/// support extensions which define parts of a `RawType`. `MockableType` combines all partials into
/// a final unique type definition on initialization.
class RawTypeRepository {
  private(set) var rawTypes = [String: [String: [RawType]]]() // typename => module name => rawtype
  
  /// Get raw type partials for a fully qualified name in a particular module.
  @inlinable func rawType(named name: String, in moduleName: String) -> [RawType]? {
    return rawTypes[name]?[moduleName]
  }
  
  /// Get raw type partials for a fully qualified name in all modules.
  @inlinable func rawTypes(named name: String) -> [String: [RawType]]? {
    return rawTypes[name]
  }
  
  /// Add a single raw type partial.
  @inlinable func addRawType(_ rawType: RawType) {
    rawTypes[rawType.fullyQualifiedName, default: [:]][rawType.parsedFile.moduleName, default: []]
      .append(rawType)
  }
  
  enum Constants {
    static let optionalsCharacterSet = CharacterSet.createOptionalsSet()
  }
  
  /// Contained types can shadow higher level type names, so inheritance requires some inference.
  /// Type inference starts from the deepest level and works outwards.
  /*
   class SecondLevelType {}
   class TopLevelType {
     class SecondLevelType {
       class ThirdLevelType: SecondLevelType {} // Inherits from the contained `SecondLevelType`
     }
   }
   */
  func nearestInheritedType(named rawName: String,
                            trimmedName: String? = nil,
                            moduleNames: [String],
                            referencingModuleName: String?, // The module referencing the type.
                            containingTypeNames: ArraySlice<String>) -> [RawType]? {
    let name: String
    if let trimmedName = trimmedName {
      name = trimmedName
    } else {
      name = rawName
        .trimmingCharacters(in: Constants.optionalsCharacterSet)
        .removingParameterAttributes()
        .removingGenericTyping()
    }

    let attributedModuleNames: [String]
    if let referencingModuleName = referencingModuleName {
      attributedModuleNames = [referencingModuleName] + moduleNames
    } else {
      attributedModuleNames = moduleNames
    }
    let getRawType: (String) -> [RawType]? = {
      guard let rawTypes = self.rawTypes(named: $0) else { return nil }
      for moduleName in moduleNames {
        guard let rawType = rawTypes[moduleName] else { continue }
        return rawType
      }
      return nil
    }
    guard !containingTypeNames.isEmpty else { // Base case.
      // Check if this is a potentially fully qualified name (from the module).
      guard let firstComponentIndex = name.firstIndex(of: ".") else { return getRawType(name) }
      if let rawType = getRawType(name) { return rawType }
      // Ensure that the first component is actually a module that we've indexed.
      guard moduleNames.contains(String(name[..<firstComponentIndex])) else { return nil }
      let dequalifiedName = name[name.index(after: firstComponentIndex)...]
      return getRawType(String(dequalifiedName))
    }
    
    let fullyQualifiedName = (containingTypeNames + [name]).joined(separator: ".")
    if let rawType = getRawType(fullyQualifiedName) { return rawType }
    
    let typeNames = containingTypeNames[0..<(containingTypeNames.count-1)]
    return nearestInheritedType(named: name,
                                trimmedName: name,
                                moduleNames: attributedModuleNames,
                                referencingModuleName: nil,
                                containingTypeNames: typeNames)
  }
}
