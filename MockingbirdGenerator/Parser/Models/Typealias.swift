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
  let typeName: String // Possible that this references another typealias.
  let rawType: RawType
  
  init?(from rawType: RawType) {
    guard let kind = SwiftDeclarationKind(from: rawType.dictionary), kind == .typealias,
      let name = rawType.dictionary[SwiftDocKey.name.rawValue] as? String
      else { return nil }
    self.name = name
    self.rawType = rawType
    
    let source = rawType.parsedFile.data
    guard let typeName = SourceSubstring.nameSuffix.extract(from: rawType.dictionary,
                                                            contents: source),
      let declarationIndex = typeName.firstIndex(of: "=") else { return nil }
    let declaration = typeName[typeName.index(after: declarationIndex)...]
    self.typeName = declaration.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

class TypealiasRepository {
  /// Fully qualified (module) typealias name => `Typealias`
  private(set) var typealiases = [String: Typealias]()
  /// Fully qualified (module) typealias name => actual fully qualified (module) type name
  private var unwrappedTypealiases = Synchronized<[String: String]>([:])
  
  /// Start tracking a typealias.
  func addTypealias(_ typeAlias: Typealias) {
    typealiases[typeAlias.rawType.fullyQualifiedModuleName] = typeAlias
  }
  
  /// Returns the actual fully qualified type name for a given fully qualified (module) type name.
  func actualTypeName(for typeName: String,
                      rawTypeRepository: RawTypeRepository,
                      moduleNames: [String],
                      referencingModuleName: String,
                      containingTypeNames: ArraySlice<String>) -> String {
    guard let typeAlias = typealiases[typeName] else { return typeName }
    return actualTypeName(for: typeAlias,
                          rawTypeRepository: rawTypeRepository,
                          moduleNames: moduleNames,
                          referencingModuleName: referencingModuleName,
                          containingTypeNames: containingTypeNames) ?? typeName
  }
  
  /// Returns the actual type name for a given `Typealias`, if one exists.
  func actualTypeName(for typeAlias: Typealias,
                      rawTypeRepository: RawTypeRepository,
                      moduleNames: [String],
                      referencingModuleName: String,
                      containingTypeNames: ArraySlice<String>) -> String? {
    let unwrappedTypealiases = self.unwrappedTypealiases.value
    
    // This typealias is already resolved.
    if let actualTypeName = unwrappedTypealiases[typeAlias.rawType.fullyQualifiedModuleName] {
      return actualTypeName
    }
    
    // Get the fully qualified name of the referenced type.
    guard let aliasedRawTypeName = rawTypeRepository
      .nearestInheritedType(named: typeAlias.typeName,
                            moduleNames: moduleNames,
                            referencingModuleName: referencingModuleName,
                            containingTypeNames: containingTypeNames)?
      .findBaseRawType()?.fullyQualifiedModuleName else {
        self.unwrappedTypealiases.update {
          $0[typeAlias.rawType.fullyQualifiedModuleName] = typeAlias.typeName
        }
        return typeAlias.typeName
    }
    
    // Check if the typealias references another typealias.
    guard let aliasedTypealias = typealiases[aliasedRawTypeName] else { return aliasedRawTypeName }
    let typeName = actualTypeName(for: aliasedTypealias,
                                  rawTypeRepository: rawTypeRepository,
                                  moduleNames: moduleNames,
                                  referencingModuleName: aliasedTypealias.rawType.parsedFile.moduleName,
                                  containingTypeNames: aliasedTypealias.rawType.containingTypeNames[...])
    self.unwrappedTypealiases.update {
      $0[typeAlias.rawType.fullyQualifiedModuleName] = typeName
    }
    return typeName
  }
}
