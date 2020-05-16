//
//  ProcessStructuresOperation.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import SourceKittenFramework

/// Creates minimal `RawType` partial objects from `ParsedFile` SourceKitten structures. Partials
/// can be classes, protocols, extensions, typealiases, etc, which are then combined later in a
/// `FlattenInheritanceOperation` to create a hydrated `MockableType`.
class ProcessStructuresOperation: BasicOperation {
  let structureDictionary: StructureDictionary
  let parsedFile: ParsedFile
  
  class Result {
    fileprivate(set) var rawTypes = [RawType]()
  }
  
  let result = Result()
  
  override var description: String { "Process Structures" }
  
  init(structureDictionary: StructureDictionary, parsedFile: ParsedFile) {
    self.structureDictionary = structureDictionary
    self.parsedFile = parsedFile
  }
  
  override func run() throws {
    result.rawTypes.append(contentsOf: processStructureDictionary(structureDictionary,
                                                                  parsedFile: parsedFile,
                                                                  containingTypeNames: [],
                                                                  genericTypeContext: [],
                                                                  definedInExtension: false))
    log("Created \(result.rawTypes.count) raw type\(result.rawTypes.count != 1 ? "s" : "") from source file at \(parsedFile.path.absolute())")
  }
  
  /// Create a `RawType` object from a parsed file's `StructureDictionary`.
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          parsedFile: ParsedFile,
                                          containingTypeNames: [String],
                                          genericTypeContext: [[String]],
                                          definedInExtension: Bool) -> [RawType] {
    let typeName = dictionary[SwiftDocKey.name.rawValue] as? String
    
    let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] ?? []
    let genericTypes = substructure.compactMap({ dictionary -> String? in
      guard let kind = SwiftDeclarationKind(from: dictionary), kind == .genericTypeParam
        else { return nil }
      return dictionary[SwiftDocKey.name.rawValue] as? String
    })
    let allGenericTypes = genericTypes.isEmpty ? "" : "<\(genericTypes.joined(separator: ", "))>"
    
    let attributedContainingTypeNames: [String] // Containing types plus the current type.
    let attributedGenericTypeContext: [[String]] // Generic context plus the current generic types.
    if let name = typeName { // Handle the top level of the structure dictionary.
      attributedContainingTypeNames = containingTypeNames + [name + allGenericTypes]
      attributedGenericTypeContext = genericTypeContext + [genericTypes]
    } else {
      attributedContainingTypeNames = containingTypeNames
      attributedGenericTypeContext = genericTypeContext
    }
    
    let optionalKind = SwiftDeclarationKind(from: dictionary)
    let containedTypesInExtension = definedInExtension || optionalKind == .extension
    let containedTypes = substructure.flatMap({
      processStructureDictionary($0,
                                 parsedFile: parsedFile,
                                 containingTypeNames: attributedContainingTypeNames,
                                 genericTypeContext: attributedGenericTypeContext,
                                 definedInExtension: containedTypesInExtension)
    })
    guard let name = typeName else { return containedTypes } // Base case where this isn't a type.
    
    // For inheritance, contained types are stored in the root namespace as fully qualified types.
    containedTypes.forEach({ result.rawTypes.append($0) })
    
    guard let kind = optionalKind, kind.isParsable else { return [] }
    
    let accessLevel = AccessLevel(from: dictionary) ?? .defaultLevel
    guard accessLevel.isMockable else { return [] }
    
    let fullyQualifiedName = attributedContainingTypeNames.joined(separator: ".")
    let selfConformanceTypeNames = kind == .protocol
      ? parseSelfConformanceTypeNames(from: dictionary) : []
    let aliasedTypeNames = kind == .typealias
      ? parseAliasedTypeNames(from: dictionary): []
    
    return [RawType(dictionary: dictionary,
                    name: name,
                    fullyQualifiedName: fullyQualifiedName,
                    containedTypes: containedTypes,
                    containingTypeNames: containingTypeNames,
                    genericTypes: genericTypes,
                    genericTypeContext: genericTypeContext,
                    selfConformanceTypeNames: selfConformanceTypeNames,
                    aliasedTypeNames: aliasedTypeNames,
                    definedInExtension: definedInExtension,
                    kind: kind,
                    parsedFile: parsedFile)]
  }
  
  private func parseSelfConformanceTypeNames(from dictionary: StructureDictionary) -> Set<String> {
    guard let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: dictionary,
                                                                      contents: parsedFile.data),
      let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression)
      else { return [] }
    
    return Set(nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
      .components(separatedBy: ",", excluding: .allGroups)
      .compactMap({ WhereClause(from: String($0)) })
      .filter({ $0.requirement == .conforms && $0.constrainedTypeName == "Self" })
      .map({ $0.genericConstraint }))
  }
  
  private func parseAliasedTypeNames(from dictionary: StructureDictionary) -> Set<String> {
    guard let typeNames = Typealias.parseTypeNames(from: dictionary, parsedFile: parsedFile) else {
      return []
    }
    return Set(typeNames)
  }
}
