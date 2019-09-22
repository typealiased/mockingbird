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
  
  init(structureDictionary: StructureDictionary, parsedFile: ParsedFile) {
    self.structureDictionary = structureDictionary
    self.parsedFile = parsedFile
  }
  
  override func run() throws {
    result.rawTypes.append(contentsOf: processStructureDictionary(structureDictionary,
                                                                  parsedFile: parsedFile,
                                                                  containingTypeNames: [],
                                                                  definedInExtension: false))
    log("Created \(result.rawTypes.count) raw type\(result.rawTypes.count != 1 ? "s" : "") from source file at \(parsedFile.path.absolute())")
  }
  
  /// Create a `RawType` object from a parsed file's `StructureDictionary`.
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          parsedFile: ParsedFile,
                                          containingTypeNames: [String],
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
    if let name = typeName {
      attributedContainingTypeNames = containingTypeNames + [name + allGenericTypes]
    } else {
      attributedContainingTypeNames = containingTypeNames
    }
    
    let optionalKind = SwiftDeclarationKind(from: dictionary)
    let containedTypesInExtension = definedInExtension || optionalKind == .extension
    let containedTypes = substructure.flatMap({
      processStructureDictionary($0,
                                 parsedFile: parsedFile,
                                 containingTypeNames: attributedContainingTypeNames,
                                 definedInExtension: containedTypesInExtension)
    })
    guard let name = typeName else { return containedTypes } // Base case where this isn't a type.
    
    // For inheritance, contained types are stored in the root namespace as fully qualified types.
    containedTypes.forEach({ result.rawTypes.append($0) })
    
    guard let kind = optionalKind, kind.isParsable,
      let accessLevel = AccessLevel(from: dictionary), accessLevel.isMockable else { return [] }
    let fullyQualifiedName = attributedContainingTypeNames.joined(separator: ".")
    let selfConformanceTypes = kind == .protocol ? parseSelfConformanceTypes(from: dictionary) : []
    return [RawType(dictionary: dictionary,
                    name: name,
                    fullyQualifiedName: fullyQualifiedName,
                    containedTypes: containedTypes,
                    containingTypeNames: containingTypeNames,
                    selfConformanceTypes: selfConformanceTypes,
                    definedInExtension: definedInExtension,
                    kind: kind,
                    parsedFile: parsedFile)]
  }
  
  func parseSelfConformanceTypes(from dictionary: StructureDictionary) -> Set<String> {
    guard let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: dictionary,
                                                                      contents: parsedFile.data),
      let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression)
      else { return [] }
    
    return Set(nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
      .components(separatedBy: ",", excluding: .allGroups)
      .compactMap({ WhereClause(from: String($0)) })
      .filter({ $0.operator == .conforms && $0.constrainedTypeName == "Self" })
      .map({ $0.genericConstraint }))
  }
}
