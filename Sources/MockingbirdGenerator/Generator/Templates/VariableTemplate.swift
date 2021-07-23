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
  
  lazy var getterCallingContext: String = {
    let superCall = context.mockableType.kind != .class ? "nil" :
      "super.\(backticked: variable.name)"
    return ObjectInitializationTemplate(
      name: "Mockingbird.CallingContext",
      arguments: [("super", superCall)]
    ).render()
  }()
  
  lazy var setterCallingContext: String = {
    // Cannot reference the super setter directly.
    let typeName = unwrappedSpecializedTypeName
    let superCall = context.mockableType.kind != .class ? "nil" : ClosureTemplate(
      parameters: [("newValue", typeName)],
      body: "super.\(backticked: variable.name) = newValue"
    ).render()
    return ObjectInitializationTemplate(
      name: "Mockingbird.CallingContext",
      arguments: [("super", superCall)]
    ).render()
  }()
  
  lazy var getterInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: getterName)"),
        ("arguments", "[]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: unwrappedSpecializedTypeName).self)"),
        ("context", getterCallingContext),
      ]).render()
  }()
  
  lazy var mockableSetterInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: setterName)"),
        ("arguments", "[Mockingbird.ArgumentMatcher(newValue)]"),
        ("returnType", "Swift.ObjectIdentifier(Void.self)"),
        ("context", setterCallingContext),
      ]).render()
  }()
  
  lazy var matchableSetterInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: setterName)"),
        ("arguments", "[Mockingbird.resolve(newValue)]"),
        ("returnType", "Swift.ObjectIdentifier(Void.self)"),
        ("context", setterCallingContext),
      ]).render()
  }()
  
  var mockedDeclaration: String {
    let getterDefinition = PropertyDefinitionTemplate(
      type: .getter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
      return \(FunctionCallTemplate(
                name: "\(contextPrefix)mockingbirdContext.forwardSwiftInvocation",
                arguments: [(nil, getterInvocation)]))
      """)
    let setterDefinition = PropertyDefinitionTemplate(
      type: .setter,
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
      return \(FunctionCallTemplate(
                name: "\(contextPrefix)mockingbirdContext.forwardSwiftInvocation",
                arguments: [(nil, mockableSetterInvocation)]))
      """)
  
    let accessors = !shouldGenerateSetter ? [getterDefinition.render()] : [
      getterDefinition.render(),
      setterDefinition.render(),
    ]
    
    let override = variable.isOverridable ? "override " : ""
    let declaration = "\(override)public \(modifiers)var \(backticked: variable.name): \(specializedTypeName)"
    return String(lines: [
      "// MARK: Mocked \(variable.name)",
      VariableDefinitionTemplate(attributes: variable.attributes.safeDeclarations,
                                 declaration: declaration,
                                 body: String(lines: accessors)).render()
    ])
  }
  
  var synthesizedDeclarations: String {
    let typeName = unwrappedSpecializedTypeName
    let getterGenericTypes = ["\(Declaration.propertyGetterDeclaration)",
                              "() -> \(typeName)",
                              typeName]
    let setterGenericTypes = ["\(Declaration.propertySetterDeclaration)",
                              "(\(typeName)) -> Void",
                              "Void"]
    
    let getterReturnType = "Mockingbird.Mockable<\(getterGenericTypes.joined(separator: ", "))>"
    let getterDefinition = FunctionDefinitionTemplate(
      attributes: variable.attributes.safeDeclarations,
      declaration: "public \(modifiers)func get\(capitalizedName)() -> \(getterReturnType)",
      body: !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
      return \(ObjectInitializationTemplate(
                name: "Mockingbird.Mockable",
                genericTypes: getterGenericTypes,
                arguments: [("mock", mockObject), ("invocation", getterInvocation)]))
      """)
    
    let setterReturnType = "Mockingbird.Mockable<\(setterGenericTypes.joined(separator: ", "))>"
    let setterDefinition = FunctionDefinitionTemplate(
      attributes: variable.attributes.safeDeclarations,
      declaration: "public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> \(setterReturnType)",
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
  
  lazy var declarationAttributes: String = {
    return variable.attributes.safeDeclarations.joined(separator: " ")
  }()
  
  lazy var modifiers: String = {
    return (variable.kind.typeScope == .static || variable.kind.typeScope == .class ? "class " : "")
  }()
  
  lazy var mockObject: String = {
    return variable.kind.typeScope == .static || variable.kind.typeScope == .class
      ? "staticMock" : "self"
  }()
  
  lazy var contextPrefix: String = {
    return mockObject + "."
  }()
  
  lazy var getterName: String = { return "\(variable.name).get" }()
  lazy var setterName: String = { return "\(variable.name).set" }()
  
  lazy var specializedTypeName: String = {
    return context.specializeTypeName(variable.typeName)
  }()
  
  lazy var unwrappedSpecializedTypeName: String = {
    return specializedTypeName.removingImplicitlyUnwrappedOptionals()
  }()
  
  lazy var capitalizedName: String = {
    return variable.name.capitalizedFirst
  }()
  
  lazy var shouldGenerateSetter: Bool = {
    return !variable.attributes.contains(.readonly) && variable.setterAccessLevel.isMockable
  }()
}
