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
        ("setterSelectorName", "\(doubleQuoted: uniqueDeclarationForSubscriptSetter)"),
        ("selectorType", "Mockingbird.SelectorType.subscriptGetter"),
        ("arguments", "[\(separated: mockArgumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: matchableReturnType).self)"),
      ])
    
    let setterArguments = mockArgumentMatchers + ["Mockingbird.ArgumentMatcher(newValue)"]
    let setterInvocation = ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclarationForSubscriptSetter)"),
        ("setterSelectorName", "\(doubleQuoted: uniqueDeclarationForSubscriptSetter)"),
        ("selectorType", "Mockingbird.SelectorType.subscriptSetter"),
        ("arguments", "[\(separated: setterArguments)]"),
        ("returnType", "Swift.ObjectIdentifier(Void.self)"),
      ])
    let callArguments = invocationArguments.map({
      (argument: (argumentLabel: String?, parameterName: String)) -> String in
      guard let argumentLabel = argument.argumentLabel,
            argumentLabel.backtickUnwrapped != argument.parameterName.backtickUnwrapped else {
        return argument.parameterName
      }
      return "\(argumentLabel): \(argument.parameterName)"
    })
    
    let getterDefinition = PropertyDefinitionTemplate(
      type: .getter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        ThunkTemplate(mockableType: context.mockableType,
                      invocation: getterInvocation.render(),
                      shortSignature: method.parameters.isEmpty ? nil : shortSignature,
                      longSignature: longSignature,
                      returnType: matchableReturnType,
                      isBridged: true,
                      isThrowing: method.isThrowing,
                      isStatic: method.kind.typeScope.isStatic,
                      callMember: { scope in
                        return "\(scope)[\(separated: callArguments)]"
                      },
                      invocationArguments: invocationArguments).render())
    
    let setterShortSignature = method.parameters.isEmpty ? nil : """
    ()\(method.isThrowing ? " throws" : "") -> Void
    """
    let setterParameterTypes = matchableParameterTypes + [matchableReturnType]
    let setterLongSignature = """
    (\(separated: setterParameterTypes))\(method.isThrowing ? " throws" : "") -> Void
    """
    let setterInvocationArguments = invocationArguments + [(nil, "newValue")]
    let setterDefinition = PropertyDefinitionTemplate(
      type: .setter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        ThunkTemplate(mockableType: context.mockableType,
                      invocation: setterInvocation.render(),
                      shortSignature: setterShortSignature,
                      longSignature: setterLongSignature,
                      returnType: "Void",
                      isBridged: true,
                      isThrowing: method.isThrowing,
                      isStatic: method.kind.typeScope.isStatic,
                      callMember: { scope in
                        return "\(scope)[\(separated: callArguments)] = newValue"
                      },
                      invocationArguments: setterInvocationArguments).render())
    
    return String(lines: [
      "// MARK: Mocked \(fullNameForMocking)",
      VariableDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                 declaration: "public \(overridableModifiers)\(uniqueDeclaration)",
                                 body: String(lines: [getterDefinition.render(),
                                                      setterDefinition.render()])).render(),
    ])
  }
  
  override var synthesizedDeclarations: String {
    let getterReturnType = matchableReturnType
    let setterReturnType = "Void"
    
    let modifiers = method.isThrowing ? " throws" : ""
    
    let getterInvocationType = """
    (\(separated: matchableParameterTypes))\(modifiers) -> \(getterReturnType)
    """
    
    let setterParameterTypes = matchableParameterTypes + [matchableReturnType]
    let setterInvocationType = """
    (\(separated: setterParameterTypes))\(modifiers) -> \(setterReturnType)
    """
    
    var mockableMethods = [String]()
    
    let getterGenericTypes = ["\(Declaration.subscriptGetterDeclaration)",
                              getterInvocationType,
                              getterReturnType]
    let setterGenericTypes = ["\(Declaration.subscriptSetterDeclaration)",
                              setterInvocationType,
                              setterReturnType]
    
    mockableMethods.append(matchableSubscript(isGetter: true,
                                              genericTypes: getterGenericTypes))
    mockableMethods.append(matchableSubscript(isGetter: false,
                                              genericTypes: setterGenericTypes))
    
    if method.isVariadic {
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
  
  func matchableSubscript(isGetter: Bool,
                          isVariadic: Bool = false,
                          genericTypes: [String]) -> String {
    let variant: FunctionVariant = isGetter ? .subscriptGetter : .subscriptSetter
    let name = fullName(for: .matching(useVariadics: isVariadic, variant: variant))
    let namePrefix = isGetter ? "get" : "set"
    let returnType = isGetter ? "\(parenthetical: matchableReturnType)" : "Void"
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
        ("setterSelectorName", "\(doubleQuoted: uniqueDeclarationForSubscriptSetter)"),
        ("selectorType", "Mockingbird.SelectorType.subscript" + (isGetter ? "Getter" : "Setter")),
        ("arguments", "[\(argumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(returnType).self)"),
      ])
    
    let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
    return \(ObjectInitializationTemplate(
      name: "Mockingbird.Mockable",
      genericTypes: genericTypes,
              arguments: [("mock", mockObject), ("invocation", invocation.render())]))
    """
    
    let syntheizedReturnType = "Mockingbird.Mockable<\(separated: genericTypes)>"
    let declaration = "public \(regularModifiers)func \(namePrefix)\(name.capitalizedFirst) -> \(syntheizedReturnType)"
    let genericConstraints = method.whereClauses.map({ context.specializeTypeName("\($0)") })
    return FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                      declaration: declaration,
                                      genericConstraints: genericConstraints,
                                      body: body).render()
  }
  
  lazy var uniqueDeclarationForSubscriptGetter: String = {
    let fullName = self.fullName(for: .mocking(variant: .subscriptGetter))
    return "get.\(fullName)\(returnTypeAttributesForMocking) -> \(mockableReturnType)\(genericConstraints)"
  }()
  
  lazy var uniqueDeclarationForSubscriptSetter: String = {
    let fullName = self.fullName(for: .mocking(variant: .subscriptSetter))
    return "set.\(fullName)\(returnTypeAttributesForMocking) -> \(mockableReturnType)\(genericConstraints)"
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
}
