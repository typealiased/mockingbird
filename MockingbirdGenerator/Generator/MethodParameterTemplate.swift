//
//  MethodParameterTemplate.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/14/19.
//

import Foundation

struct MethodParameterTemplate {
  let methodParameter: MethodParameter
  let context: MethodTemplate
  init(methodParameter: MethodParameter, context: MethodTemplate) {
    self.methodParameter = methodParameter
    self.context = context
  }
  
  func mockableTypeName(forClosure: Bool) -> String {
    let rawTypeName = context.context.specializeTypeName(methodParameter.typeName)
    
    // When the type names are used for invocations instead of declaring the method parameters.
    guard forClosure else {
      return "\(rawTypeName)"
    }
    
    let typeName = rawTypeName.removingImplicitlyUnwrappedOptionals()
    if methodParameter.attributes.contains(.variadic) {
      return "[\(typeName.dropLast(3))]"
    } else {
      return "\(typeName)"
    }
  }
  
  var invocationName: String {
    let inoutAttribute = methodParameter.attributes.contains(.inout) ? "&" : ""
    let autoclosureForwarding = methodParameter.attributes.contains(.autoclosure) ? "()" : ""
    return "\(inoutAttribute)`\(methodParameter.name)`\(autoclosureForwarding)"
  }
  
  var matchableTypeName: String {
    let typeName = context.context.specializeTypeName(methodParameter.typeName)
      .removingParameterAttributes()
    if methodParameter.attributes.contains(.variadic) {
      return "[" + typeName + "]"
    } else {
      return typeName
    }
  }
}
