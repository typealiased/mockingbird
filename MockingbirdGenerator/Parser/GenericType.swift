//
//  GenericType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct GenericType: Hashable {
  let name: String
  let inheritedTypes: Set<String>
  let genericConstraints: [String]
  
  struct Reduced: Hashable {
    let name: String
    init(from genericType: GenericType) {
      self.name = genericType.name
    }
  }
  
  init?(from dictionary: StructureDictionary,
        rawType: RawType,
        moduleNames: [String],
        rawTypeRepository: RawTypeRepository) {
    guard let kind = SwiftDeclarationKind(from: dictionary),
      kind == .genericTypeParam || kind == .associatedtype,
      let name = dictionary[SwiftDocKey.name.rawValue] as? String
      else { return nil }
    
    self.name = name
    
    let containingTypeNames = rawType.containingTypeNames[...] + [rawType.name]
    let containingScopes = rawType.containingScopes[...] + [rawType.name]
    
    var inheritedTypes = Set<String>()
    if let rawInheritedTypes = dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] {
      for rawInheritedType in rawInheritedTypes {
        guard let name = rawInheritedType[SwiftDocKey.name.rawValue] as? String else { continue }
        let qualifiedTypeNames = rawTypeRepository
          .nearestInheritedType(named: name,
                                moduleNames: moduleNames,
                                referencingModuleName: rawType.parsedFile.moduleName,
                                containingTypeNames: containingTypeNames)?
          .findBaseRawType()?
          .qualifiedModuleNames(from: name, context: containingScopes)
        inheritedTypes.insert(qualifiedTypeNames?.contextQualified ?? name)
      }
    }
    
    var genericConstraints = [String]()
    if kind == .associatedtype { // We need to manually parse any associated type constraint.
      let source = rawType.parsedFile.file.contents
      if let declaration = SourceSubstring.key.extract(from: dictionary, contents: source),
        let inferredTypeLowerBound = declaration.firstIndex(of: ":") {
        let inferredTypeStartIndex = declaration.index(after: inferredTypeLowerBound)
        let typeDeclaration = declaration[inferredTypeStartIndex...]
        
        let inferredType: String
        if let whereRange = typeDeclaration.range(of: #"\bwhere\b"#, options: .regularExpression) {
          let rawInferredType = typeDeclaration[..<whereRange.lowerBound]
          inferredType = String(rawInferredType.trimmingCharacters(in: .whitespacesAndNewlines))
          
          genericConstraints = typeDeclaration[whereRange.upperBound...]
            .substringComponents(separatedBy: ",")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
          genericConstraints = GenericType
            .qualifyConstraintTypes(constraints: genericConstraints,
                                    containingType: rawType,
                                    moduleNames: moduleNames,
                                    rawTypeRepository: rawTypeRepository)
        } else { // No `where` generic constraint.
          inferredType = String(typeDeclaration.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        let qualifiedTypeNames = rawTypeRepository
          .nearestInheritedType(named: inferredType,
                                moduleNames: moduleNames,
                                referencingModuleName: rawType.parsedFile.moduleName,
                                containingTypeNames: containingTypeNames)?
          .findBaseRawType()?
          .qualifiedModuleNames(from: inferredType, context: containingScopes)
        inheritedTypes.insert(qualifiedTypeNames?.contextQualified ?? inferredType)
      }
    }
    self.genericConstraints = genericConstraints
    self.inheritedTypes = inheritedTypes
  }
  
  static func qualifyConstraintTypes(constraints: [String],
                                     containingType: RawType,
                                     moduleNames: [String],
                                     rawTypeRepository: RawTypeRepository) -> [String] {
    let containingTypeNames = containingType.containingTypeNames[...] + [containingType.name]
    let containingScopes = containingType.containingScopes[...] + [containingType.name]
    
    return constraints.map({ constraint -> String in
      let components = constraint.substringComponents(separatedBy: "=")
      guard components.count == 3 else { return constraint }
      let constrainedMember = components[0].trimmingCharacters(in: .whitespaces)
      let constraintType = components[2].trimmingCharacters(in: .whitespaces)
      if constraintType == "Self" {
        return "\(constrainedMember) == \(containingType.name)Mock"
      }
      
      let qualifiedTypeNames = rawTypeRepository
        .nearestInheritedType(named: constraintType,
                              moduleNames: moduleNames,
                              referencingModuleName: containingType.parsedFile.moduleName,
                              containingTypeNames: containingTypeNames)?
        .findBaseRawType()?
        .qualifiedModuleNames(from: constraintType, context: containingScopes)
      let qualifiedTypeName = qualifiedTypeNames?.contextQualified ?? constraintType
      return "\(constrainedMember) == \(qualifiedTypeName)"
    })
  }
}
