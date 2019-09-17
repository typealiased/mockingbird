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
                                                                  containingTypeNames: []))
    log("Created \(result.rawTypes.count) raw type\(result.rawTypes.count != 1 ? "s" : "") from source file at \(parsedFile.path.absolute())")
  }
  
  /// Create a `RawType` object from a parsed file's `StructureDictionary`.
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          parsedFile: ParsedFile,
                                          containingTypeNames: [String]) -> [RawType] {
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
    
    let containedTypes = substructure.flatMap({
      processStructureDictionary($0,
                                 parsedFile: parsedFile,
                                 containingTypeNames: attributedContainingTypeNames)
    })
    guard let name = typeName else { return containedTypes } // Base case where this isn't a type.
    
    // For inheritance, contained types are stored in the root namespace as fully qualified types.
    containedTypes.forEach({ result.rawTypes.append($0) })
    
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isParsable,
      let accessLevel = AccessLevel(from: dictionary), accessLevel.isMockable else { return [] }
    let fullyQualifiedName = attributedContainingTypeNames.joined(separator: ".")
    return [RawType(dictionary: dictionary,
                    name: name,
                    fullyQualifiedName: fullyQualifiedName,
                    containedTypes: containedTypes,
                    containingTypeNames: containingTypeNames,
                    kind: kind,
                    parsedFile: parsedFile)]
  }
}
