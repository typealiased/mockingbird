//
//  GenericType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct WhereClause: Hashable, Comparable, CustomStringConvertible {
  enum Requirement: String {
    case conforms = ":"
    case equals = "=="
    
    var isCommutative: Bool {
      switch self {
      case .conforms: return false
      case .equals: return true
      }
    }
  }
  
  var description: String {
    switch requirement {
    case .conforms: return "\(constrainedTypeName)\(requirement.rawValue) \(genericConstraint)"
    case .equals: return "\(constrainedTypeName) \(requirement.rawValue) \(genericConstraint)"
    }
  }
  
  static func < (lhs: WhereClause, rhs: WhereClause) -> Bool {
    return "\(lhs)" < "\(rhs)"
  }
  
  let constrainedTypeName: String
  let genericConstraint: String
  let requirement: Requirement
  let hasSelfConstraint: Bool
  
  init?(from declaration: String) {
    self.hasSelfConstraint = false // Hydrated when qualified.
    
    let lhs: String
    let rhs: String
    if let conformsIndex = declaration.firstIndex(of: Requirement.conforms.rawValue.first!) {
      self.requirement = .conforms
      lhs = declaration[..<conformsIndex]
        .trimmingCharacters(in: .whitespacesAndNewlines)
      rhs = declaration[declaration.index(after: conformsIndex)...]
        .trimmingCharacters(in: .whitespacesAndNewlines)
    } else if let equalsRange = declaration.range(of: Requirement.equals.rawValue) {
      self.requirement = .equals
      lhs = declaration[..<equalsRange.lowerBound]
        .trimmingCharacters(in: .whitespacesAndNewlines)
      rhs = declaration[equalsRange.upperBound...]
        .trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      return nil
    }
    
    // Commutative requirements require special consieration for hashing and equality.
    var components = [lhs, rhs]
    if self.requirement.isCommutative { components.sort() }
    self.constrainedTypeName = components[0]
    self.genericConstraint = components[1]
  }
  
  init(constrainedTypeName: String, genericConstraint: String, requirement: Requirement) {
    self.constrainedTypeName = constrainedTypeName
    self.genericConstraint = genericConstraint
    self.requirement = requirement
    self.hasSelfConstraint =
      constrainedTypeName.contains(SerializationRequest.Constants.selfTokenIndicator)
      || genericConstraint.contains(SerializationRequest.Constants.selfTokenIndicator)
  }
}

struct GenericType: Hashable {
  let name: String
  let constraints: Set<String> // A set of type names
  let whereClauses: [WhereClause]
  let hasSelfConstraint: Bool
  
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
    
    let whereClauses: [WhereClause]
    if kind == .associatedtype {
      whereClauses = GenericType.parseAssociatedTypes(constraints: &constraints,
                                                      rawType: rawType,
                                                      dictionary: dictionary,
                                                      moduleNames: moduleNames,
                                                      rawTypeRepository: rawTypeRepository)
      self.hasSelfConstraint = whereClauses.contains(where: { $0.hasSelfConstraint })
    } else {
      whereClauses = []
      self.hasSelfConstraint = false
    }
    self.whereClauses = whereClauses
    self.constraints = constraints
  }
  
  /// Qualify any generic type constraints, which SourceKit gives us as inherited types.
  private static func parseInheritedTypes(rawInheritedTypes: [StructureDictionary],
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
      let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                          context: serializationContext,
                                                          options: .standard)
      constraints.insert(declaredType.serialize(with: qualifiedTypeNameRequest))
    }
    return constraints
  }
  
  /// Manually parse any constraints defined by associated types in protocols.
  private static func parseAssociatedTypes(constraints: inout Set<String>,
                                           rawType: RawType,
                                           dictionary: StructureDictionary,
                                           moduleNames: [String],
                                           rawTypeRepository: RawTypeRepository) -> [WhereClause] {
    var whereClauses = [WhereClause]()
    let source = rawType.parsedFile.data
    guard let declaration = SourceSubstring.key.extract(from: dictionary, contents: source),
      let inferredTypeLowerBound = declaration.firstIndex(of: ":")
      else { return whereClauses }
    
    let inferredTypeStartIndex = declaration.index(after: inferredTypeLowerBound)
    let typeDeclaration = declaration[inferredTypeStartIndex...]
    
    // Associated types can also have generic type constraints using a generic `where` clause.
    let allInferredTypes: String
    if let whereRange = typeDeclaration.range(of: #"\bwhere\b"#, options: .regularExpression) {
      let rawInferredType = typeDeclaration[..<whereRange.lowerBound]
      allInferredTypes = rawInferredType.trimmingCharacters(in: .whitespacesAndNewlines)
      
      whereClauses = typeDeclaration[whereRange.upperBound...]
        .components(separatedBy: ",", excluding: .allGroups)
        .compactMap({ WhereClause(from: String($0)) })
        .map({ GenericType.qualifyWhereClause($0,
                                              containingType: rawType,
                                              moduleNames: moduleNames,
                                              rawTypeRepository: rawTypeRepository) })
    } else { // No `where` generic type constraints.
      allInferredTypes = typeDeclaration.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    let inferredTypes = allInferredTypes
      .substringComponents(separatedBy: ",")
      .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    
    // Qualify all generic constraint types.
    for inferredType in inferredTypes {
      let declaredType = DeclaredType(from: inferredType)
      let serializationContext = SerializationRequest
        .Context(moduleNames: moduleNames,
                 rawType: rawType,
                 rawTypeRepository: rawTypeRepository)
      let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                          context: serializationContext,
                                                          options: .standard)
      constraints.insert(declaredType.serialize(with: qualifiedTypeNameRequest))
    }
    
    return whereClauses
  }
  
  /// Type constraints for associated types can contain `Self` references which need to be resolved.
  static func qualifyWhereClause(_ whereClause: WhereClause,
                                 containingType: RawType,
                                 moduleNames: [String],
                                 rawTypeRepository: RawTypeRepository) -> WhereClause {
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: containingType,
               rawTypeRepository: rawTypeRepository)
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: serializationContext,
                                                        options: .standard)
    
    let declaredConstrainedType = DeclaredType(from: whereClause.constrainedTypeName)
    var qualifiedConstrainedTypeName = declaredConstrainedType
      .serialize(with: qualifiedTypeNameRequest)
    
    let declaredConstraintType = DeclaredType(from: whereClause.genericConstraint)
    var qualifiedConstraintTypeName = declaredConstraintType
      .serialize(with: qualifiedTypeNameRequest)
    
    // De-qualify `Self` constraints.
    let selfPrefix = "\(SerializationRequest.Constants.selfToken)."
    if qualifiedConstrainedTypeName.hasPrefix(selfPrefix) {
      qualifiedConstrainedTypeName.removeFirst(selfPrefix.count)
    }
    
    if qualifiedConstraintTypeName.hasPrefix(selfPrefix) {
      qualifiedConstraintTypeName.removeFirst(selfPrefix.count)
    }
    
    return WhereClause(constrainedTypeName: qualifiedConstrainedTypeName,
                       genericConstraint: qualifiedConstraintTypeName,
                       requirement: whereClause.requirement)
  }
}

extension GenericType: Comparable {
  static func < (lhs: GenericType, rhs: GenericType) -> Bool {
    return (
      lhs.whereClauses,
      lhs.constraints.sorted(),
      lhs.name
    ) < (
      rhs.whereClauses,
      rhs.constraints.sorted(),
      rhs.name
    )
  }
}
