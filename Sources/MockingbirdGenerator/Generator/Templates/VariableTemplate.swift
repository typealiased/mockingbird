//
//  VariableTemplate.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/6/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation

/// Renders a `Variable` to a `PartialFileContent` object.
class VariableTemplate: Template {
  let variable: Variable
  let context: MockableTypeTemplate
  init(variable: Variable, context: MockableTypeTemplate) {
    self.variable = variable
    self.context = context
  }
  
  func render() -> String {
    let (directiveStart, directiveEnd) = compilationDirectiveDeclaration
    return String(lines: [directiveStart,
                          String(lines: [mockedDeclaration, synthesizedDeclarations], spacing: 2),
                          directiveEnd])
  }
  
  var compilationDirectiveDeclaration: (start: String, end: String) {
    guard !variable.compilationDirectives.isEmpty else { return ("", "") }
    let start = String(lines: variable.compilationDirectives.map({ $0.declaration }))
    let end = String(lines: variable.compilationDirectives.map({ _ in "#endif" }))
    return (start, end)
  }
  
  lazy var getterInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: getterName)"),
        ("setterSelectorName", "\(doubleQuoted: setterName)"),
        ("selectorType", "Mockingbird.SelectorType.getter"),
        ("arguments", "[]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: matchableType).self)"),
      ]).render()
  }()
  
  lazy var mockableSetterInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: setterName)"),
        ("setterSelectorName", "\(doubleQuoted: setterName)"),
        ("selectorType", "Mockingbird.SelectorType.setter"),
        ("arguments", "[Mockingbird.ArgumentMatcher(newValue)]"),
        ("returnType", "Swift.ObjectIdentifier(Void.self)"),
      ]).render()
  }()
  
  lazy var matchableSetterInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: setterName)"),
        ("setterSelectorName", "\(doubleQuoted: setterName)"),
        ("selectorType", "Mockingbird.SelectorType.setter"),
        ("arguments", "[Mockingbird.resolve(newValue)]"),
        ("returnType", "Swift.ObjectIdentifier(Void.self)"),
      ]).render()
  }()
  
  var mockedDeclaration: String {
    let getterDefinition = PropertyDefinitionTemplate(
      type: .getter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        ThunkTemplate(mockableType: context.mockableType,
                      invocation: getterInvocation,
                      shortSignature: nil,
                      longSignature: "() -> \(matchableType)",
                      returnType: matchableType,
                      isBridged: true,
                      isThrowing: false,
                      isStatic: variable.kind.typeScope.isStatic,
                      callMember: { scope in
                        return "\(scope).\(backticked: self.variable.name)"
                      },
                      invocationArguments: []).render())
    let setterDefinition = PropertyDefinitionTemplate(
      type: .setter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        ThunkTemplate(mockableType: context.mockableType,
                      invocation: mockableSetterInvocation,
                      shortSignature: "() -> Void",
                      longSignature: "\(parenthetical: matchableType) -> Void",
                      returnType: "Void",
                      isBridged: true,
                      isThrowing: false,
                      isStatic: variable.kind.typeScope.isStatic,
                      callMember: { scope in
                        return "\(scope).\(backticked: self.variable.name) = newValue"
                      },
                      invocationArguments: [(nil, "newValue")]).render())
  
    let accessors = !shouldGenerateSetter ? [getterDefinition.render()] : [
      getterDefinition.render(),
      setterDefinition.render(),
    ]
    
    let override = variable.isOverridable ? "override " : ""
    let declaration = "\(override)public \(modifiers)var \(backticked: variable.name): \(mockableType)"
    return String(lines: [
      "// MARK: Mocked \(variable.name)",
      VariableDefinitionTemplate(attributes: variable.attributes.safeDeclarations,
                                 declaration: declaration,
                                 body: String(lines: accessors)).render()
    ])
  }
  
  var synthesizedDeclarations: String {
    let getterGenericTypes = ["\(Declaration.propertyGetterDeclaration)",
                              "() -> \(matchableType)",
                              matchableType]
    let setterGenericTypes = ["\(Declaration.propertySetterDeclaration)",
                              "(\(matchableType)) -> Void",
                              "Void"]
    
    let getterReturnType = "Mockingbird.Mockable<\(separated: getterGenericTypes)>"
    let getterDefinition = FunctionDefinitionTemplate(
      attributes: variable.attributes.safeDeclarations,
      declaration: "public \(modifiers)func get\(capitalizedName)() -> \(getterReturnType)",
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
      return \(ObjectInitializationTemplate(
                name: "Mockingbird.Mockable",
                genericTypes: getterGenericTypes,
                arguments: [("mock", mockObject), ("invocation", getterInvocation)]))
      """)
    
    let setterReturnType = "Mockingbird.Mockable<\(separated: setterGenericTypes)>"
    let setterDefinition = FunctionDefinitionTemplate(
      attributes: variable.attributes.safeDeclarations,
      declaration: "public \(modifiers)func set\(capitalizedName)(_ newValue: @autoclosure () -> \(matchableType)) -> \(setterReturnType)",
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
      return \(ObjectInitializationTemplate(
                name: "Mockingbird.Mockable",
                genericTypes: setterGenericTypes,
                arguments: [("mock", mockObject), ("invocation", matchableSetterInvocation)]))
      """)
    
    let accessors = !shouldGenerateSetter ? [getterDefinition.render()] : [
      getterDefinition.render(),
      setterDefinition.render(),
    ]
    return String(lines: accessors, spacing: 2)
  }
  
  lazy var modifiers: String = {
    return variable.kind.typeScope.isStatic ? "class " : ""
  }()
  
  lazy var mockObject: String = {
    return variable.kind.typeScope.isStatic ? "staticMock" : "self"
  }()
  
  // Keep this in sync with `MockingbirdFramework.Invocation.Constants.getterSuffix`
  lazy var getterName: String = {
    return "\(variable.name).getter"
  }()
  
  // Keep this in sync with `MockingbirdFramework.Invocation.Constants.setterSuffix`
  lazy var setterName: String = {
    return "\(variable.name).setter"
  }()
  
  lazy var mockableType: String = {
    return context.specializeTypeName(variable.typeName)
  }()
  
  lazy var matchableType: String = {
    return mockableType.removingImplicitlyUnwrappedOptionals()
  }()
  
  lazy var capitalizedName: String = {
    return variable.name.capitalizedFirst
  }()
  
  lazy var shouldGenerateSetter: Bool = {
    return !variable.attributes.contains(.readonly) && variable.setterAccessLevel.isMockable
  }()
}
