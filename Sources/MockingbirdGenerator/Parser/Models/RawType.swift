//
//  RawType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/29/19.
//

import Foundation
import SourceKittenFramework

/// A light wrapper around a SourceKit structure, used for the mocked module and its dependencies.
class RawType {
  let dictionary: StructureDictionary
  let name: String
  /// Fully qualified with respect to the current module (not with respect to other modules)
  let fullyQualifiedName: String
  let containedTypes: [RawType]
  let containingTypeNames: [String]
  let containingScopes: [String] // Including the module name and any containing types.
  let genericTypes: [String] // Ordered generic type parameters.
  let genericTypeContext: [[String]] // Generic type parameters in each containing type.
  let selfConformanceTypeNames: Set<String> // Self conformances defined in generic where clauses.
  let aliasedTypeNames: Set<String> // For typealias definitions only.
  let definedInExtension: Bool // Types can be defined and nested within extensions.
  let kind: SwiftDeclarationKind
  let parsedFile: ParsedFile
  
  var isContainedType: Bool { return !containingTypeNames.isEmpty }
  
  /// Fully qualified with respect to other modules.
  var fullyQualifiedModuleName: String { return parsedFile.moduleName + "." + fullyQualifiedName }
  
  /// Returns a set of qualified and optional/generic type preserving names.
  ///
  /// - Parameters:
  ///   - declaration: The actual string declaration of the `RawType`, containing full type info.
  ///   - context: The containing scope names of where the type was referenced from.
  /// - Returns: Module-qualified and context-qualified names for the type.
  func qualifiedModuleNames(from declaration: String,
                            context: ArraySlice<String>,
                            definingModuleName: String?)
    -> (moduleQualified: String, contextQualified: String) {
      let trimmedDeclaration = declaration.removingParameterAttributes()
      let rawComponents = trimmedDeclaration
        .components(separatedBy: ".", excluding: .allGroups)
        .map({ String($0) })
      let specializedName = rawComponents[(rawComponents.count-1)...]
      
      let qualifiers: [String]
      if let definingModuleName = definingModuleName {
        qualifiers = [definingModuleName] + containingTypeNames + [name]
      } else {
        qualifiers = containingTypeNames + [name]
      }
      
      // Preserve any generic type specialization from the raw declaration components.
      let merge: ([String], [String]) -> String = { (old, new) -> String in
        var components: Array<String>.SubSequence {
          if new.count > old.count {
            return (new[..<(new.count-old.count)] + old[...])
          } else {
            return old[(old.count-new.count)...]
          }
        }
        return components.joined(separator: ".")
      }
      
      // Check if the referencing declaration is in the same scope as the type declaration.
      let lcaScopeIndex = zip(qualifiers, context)
        .map({ ($0, $1) })
        .lastIndex(where: { $0 == $1 }) ?? 0
      let endIndex = qualifiers.count - 1
      
      // If the LCA is the module then include the module name, else exclude type-scoped qualifiers.
      let startIndex = min(lcaScopeIndex + (lcaScopeIndex > 0 ? 1 : 0), endIndex)
      
      let moduleComponents = (qualifiers[..<endIndex] + specializedName).map({ String($0) })
      let moduleQualified = merge(rawComponents, moduleComponents)
      
      let contextComponents =
        (qualifiers[startIndex..<endIndex] + specializedName).map({ String($0) })
      let contextQualified = merge(rawComponents, contextComponents)
      
      return (moduleQualified: moduleQualified, contextQualified: contextQualified)
  }

  
  init(dictionary: StructureDictionary,
       name: String,
       fullyQualifiedName: String,
       containedTypes: [RawType],
       containingTypeNames: [String],
       genericTypes: [String],
       genericTypeContext: [[String]],
       selfConformanceTypeNames: Set<String>,
       aliasedTypeNames: Set<String>,
       definedInExtension: Bool,
       kind: SwiftDeclarationKind,
       parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
    self.fullyQualifiedName = fullyQualifiedName
    self.containedTypes = containedTypes
    self.containingTypeNames = containingTypeNames
    self.containingScopes = [parsedFile.moduleName] + containingTypeNames
    self.genericTypes = genericTypes
    self.genericTypeContext = genericTypeContext
    self.selfConformanceTypeNames = selfConformanceTypeNames
    self.aliasedTypeNames = aliasedTypeNames
    self.definedInExtension = definedInExtension
    self.kind = kind
    self.parsedFile = parsedFile
  }
}

