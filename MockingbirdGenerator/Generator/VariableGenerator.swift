//
//  VariableGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/6/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation

extension Variable {
  func createGenerator(in context: MockableType) -> VariableGenerator {
    return VariableGenerator(variable: self, context: context)
  }
}

class VariableGenerator {
  let variable: Variable
  let context: MockableType
  init(variable: Variable, context: MockableType) {
    self.variable = variable
    self.context = context
  }
  
  func generate() -> String {
    return """
    \(generatedMocks)
    
    \(generatedStubs)
    
    \(generatedVerifications)
    """
  }
  
  var generatedMocks: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    let typeName = specializedTypeName
    return """
      // MARK: Mockable `\(variable.name)`
    \(attributes)
      \(context.kind == .class ? "override " : "")\(accessLevel)\(modifiers)var \(variable.name): \(typeName) {
        get {
          let invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [])
          \(contextPrefix)mockingContext.didInvoke(invocation)
          return (\(contextPrefix)stubbingContext.implementation(for: invocation) as! () -> \(typeName))()
        }
        set {
          let invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: [ArgumentMatcher(newValue)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
          let implementation = \(contextPrefix)stubbingContext.implementation(for: invocation, optional: true)
          if let concreteImplementation = implementation as? (\(typeName)) -> Void {
            concreteImplementation(newValue)
          } else {
            (implementation as? () -> Void)?()
          }
        }
      }
    """
  }
  
  var generatedStubs: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    let typeName = specializedTypeName
    let getterInvocationType = "() -> \(typeName)"
    let setterInvocationType = "(\(typeName)) -> Void"
    let stubbableGetterGenericTypes = [getterInvocationType, typeName].joined(separator: ", ")
    let stubbableSetterGenericTypes = [setterInvocationType, "Void"].joined(separator: ", ")
    return """
      // MARK: Stubbable `\(variable.name)`
    \(attributes)
      public \(modifiers)func get\(capitalizedName)() -> Mockingbird.Stubbable<\(stubbableGetterGenericTypes)> {
        let invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [])
        return Mockingbird.Stubbable<\(stubbableGetterGenericTypes)>(stubbingContext: \(contextPrefix)stubbingContext, invocation: invocation)
      }
    \(attributes)
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Mockingbird.Stubbable<\(stubbableSetterGenericTypes)> {
        let arguments = [Mockingbird.resolve(newValue)]
        let invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: arguments)
        return Mockingbird.Stubbable<\(stubbableSetterGenericTypes)>(stubbingContext: \(contextPrefix)stubbingContext, invocation: invocation)
      }
    """
  }
  
  var generatedVerifications: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    let typeName = specializedTypeName
    return """
      // MARK: Verifiable `\(variable.name)`
    \(attributes)
      public \(modifiers)func get\(capitalizedName)() -> Mockingbird.Mockable<\(typeName)> {
        let invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [])
        return Mockingbird.Mockable<\(typeName)>(mockingContext: \(contextPrefix)mockingContext, invocation: invocation)
      }
    \(attributes)
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Mockingbird.Mockable<Void> {
        let arguments = [Mockingbird.resolve(newValue)]
        let invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: arguments)
        return Mockingbird.Mockable<Void>(mockingContext: \(contextPrefix)mockingContext, invocation: invocation)
      }
    """
  }
  
  lazy var declarationAttributes: String = {
    return variable.attributes.declarations.joined(separator: " ")
  }()
  
  lazy var modifiers: String = {
    return (variable.kind.typeScope == .static || variable.kind.typeScope == .class ? "class " : "")
  }()
  
  lazy var contextPrefix: String = {
    return (variable.kind.typeScope == .static || variable.kind.typeScope == .class ? "staticMock." : "")
  }()
  
  lazy var accessLevel: String = {
    guard variable.setterAccessLevel == .private || variable.setterAccessLevel == .fileprivate
      else { return "public " }
    return "public \(variable.setterAccessLevel)(set) "
  }()
  
  lazy var getterName: String = { return "\(variable.name).get" }()
  lazy var setterName: String = { return "\(variable.name).set" }()
  
  lazy var specializedTypeName: String = {
    return context.specializeTypeName(variable.typeName)
  }()
  
  lazy var capitalizedName: String = {
    return variable.name.capitalizedFirst
  }()
}
