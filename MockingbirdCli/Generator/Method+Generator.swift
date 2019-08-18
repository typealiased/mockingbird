//
//  MethodGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/6/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//
// swiftlint:disable leading_whitespace

import Foundation

extension MethodParameter {
  var resolvedType: String {
    let capitalizedName = name.capitalizedFirst
    return "let matcher\(capitalizedName) = resolve(`\(name)`)"
  }
  
  func castedMatcherType(in context: MockableType) -> String {
    let capitalizedName = name.capitalizedFirst
    let typeName = matchableTypeName(in: context, unwrapOptional: true)
    let alreadyMatcher = "matcher\(capitalizedName) as? MockingbirdMatcher"
    let createMatcher = "MockingbirdMatcher(matcher\(capitalizedName) as AnyObject as? \(typeName))"
    return "(\(alreadyMatcher)) ?? \(createMatcher)"
  }
  
  func matchableTypeName(in context: MockableType, unwrapOptional: Bool = false) -> String {
    let typeName = context.specializeTypeName(self.typeName, unwrapOptional: unwrapOptional)
    guard isClosure else { return typeName }
    return typeName
      .replacingOccurrences(of: "@escaping", with: "")
      .replacingOccurrences(of: "@autoclosure", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  var isClosure: Bool { // This could be slow, should cache
    return typeName.contains(" -> ")
  }
  
  var isEscapingClosure: Bool { // This could be slow, should cache
    return typeName.contains("@escaping")
  }
  
  var isAutoclosure: Bool { // This could be slow, should cache
    return typeName.contains("@autoclosure")
  }
}

extension Method {
  func generate(in context: MockableType) -> String {
    return [createMock(in: context),
            createStub(in: context),
            createVerification(in: context)]
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  func createMock(in context: MockableType) -> String {
    let returnTypeName = context.specializeTypeName(self.returnTypeName)
    return """
      // MARK: Mockable `\(name)`
    
      public \(modifiers(in: context))func \(fullName(in: context)) \(returnTypeAttributes)-> \(returnTypeName) {
        let invocation = MockingbirdInvocation(selectorName: "\(fullSelectorName(in: context))",
                                               arguments: [\(mockArgumentMatchers)])
        \(contextPrefix)mockingContext.didInvoke(invocation)
    \(stubbedImplementationCall(in: context))
      }
    """
  }
  
  func createStub(in context: MockableType) -> String {
    guard !isInitializer else { return "" }
    let returnTypeName = context.specializeTypeName(self.returnTypeName)
    return """
      // MARK: Stubbable `\(name)`
    
      public \(modifiers(in: context, allowOverride: false))func \(fullName(in: context, forMatching: true)) -> MockingbirdScopedStub<\(returnTypeName)> {
    \(matchableInvocation(in: context))
        if let stub = DispatchQueue.currentStub {
          \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation)
        }
        return MockingbirdScopedStub<\(returnTypeName)>()
      }
    """
  }
  
  func createVerification(in context: MockableType) -> String {
    return """
      // MARK: Verifiable `\(name)`
    
      public \(modifiers(in: context, allowOverride: false))func \(fullName(in: context, forMatching: true)) -> MockingbirdScopedMock {
    \(matchableInvocation(in: context))
        if let expectation = DispatchQueue.currentExpectation {
          expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation)
        }
        return MockingbirdScopedMock()
      }
    """
  }
  
  func modifiers(in context: MockableType, allowOverride: Bool = true) -> String {
    let isRequired = attributes.contains(.required)
    let required = (isRequired ? "required " : "")
    let override = (context.kind == .class && !isRequired && allowOverride ? "override " : "")
    let `static` = (kind.typeScope == .static || kind.typeScope == .class ? "static " : "")
    return "\(required)\(override)\(`static`)"
  }
  
  var genericConstraints: String { // This might be slow, we should consider caching it.
    return genericTypes.map({ genericType -> String in
      guard !genericType.inheritedTypes.isEmpty else { return genericType.name }
      let inheritedTypes = Array(genericType.inheritedTypes).joined(separator: " & ")
      return "\(genericType.name): \(inheritedTypes)"
    }).joined(separator: ", ")
  }
  
  var shortName: String {
    guard let shortName = name.components(separatedBy: "(").first else { return name }
    let genericConstraints = self.genericConstraints
    return genericConstraints.isEmpty ? "\(shortName)" : "\(shortName)<\(genericConstraints)>"
  }
  
  func fullName(in context: MockableType, forMatching: Bool = false) -> String {
    let parameterNames = parameters.map({ parameter -> String in
      let typeName: String
      if forMatching {
        typeName = "@escaping @autoclosure () -> \(parameter.matchableTypeName(in: context))"
      } else {
        typeName = context.specializeTypeName(parameter.typeName)
      }
      let argumentLabel = parameter.argumentLabel ?? "_"
      if argumentLabel != parameter.name {
        return "\(argumentLabel) \(parameter.name): \(typeName)"
      } else {
        return "\(parameter.name): \(typeName)"
      }
    }).joined(separator: ", ")
    return "\(shortName)(\(parameterNames))"
  }
  
  func fullSelectorName(in context: MockableType) -> String {
    let returnTypeName = context.specializeTypeName(self.returnTypeName)
    return "\(name) -> \(returnTypeName)"
  }
  
  func stubbedImplementationCall(in context: MockableType) -> String {
    if returnTypeName == "Void" {
      return """
          guard let implementation = try? \(contextPrefix)stubbingContext.implementation(for: invocation) else { return }
          (\(tryInvocation)implementation(invocation)) as! Void
      """
    } else {
      let returnTypeName = context.specializeTypeName(self.returnTypeName)
      let castedResult = !isInitializer ? " as! \(returnTypeName)" : ""
      return """
          \(!isInitializer ? "return " : "")(\(tryInvocation)(try! \(contextPrefix)stubbingContext.implementation(for: invocation))(invocation))\(castedResult)
      """
    }
  }
  
  func matchableInvocation(in context: MockableType) -> String {
    guard !parameters.isEmpty else {
      return """
          let invocation = MockingbirdInvocation(selectorName: "\(fullSelectorName(in: context))",
                                                 arguments: [])
      """
    }
    
    return """
    \(resolvedArgumentMatchers(in: context))
        let invocation = MockingbirdInvocation(selectorName: "\(fullSelectorName(in: context))",
                                               arguments: arguments)
    """
  }
  
  func resolvedArgumentMatchers(in context: MockableType) -> String {
    let resolved = parameters.map({ $0.resolvedType }).joined(separator: "\n    ")
    let arguments = parameters.map({ $0.castedMatcherType(in: context) }).joined(separator: ",\n      ")
    return """
        \(resolved)
        let arguments: [MockingbirdMatcher] = [
          \(arguments)
        ]
    """
  }
  
  var tryInvocation: String {
    return "try\(attributes.contains(.throws) ? "" : "?") "
  }
  
  var returnTypeAttributes: String {
    let `throws` = attributes.contains(.throws) ? "throws " : ""
    let `rethrows` = attributes.contains(.rethrows) ? "rethrows " : ""
    return "\(`throws`)\(`rethrows`)"
  }
  
  var mockArgumentMatchers: String {
    return parameters.map({ parameter -> String in
      guard !parameter.isClosure || parameter.isEscapingClosure else {
        // Can't save the parameter in the invocation because it's non-escaping
        return "MockingbirdMatcher(nil)"
      }
      return "MockingbirdMatcher(`\(parameter.name)`)"
    }).joined(separator: ", ")
  }
  
  var contextPrefix: String {
    return (kind.typeScope == .static || kind.typeScope == .class ? "staticMock." : "")
  }
}
