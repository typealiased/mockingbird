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
  let constraints: Set<String> // A set of type names
  let whereClauses: [String]
  
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
    
    var constraints: Set<String>
    if let rawInheritedTypes = dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] {
      constraints = GenericType.parseInheritedTypes(rawInheritedTypes: rawInheritedTypes,
                                                    moduleNames: moduleNames,
                                                    rawType: rawType,
                                                    rawTypeRepository: rawTypeRepository)
    } else {
      constraints = []
    }
    
    let whereClauses: [String]
    if kind == .associatedtype {
      whereClauses = GenericType.parseAssociatedTypes(constraints: &constraints,
                                                      rawType: rawType,
                                                      dictionary: dictionary,
                                                      moduleNames: moduleNames,
                                                      rawTypeRepository: rawTypeRepository)
    } else {
      whereClauses = []
    }
    self.whereClauses = whereClauses
    self.constraints = constraints
  }
  
  /// Qualify any generic type constraints, which SourceKit gives us as inherited types.
  @inlinable
  static func parseInheritedTypes(rawInheritedTypes: [StructureDictionary],
                                  moduleNames: [String],
                                  rawType: RawType,
                                  rawTypeRepository: RawTypeRepository) -> Set<String> {
    var constraints = Set<String>()
    for rawInheritedType in rawInheritedTypes {
      guard let name = rawInheritedType[SwiftDocKey.name.rawValue] as? String else { continue }
      let declaredType = DeclaredType(from: name)
      let serializationContext = SerializationRequest
        .Context(moduleNames: moduleNames,
                 rawType: rawType,
                 rawTypeRepository: rawTypeRepository)
      let qualifiedTypeNameRequest = SerializationRequest(method: .contextQualified,
                                                          context: serializationContext,
                                                          options: .standard)
      constraints.insert(declaredType.serialize(with: qualifiedTypeNameRequest))
    }
    return constraints
  }
  
  /// Manually parse any constraints defined by associated types in protocols.
  @inlinable
  static func parseAssociatedTypes(constraints: inout Set<String>,
                                   rawType: RawType,
                                   dictionary: StructureDictionary,
                                   moduleNames: [String],
                                   rawTypeRepository: RawTypeRepository) -> [String] {
    var genericConstraints = [String]()
    let source = rawType.parsedFile.data
    guard let declaration = SourceSubstring.key.extract(from: dictionary, contents: source),
      let inferredTypeLowerBound = declaration.firstIndex(of: ":")
      else { return genericConstraints }
    
    let inferredTypeStartIndex = declaration.index(after: inferredTypeLowerBound)
    let typeDeclaration = declaration[inferredTypeStartIndex...]
    
    // Associated types can also have generic type constraints using a generic `where` clause.
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
    } else { // No `where` generic type constraints.
      inferredType = String(typeDeclaration.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // Qualify all generic constraint types.
    let declaredType = DeclaredType(from: inferredType)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository)
    let qualifiedTypeNameRequest = SerializationRequest(method: .contextQualified,
                                                        context: serializationContext,
                                                        options: .standard)
    constraints.insert(declaredType.serialize(with: qualifiedTypeNameRequest))
    
    return genericConstraints
  }
  
  /// Type constraints for associated types can contain `Self` references which need to be resolved.
  @inlinable
  static func qualifyConstraintTypes(constraints: [String],
                                     containingType: RawType,
                                     moduleNames: [String],
                                     rawTypeRepository: RawTypeRepository) -> [String] {
    return constraints.map({ constraint -> String in
      let components = constraint.substringComponents(separatedBy: "=")
      guard components.count == 3 else { return constraint }
      let constrainedMember = components[0].trimmingCharacters(in: .whitespaces)
      let constraintType = components[2].trimmingCharacters(in: .whitespaces)
      if constraintType == "Self" {
        return "\(constrainedMember) == \(containingType.name)Mock"
      }
      
      let declaredType = DeclaredType(from: constraintType)
      let serializationContext = SerializationRequest
        .Context(moduleNames: moduleNames,
                 rawType: containingType,
                 rawTypeRepository: rawTypeRepository)
      let qualifiedTypeNameRequest = SerializationRequest(method: .contextQualified,
                                                          context: serializationContext,
                                                          options: .standard)
      let qualifiedTypeName = declaredType.serialize(with: qualifiedTypeNameRequest)
      return "\(constrainedMember) == \(qualifiedTypeName)"
    })
  }
}
