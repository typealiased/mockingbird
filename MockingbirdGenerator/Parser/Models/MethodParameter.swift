//
//  MethodParameter.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import SourceKittenFramework

struct MethodParameter {
  let name: String
  let argumentLabel: String?
  let typeName: String
  let kind: SwiftDeclarationKind
  let attributes: Attributes
  let hasSelfConstraints: Bool
  
  private let rawType: RawType
  
  init?(from dictionary: StructureDictionary,
        argumentLabel: String?,
        parameterIndex: Int,
        rawDeclaration: String?,
        rawType: RawType,
        moduleNames: [String],
        rawTypeRepository: RawTypeRepository,
        typealiasRepository: TypealiasRepository) {
    guard let kind = SwiftDeclarationKind(from: dictionary), kind == .varParameter,
      let rawTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String
      else { return nil }
    // It's possible for protocols to define parameters with only the argument label and no name.
    self.name = dictionary[SwiftDocKey.name.rawValue] as? String ?? "param\(parameterIndex+1)"
    self.kind = kind
    self.argumentLabel = argumentLabel
    
    let declaredParameter = rawDeclaration ?? rawTypeName
    let parameter = Function.Parameter(from: declaredParameter)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository,
               typealiasRepository: typealiasRepository)
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: serializationContext,
                                                        options: .standard)
    let actualTypeNameRequest = SerializationRequest(method: .actualTypeName,
                                                     context: serializationContext,
                                                     options: .standard)
    let typeName = parameter.serialize(with: qualifiedTypeNameRequest)
    let actualParameterName = parameter.serialize(with: actualTypeNameRequest)
    let actualParameter = Function.Parameter(from: actualParameterName)
    
    // Final attributes can differ from those in `parameter` due to knowing the typealiased type.
    var attributes = Attributes(from: dictionary).union(actualParameter.attributes)
    if actualParameter.type.isFunction && !actualParameter.type.isOptional {
      attributes.insert(.closure)
    }
    self.typeName = typeName
    self.attributes = attributes
    self.hasSelfConstraints = typeName.contains(SerializationRequest.Constants.selfTokenIndicator)
    self.rawType = rawType
  }
}

extension MethodParameter: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(argumentLabel)
    hasher.combine(typeName)
    hasher.combine(kind.typeScope == .instance)
    hasher.combine(attributes)
  }
  
  static func == (lhs: MethodParameter, rhs: MethodParameter) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

extension MethodParameter: Comparable {
  static func < (lhs: MethodParameter, rhs: MethodParameter) -> Bool {
    return (
      lhs.typeName,
      lhs.name,
      lhs.argumentLabel ?? ""
    ) < (
      rhs.typeName,
      rhs.name,
      rhs.argumentLabel ?? ""
    )
  }
}

extension MethodParameter: Specializable {
  private init(from parameter: MethodParameter, typeName: String) {
    self.name = parameter.name
    self.argumentLabel = parameter.argumentLabel
    self.typeName = typeName
    self.kind = parameter.kind
    self.attributes = parameter.attributes
    self.hasSelfConstraints = parameter.hasSelfConstraints
    self.rawType = parameter.rawType
  }
  
  func specialize(using context: SpecializationContext,
                  moduleNames: [String],
                  genericTypeContext: [[String]],
                  excludedGenericTypeNames: Set<String>,
                  rawTypeRepository: RawTypeRepository,
                  typealiasRepository: TypealiasRepository) -> MethodParameter {
    guard !context.specializations.isEmpty else { return self }
    
    let declaredType = DeclaredType(from: typeName)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository,
               typealiasRepository: typealiasRepository)
    let attributedSerializationContext = SerializationRequest
      .Context(from: serializationContext,
               genericTypeContext: genericTypeContext + serializationContext.genericTypeContext,
               excludedGenericTypeNames: excludedGenericTypeNames,
               specializationContext: context)
    let options: SerializationRequest.Options = [.standard, .shouldSpecializeTypes]
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: attributedSerializationContext,
                                                        options: options)
    let specializedTypeName = declaredType.serialize(with: qualifiedTypeNameRequest)
    
    return MethodParameter(from: self, typeName: specializedTypeName)
  }
}
