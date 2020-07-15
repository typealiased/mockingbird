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
    return [directiveStart,
            mockedDeclaration,
            frameworkDeclarations,
            directiveEnd]
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  var compilationDirectiveDeclaration: (start: String, end: String) {
    guard !variable.compilationDirectives.isEmpty else { return ("", "") }
    let start = variable.compilationDirectives
      .map({ "  " + $0.declaration })
      .joined(separator: "\n")
    let end = variable.compilationDirectives
      .map({ _ in "  #endif" })
      .joined(separator: "\n")
    return (start, end)
  }
  
  var mockedDeclaration: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    let override = variable.isOverridable ? "override " : ""
    
    let getter = """
        get {
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [], returnType: Swift.ObjectIdentifier((\(unwrappedSpecializedTypeName)).self))
          return \(contextPrefix)mockingContext.didInvoke(invocation) { () -> \(unwrappedSpecializedTypeName) in
            let implementation = \(contextPrefix)stubbingContext.implementation(for: invocation)
            if let concreteImplementation = implementation as? () -> \(unwrappedSpecializedTypeName) {
              return concreteImplementation()
            } else if let defaultValue = \(contextPrefix)stubbingContext.defaultValueProvider.provideValue(for: (\(unwrappedSpecializedTypeName)).self) {
              return defaultValue
            } else {
              fatalError(\(contextPrefix)stubbingContext.failTest(for: invocation))
            }
          }
        }
    """
    
    let setter: String
    if !shouldGenerateSetter {
      setter = ""
    } else {
      setter = """

          set {
            let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: [ArgumentMatcher(newValue)], returnType: Swift.ObjectIdentifier(Void.self))
            \(contextPrefix)mockingContext.didInvoke(invocation)
            let implementation = \(contextPrefix)stubbingContext.implementation(for: invocation)
            if let concreteImplementation = implementation as? (\(unwrappedSpecializedTypeName)) -> Void {
              concreteImplementation(newValue)
            } else {
              (implementation as? () -> Void)?()
            }
          }
      """
    }
    
    let body: String
    if context.shouldGenerateThunks {
      body = """
      {
      \(getter)\(setter)
        }
      """
    } else {
      body = "{ get { \(MockableTypeTemplate.Constants.thunkStub) } " + (shouldGenerateSetter ? "set { \(MockableTypeTemplate.Constants.thunkStub) } " : "") + "}"
    }
    
    return """
      // MARK: Mocked \(variable.name)
    \(attributes)
      \(override)public \(modifiers)var `\(variable.name)`: \(specializedTypeName) \(body)
    """
  }
  
  var frameworkDeclarations: String {
    let attributes = declarationAttributes.isEmpty ? "" : "  \(declarationAttributes)\n"
    let typeName = unwrappedSpecializedTypeName
    let getterInvocationType = "() -> \(typeName)"
    let setterInvocationType = "(\(typeName)) -> Void"
    let mockableGetterGenericTypes = ["\(Declaration.propertyGetterDeclaration)",
                                      getterInvocationType,
                                      typeName].joined(separator: ", ")
    let mockableSetterGenericTypes = ["\(Declaration.propertySetterDeclaration)",
                                      setterInvocationType,
                                      "Void"].joined(separator: ", ")
    
    var accessors = [String]()
    
    let getterBody: String
    if context.shouldGenerateThunks {
      getterBody = """
      {
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [], returnType: Swift.ObjectIdentifier((\(unwrappedSpecializedTypeName)).self))
          return Mockingbird.Mockable<\(mockableGetterGenericTypes)>(mock: \(mockObject), invocation: invocation)
        }
      """
    } else {
      getterBody = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
    }
    let getter = """
    \(attributes)  public \(modifiers)func get\(capitalizedName)() -> Mockingbird.Mockable<\(mockableGetterGenericTypes)> \(getterBody)
    """
    accessors.append(getter)
    
    if shouldGenerateSetter {
      let setterBody: String
      if context.shouldGenerateThunks {
        setterBody = """
        {
            let arguments: [Mockingbird.ArgumentMatcher] = [Mockingbird.resolve(newValue)]
            let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: arguments, returnType: Swift.ObjectIdentifier(Void.self))
            return Mockingbird.Mockable<\(mockableSetterGenericTypes)>(mock: \(mockObject), invocation: invocation)
          }
        """
      } else {
        setterBody = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
      }
      
      let setter = """
      \(attributes)  public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Mockingbird.Mockable<\(mockableSetterGenericTypes)> \(setterBody)
      """
      accessors.append(setter)
    }
    
    return accessors.joined(separator: "\n\n")
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
