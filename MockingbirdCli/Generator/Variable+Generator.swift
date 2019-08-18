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
  func generate(in context: MockableType) -> String {
    return """
    \(createMocks(in: context))
    
    \(createStubs(in: context))
    
    \(createVerifications(in: context))
    """
  }
  
  func createMocks(in context: MockableType) -> String {
    let typeName = context.specializeTypeName(self.typeName)
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Mockable `\(name)`
    
      \(context.kind == .class ? "override " : "")\(accessLevel)\(modifiers(in: context))var \(name): \(typeName) {
        get {
          let invocation = MockingbirdInvocation(selectorName: "\(getterName)", arguments: [])
          \(contextPrefix)mockingContext.didInvoke(invocation)
          return (try? (try! \(contextPrefix)stubbingContext.implementation(for: invocation))(invocation)) as! \(typeName)
        }
        set {
          let invocation = MockingbirdInvocation(selectorName: "\(setterName)",
                                                 arguments: [MockingbirdMatcher(newValue)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
          _ = try? (try? \(contextPrefix)stubbingContext.implementation(for: invocation))?(invocation)
        }
      }
    """
  }
  
  func createStubs(in context: MockableType) -> String {
    let capitalizedName = name.capitalizedFirst
    let typeName = context.specializeTypeName(self.typeName)
    let unwrappedTypeName = context.specializeTypeName(self.typeName, unwrapOptional: true)
    let modifiers = self.modifiers(in: context)
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Stubbable `\(name)`
    
      public \(modifiers)func get\(capitalizedName)() -> MockingbirdScopedStub<\(typeName)> {
        let invocation = MockingbirdInvocation(selectorName: "\(getterName)", arguments: [])
        if let stub = DispatchQueue.currentStub {
          \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation)
        }
        return MockingbirdScopedStub<\(typeName)>()
      }
    
      public \(modifiers)func set\(capitalizedName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> MockingbirdScopedStub<Void> {
        let matcherNewValue = resolve(newValue)
        let arguments: [MockingbirdMatcher] = [
          (matcherNewValue as? MockingbirdMatcher) ?? MockingbirdMatcher(newValue as AnyObject as? \(unwrappedTypeName))
        ]
        let invocation = MockingbirdInvocation(selectorName: "\(setterName)", arguments: arguments)
        if let stub = DispatchQueue.currentStub {
          \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation)
        }
        return MockingbirdScopedStub<Void>()
      }
    """
  }
  
  func createVerifications(in context: MockableType) -> String {
    let uppercaseName = name.capitalizedFirst
    let typeName = context.specializeTypeName(self.typeName)
    let unwrappedTypeName = context.specializeTypeName(self.typeName, unwrapOptional: true)
    let modifiers = self.modifiers(in: context)
    let contextPrefix = self.contextPrefix
    return """
      // MARK: Verifiable `\(name)`
    
      public \(modifiers)func get\(uppercaseName)() -> MockingbirdScopedMock {
        let invocation = MockingbirdInvocation(selectorName: "\(getterName)", arguments: [])
        if let expectation = DispatchQueue.currentExpectation {
          expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation)
        }
        return MockingbirdScopedMock()
      }
    
      public \(modifiers)func set\(uppercaseName)(_ newValue: @escaping @autoclosure () -> \(typeName)) -> MockingbirdScopedMock {
        let matcherNewValue = resolve(newValue)
        let arguments: [MockingbirdMatcher] = [
          (matcherNewValue as? MockingbirdMatcher) ?? MockingbirdMatcher(newValue as AnyObject as? \(unwrappedTypeName))
        ]
        let invocation = MockingbirdInvocation(selectorName: "\(setterName)", arguments: arguments)
        if let expectation = DispatchQueue.currentExpectation {
          expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation)
        }
        return MockingbirdScopedMock()
      }
    """
  }
  
  func modifiers(in context: MockableType) -> String {
    return (kind.typeScope == .static || kind.typeScope == .class ? "class " : "")
  }
  
  var contextPrefix: String {
    return (kind.typeScope == .static || kind.typeScope == .class ? "staticMock." : "")
  }
  
  var accessLevel: String {
    guard setterAccessLevel == .private || setterAccessLevel == .fileprivate else { return "public " }
    return "public \(String(describing: setterAccessLevel))(set) "
  }
  
  var getterName: String { return "\(name).get" }
  var setterName: String { return "\(name).set" }
}
