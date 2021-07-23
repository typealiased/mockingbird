//
//  SubscriptMethodTemplate.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/18/20.
//

// swiftlint:disable leading_whitespace

import Foundation

/// Subscripts are a special case and require synthesizing getters and setters for matching.
class SubscriptMethodTemplate: MethodTemplate {
  override var mockedDeclarations: String {
    let getterInvocation = ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclarationForSubscriptGetter)"),
        ("arguments", "[\(mockArgumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: unwrappedReturnTypeName).self)"),
        ("context", getterCallingContext),
      ])
    
    let setterInvocation = ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclarationForSubscriptSetter)"),
        ("arguments", "[\(mockArgumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(Void.self)"),
        ("context", setterCallingContext),
      ])
    
    let getterDefinition = PropertyDefinitionTemplate(
      type: .getter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        mockedImplementation(invocation: getterInvocation.render()))
    let setterDefinition = PropertyDefinitionTemplate(
      type: .setter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        mockedImplementation(parameterTypes: methodParameterTypesListForSubscriptSetter,
                             invocation: setterInvocation.render(),
                             returnTypeName: "Void"))
    
    return String(lines: [
      "// MARK: Mocked \(fullNameForMocking)",
      VariableDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                 declaration: "public \(overridableModifiers)\(uniqueDeclaration)",
                                 body: String(lines: [getterDefinition.render(),
                                                      setterDefinition.render()])).render(),
    ])
  }
  
  override var synthesizedDeclarations: String {
    let getterReturnTypeName = unwrappedReturnTypeName
    let setterReturnTypeName = "Void"
    
    let getterInvocationType = "(\(methodParameterTypes)) \(returnTypeAttributesForMatching)-> \(getterReturnTypeName)"
    let setterInvocationType = "(\(methodParameterTypesForSubscriptSetter)) \(returnTypeAttributesForMatching)-> \(setterReturnTypeName)"
    
    var mockableMethods = [String]()
    
    let getterGenericTypes = ["\(Declaration.subscriptGetterDeclaration)",
                                      getterInvocationType,
                                      getterReturnTypeName]
    let setterGenericTypes = ["\(Declaration.subscriptSetterDeclaration)",
                                      setterInvocationType,
                                      setterReturnTypeName]
    
    mockableMethods.append(matchableSubscript(isGetter: true,
                                              genericTypes: getterGenericTypes))
    mockableMethods.append(matchableSubscript(isGetter: false,
                                              genericTypes: setterGenericTypes))
    
    if isVariadicMethod {
      // Allow methods with a variadic parameter to use variadics when stubbing.
      mockableMethods.append(matchableSubscript(isGetter: true,
                                                isVariadic: true,
                                                genericTypes: getterGenericTypes))
      mockableMethods.append(matchableSubscript(isGetter: false,
                                                isVariadic: true,
                                                genericTypes: setterGenericTypes))
    }
    
    return String(lines: mockableMethods, spacing: 2)
  }
  
  lazy var getterCallingContext: String = {
    // Cannot reference the super subscript getter directly.
    let parameters: [(argumentLabel: String, type: String)] =
      methodParameterTypesList.enumerated().map({
        (index, type) in
        return ("p\(index)", type.removingParameterAttributes())
      })
    let superCall = context.mockableType.kind != .class ? "nil" : ClosureTemplate(
      parameters: parameters,
      returnType: unwrappedReturnTypeName,
      body: "super[\(parameters.map({ $0.argumentLabel }).joined(separator: ", "))]"
    ).render()
    return ObjectInitializationTemplate(
      name: "Mockingbird.CallingContext",
      arguments: [("super", superCall)]
    ).render()
  }()
  
  lazy var setterCallingContext: String = {
    // Cannot reference the super subscript setter directly.
    let parameters: [(argumentLabel: String, type: String)] =
      methodParameterTypesList.enumerated().map({
        (index, type) in
        return ("p\(index)", type.removingParameterAttributes())
      })
    let superCall = context.mockableType.kind != .class ? "nil" : ClosureTemplate(
      parameters: parameters + [("newValue", unwrappedReturnTypeName)],
      body: "super[\(parameters.map({ $0.argumentLabel }).joined(separator: ", "))] = newValue"
    ).render()
    return ObjectInitializationTemplate(
      name: "Mockingbird.CallingContext",
      arguments: [("super", superCall)]
    ).render()
  }()
  
  func matchableSubscript(isGetter: Bool,
                          isVariadic: Bool = false,
                          genericTypes: [String]) -> String {
    let variant: FunctionVariant = isGetter ? .subscriptGetter : .subscriptSetter
    let name = fullName(for: .matching(useVariadics: isVariadic, variant: variant))
    let namePrefix = isGetter ? "get" : "set"
    let returnType = isGetter ? "\(parenthetical: unwrappedReturnTypeName)" : "Void"
    let selectorName = isGetter ?
      uniqueDeclarationForSubscriptGetter : uniqueDeclarationForSubscriptSetter
    
    let argumentMatchers: String
    if isVariadic {
      argumentMatchers = isGetter ?
        resolvedVariadicArgumentMatchers : resolvedVariadicArgumentMatchersForSubscriptSetter
    } else {
      argumentMatchers = isGetter ?
        resolvedArgumentMatchers : resolvedArgumentMatchersForSubscriptSetter
    }
    
    let invocation = ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: selectorName)"),
        ("arguments", "[\(argumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(returnType).self)"),
        ("context", isGetter ? getterCallingContext : setterCallingContext),
      ])
    
    let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
    return \(ObjectInitializationTemplate(
      name: "Mockingbird.Mockable",
      genericTypes: genericTypes,
              arguments: [("mock", mockObject), ("invocation", invocation.render())]))
    """
    
    let syntheizedReturnType = "Mockingbird.Mockable<\(genericTypes.joined(separator: ", "))>"
    let declaration = "public \(regularModifiers)func \(namePrefix)\(name.capitalizedFirst) -> \(syntheizedReturnType)"
    let genericConstraints = method.whereClauses.map({ context.specializeTypeName("\($0)") })
    return FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                      declaration: declaration,
                                      genericConstraints: genericConstraints,
                                      body: body).render()
  }
  
  lazy var uniqueDeclarationForSubscriptGetter: String = {
    let fullName = self.fullName(for: .mocking(variant: .subscriptGetter))
    return "get.\(fullName)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)\(genericConstraints)"
  }()
  
  lazy var uniqueDeclarationForSubscriptSetter: String = {
    let fullName = self.fullName(for: .mocking(variant: .subscriptSetter))
    return "set.\(fullName)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)\(genericConstraints)"
  }()
  
  lazy var resolvedArgumentMatchersForSubscriptSetter: String = {
    let parameters = method.parameters.map({ ($0.name, true) }) + [("newValue", true)]
    return resolvedArgumentMatchers(for: parameters)
  }()
  
  lazy var resolvedVariadicArgumentMatchersForSubscriptSetter: String = {
    let parameters = method.parameters.map({ ($0.name, !$0.attributes.contains(.variadic)) })
      + [("newValue", true)]
    return resolvedArgumentMatchers(for: parameters)
  }()
  
  lazy var mockArgumentMatchersForSubscriptSetter: String = {
    return (mockArgumentMatchersList + ["Mockingbird.ArgumentMatcher(`newValue`)"])
      .joined(separator: ", ")
  }()
  
  lazy var methodParameterTypesListForSubscriptSetter: [String] = {
    return methodParameterTypesList + [unwrappedReturnTypeName]
  }()
  
  lazy var methodParameterTypesForSubscriptSetter: String = {
    return methodParameterTypesListForSubscriptSetter.joined(separator: ", ")
  }()
}
