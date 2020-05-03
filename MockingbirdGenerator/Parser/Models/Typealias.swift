//
//  Typealias.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/29/19.
//

import Foundation
import SourceKittenFramework

struct Typealias {
  let name: String
  let typeNames: [String] // Possible that this references another typealias or multiple types.
  let rawType: RawType
  
  init?(from rawType: RawType) {
    guard let kind = SwiftDeclarationKind(from: rawType.dictionary), kind == .typealias,
      let name = rawType.dictionary[SwiftDocKey.name.rawValue] as? String
      else { return nil }
    self.name = name
    self.rawType = rawType
    
    guard let typeNames = Typealias.parseTypeNames(from: rawType.dictionary,
                                                   parsedFile: rawType.parsedFile)
      else { return nil }
    self.typeNames = typeNames
  }
  
  static func parseTypeNames(from dictionary: StructureDictionary,
                             parsedFile: ParsedFile) -> [String]? {
    let source = parsedFile.data
    guard let rawDeclaration = SourceSubstring.nameSuffix.extract(from: dictionary,
                                                                  contents: source),
      let declarationIndex = rawDeclaration.firstIndex(of: "=") else { return nil }
    let declaration = rawDeclaration[rawDeclaration.index(after: declarationIndex)...]
    return declaration.substringComponents(separatedBy: "&").map({
      $0.trimmingCharacters(in: .whitespacesAndNewlines)
    })
  }
}

class TypealiasRepository {
  /// Fully qualified (module) typealias name => `Typealias`
  private(set) var typealiases = [String: Typealias]()
  /// Fully qualified (module) typealias name => actual fully qualified (module) type name
  private var unwrappedTypealiases = Synchronized<[String: [String]]>([:])
  
  /// Start tracking a typealias.
  func addTypealias(_ typeAlias: Typealias) {
    typealiases[typeAlias.rawType.fullyQualifiedModuleName] = typeAlias
  }
  
  /// Returns the actual fully qualified type name for a given fully qualified (module) type name.
  func actualTypeNames(for typeName: String,
                       rawTypeRepository: RawTypeRepository,
                       moduleNames: [String],
                       referencingModuleName: String,
                       containingTypeNames: ArraySlice<String>) -> [String] {
    guard let typeAlias = typealiases[typeName] else { return [typeName] }
    return actualTypeNames(for: typeAlias,
                           rawTypeRepository: rawTypeRepository,
                           moduleNames: moduleNames,
                           referencingModuleName: referencingModuleName,
                           containingTypeNames: containingTypeNames)
  }
  
  /// Returns the actual type name for a given `Typealias`, if one exists.
  func actualTypeNames(for typeAlias: Typealias,
                       rawTypeRepository: RawTypeRepository,
                       moduleNames: [String],
                       referencingModuleName: String,
                       containingTypeNames: ArraySlice<String>) -> [String] {
    // This typealias is already resolved.
    if let actualTypeNames = unwrappedTypealiases.read({
      $0[typeAlias.rawType.fullyQualifiedModuleName]
    }) {
      return actualTypeNames
    }
    
    // Get the fully qualified name of the referenced type.
    let aliasedRawTypeNames = typeAlias.typeNames.map({ typeName -> String in
      guard let qualifiedTypeName = rawTypeRepository
        .nearestInheritedType(named: typeName,
                              moduleNames: moduleNames,
                              referencingModuleName: referencingModuleName,
                              containingTypeNames: containingTypeNames)?
        .findBaseRawType()?.fullyQualifiedModuleName
        else { return typeName }
      return qualifiedTypeName
    })
    
    // Check if the typealias references another typealias.
    let unwrappedNames = aliasedRawTypeNames.flatMap({ aliasedRawTypeName -> [String] in
      guard let aliasedTypealias = typealiases[aliasedRawTypeName] else {
        return [aliasedRawTypeName]
      }
      return actualTypeNames(for: aliasedTypealias,
                             rawTypeRepository: rawTypeRepository,
                             moduleNames: moduleNames,
                             referencingModuleName: aliasedTypealias.rawType.parsedFile.moduleName,
                             containingTypeNames: aliasedTypealias.rawType.containingTypeNames[...])
    })
    unwrappedTypealiases.update {
      $0[typeAlias.rawType.fullyQualifiedModuleName] = unwrappedNames
    }
    return unwrappedNames
  }
}
