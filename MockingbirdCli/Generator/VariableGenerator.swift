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
    let typeName = specializedTypeName
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Mockable `\(variable.name)`
    
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
    let capitalizedName = self.capitalizedName
    let typeName = specializedTypeName
    let modifiers = self.modifiers
    let contextPrefix = self.contextPrefix
    let getterInvocationType = "() -> \(typeName)"
    let setterInvocationType = "(\(typeName)) -> Void"
    return """
      // MARK: Stubbable `\(variable.name)`
    
      public \(modifiers)func get\(capitalizedName)() -> Mockingbird.Stubbable<\(getterInvocationType), \(typeName)> {
        let invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [])
        if let stub = DispatchQueue.currentStub { \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation) }
        return Stubbable<\(getterInvocationType), \(typeName)>()
      }
    
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Mockingbird.Stubbable<\(setterInvocationType), Void> {
        let arguments = [Mockingbird.resolve(newValue)]
        let invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: arguments)
        if let stub = DispatchQueue.currentStub { \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation) }
        return Mockingbird.Stubbable<\(setterInvocationType), Void>()
      }
    """
  }
  
  var generatedVerifications: String {
    let capitalizedName = self.capitalizedName
    let typeName = specializedTypeName
    let modifiers = self.modifiers
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Verifiable `\(variable.name)`
    
      public \(modifiers)func get\(capitalizedName)() -> Mockingbird.Mockable<\(typeName)> {
        let invocation = Mockingbird.Invocation(selectorName: "\(getterName)", arguments: [])
        if let expectation = DispatchQueue.currentExpectation { expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation) }
        return Mockingbird.Mockable<\(typeName)>()
      }
    
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Mockingbird.Mockable<Void> {
        let arguments = [Mockingbird.resolve(newValue)]
        let invocation = Mockingbird.Invocation(selectorName: "\(setterName)", arguments: arguments)
        if let expectation = DispatchQueue.currentExpectation { expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation) }
        return Mockingbird.Mockable<Void>()
      }
    """
  }
  
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
