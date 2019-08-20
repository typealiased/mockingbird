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
    
    \(createStubs(in: context))
    
    \(createVerifications(in: context))
    """
  }
  
  lazy var generatedMocks: String = {
    let typeName = specializedTypeName
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Mockable `\(variable.name)`
    
      \(context.kind == .class ? "override " : "")\(accessLevel)\(modifiers)var \(variable.name): \(typeName) {
        get {
          let invocation = Invocation(selectorName: "\(getterName)", arguments: [])
          \(contextPrefix)mockingContext.didInvoke(invocation)
          return (try? (try! \(contextPrefix)stubbingContext.implementation(for: invocation))(invocation)) as! \(typeName)
        }
        set {
          let invocation = Invocation(selectorName: "\(setterName)", arguments: [ArgumentMatcher(newValue)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
          _ = try? (try? \(contextPrefix)stubbingContext.implementation(for: invocation))?(invocation)
        }
      }
    """
  }()
  
  func createStubs(in context: MockableType) -> String {
    let capitalizedName = self.capitalizedName
    let typeName = specializedTypeName
    let unwrappedTypeName = specializedUnwrappedTypeName
    let modifiers = self.modifiers
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Stubbable `\(variable.name)`
    
      public \(modifiers)func get\(capitalizedName)() -> Stubbable<\(typeName)> {
        let invocation = Invocation(selectorName: "\(getterName)", arguments: [])
        if let stub = DispatchQueue.currentStub {
          \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation)
        }
        return Stubbable<\(typeName)>()
      }
    
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Stubbable<Void> {
        let matcherNewValue = resolve(newValue)
        let arguments: [ArgumentMatcher] = [
          (matcherNewValue as? ArgumentMatcher) ?? ArgumentMatcher(newValue as AnyObject as? \(unwrappedTypeName))
        ]
        let invocation = Invocation(selectorName: "\(setterName)", arguments: arguments)
        if let stub = DispatchQueue.currentStub {
          \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation)
        }
        return Stubbable<Void>()
      }
    """
  }
  
  func createVerifications(in context: MockableType) -> String {
    let capitalizedName = self.capitalizedName
    let typeName = specializedTypeName
    let unwrappedTypeName = specializedUnwrappedTypeName
    let modifiers = self.modifiers
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Verifiable `\(variable.name)`
    
      public \(modifiers)func get\(capitalizedName)() -> Mockable<\(typeName)> {
        let invocation = Invocation(selectorName: "\(getterName)", arguments: [])
        if let expectation = DispatchQueue.currentExpectation {
          expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation)
        }
        return Mockable<\(typeName)>()
      }
    
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> Mockable<Void> {
        let matcherNewValue = resolve(newValue)
        let arguments: [ArgumentMatcher] = [
          (matcherNewValue as? ArgumentMatcher) ?? ArgumentMatcher(newValue as AnyObject as? \(unwrappedTypeName))
        ]
        let invocation = Invocation(selectorName: "\(setterName)", arguments: arguments)
        if let expectation = DispatchQueue.currentExpectation {
          expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation)
        }
        return Mockable<Void>()
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
  lazy var specializedUnwrappedTypeName: String = {
    return context.specializeTypeName(variable.typeName, unwrapOptional: true)
  }()
  
  lazy var capitalizedName: String = {
    return variable.name.capitalizedFirst
  }()
}