extension RawType: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(fullyQualifiedModuleName)
  }
  
  static func == (lhs: RawType, rhs: RawType) -> Bool {
    return lhs.fullyQualifiedModuleName == rhs.fullyQualifiedModuleName
  }
}

extension Array where Element == RawType {
  /// Given an array of partial `RawType` objects, return the root declaration (not an extension).
  func findBaseRawType() -> RawType? {
    return first(where: { $0.kind != .extension })
  }
}

/// Stores `RawType` partials indexed by type name indexed by module name. Partials are mainly to
/// support extensions which define parts of a `RawType`. `MockableType` combines all partials into
/// a final unique type definition on initialization.
class RawTypeRepository {
  private(set) var rawTypes = [String: [String: [RawType]]]() // typename => module name => rawtype
  
  /// Used to check if a module name is shadowed by a type name.
  private(set) var moduleTypes = [String: Set<String>]() // module name => set(typename)
  
  /// Get raw type partials for a fully qualified name in a particular module.
  func rawType(named name: String, in moduleName: String) -> [RawType]? {
    return rawTypes[name.removingGenericTyping()]?[moduleName]
  }
  
  /// Get raw type partials for a fully qualified name in all modules.
  func rawTypes(named name: String) -> [String: [RawType]]? {
    return rawTypes[name.removingGenericTyping()]
  }
  
  /// Add a single raw type partial.
  func addRawType(_ rawType: RawType) {
    let name = rawType.fullyQualifiedName.removingGenericTyping()
    let moduleName = rawType.parsedFile.moduleName
    log("Added raw type: \(name.singleQuoted), moduleName: \(moduleName.singleQuoted)")
    rawTypes[name, default: [:]][moduleName, default: []].append(rawType)
    moduleTypes[moduleName, default: []].insert(name)
  }
  
  enum Constants {
    static let optionalsCharacterSet = CharacterSet.createOptionalsSet()
  }
  
  /// Perform type realization based on scope and module.
  ///
  /// Contained types can shadow higher level type names, so inheritance requires some inference.
  /// Type inference starts from the deepest level and works outwards.
  ///     class SecondLevelType {}
  ///     class TopLevelType {
  ///        class SecondLevelType {
  ///          // Inherits from the contained `SecondLevelType`
  ///          class ThirdLevelType: SecondLevelType {}
  ///        }
  ///      }
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
      for moduleName in attributedModuleNames {
        guard let rawType = rawTypes[moduleName],
          rawType.contains(where: { $0.kind != .extension })
          else { continue }
        return rawType
      }
      return nil
    }
    guard !containingTypeNames.isEmpty else { // Base case.
      // Check if this is a potentially fully qualified name (from the module).
      guard let firstComponentIndex = name.firstIndex(of: ".") else { return getRawType(name) }
      if let rawType = getRawType(name) { return rawType }
      
      // Ensure that the first component is actually a module that we've indexed.
      let moduleName = String(name[..<firstComponentIndex])
      guard attributedModuleNames.contains(moduleName) else { return nil }
      let dequalifiedName = name[name.index(after: firstComponentIndex)...]
      
      guard let rawType = self.rawTypes(named: String(dequalifiedName))?[moduleName],
        rawType.contains(where: { $0.kind != .extension })
        else { return nil }
      return rawType
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
  
  /// Returns whether a module name is shadowed by a type definition in any of the given modules.
  /// - Parameter moduleName: A module name to check.
  /// - Parameter moduleNames: An optional list of modules to check for type definitions.
  func isModuleNameShadowed(moduleName: String, moduleNames: [String]? = nil) -> Bool {
    if let moduleNames = moduleNames {
      return moduleNames.contains(where: { moduleTypes[$0]?.contains(moduleName) == true })
    } else {
      return moduleTypes.contains(where: { $0.value.contains(moduleName) })
    }
  }
}
