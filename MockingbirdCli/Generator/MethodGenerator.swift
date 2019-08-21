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
    let alreadyMatcher = "matcher\(capitalizedName) as? ArgumentMatcher"
    let createMatcher = "ArgumentMatcher(matcher\(capitalizedName) as AnyObject as? \(typeName))"
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
  func createGenerator(in context: MockableType) -> MethodGenerator {
    return MethodGenerator(method: self, context: context)
  }
}

class MethodGenerator {
  let method: Method
  let context: MockableType
  init(method: Method, context: MockableType) {
    self.method = method
    self.context = context
  }
  
  func generate() -> String {
    return [generatedMock,
            generatedStub,
            generatedVerification]
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  lazy var generatedMock: String = {
    if method.isInitializer {
      let initializerPrefix = (context.kind == .class ? "super." : "self.")
      return """
        // MARK: Mockable `\(method.name)`
      
        public \(overridableModifiers)\(fullNameForMocking) {
          \(initializerPrefix)init(\(superCallParameters))
          self.sourceLocation = Mockingbird.SourceLocation(__file, __line)
          let invocation = Mockingbird.Invocation(selectorName: "\(fullSelectorName)",
          arguments: [\(mockArgumentMatchers)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
        \(stubbedImplementationCall)
        }
      """
    } else {
      return """
        // MARK: Mockable `\(method.name)`
      
        public \(overridableModifiers)func \(fullNameForMocking) \(returnTypeAttributes)-> \(specializedReturnTypeName) {
          let invocation = Mockingbird.Invocation(selectorName: "\(fullSelectorName)",
                                                  arguments: [\(mockArgumentMatchers)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
      \(stubbedImplementationCall)
        }
      """
    }
  }()
  
  lazy var generatedStub: String = {
    guard !method.isInitializer else { return "" }
    let parameterTypes = methodParameterTypesForGenerics
    let returnTypeName = specializedReturnTypeName
    let invocationType = "(\(parameterTypes)) \(returnTypeAttributes)-> \(returnTypeName)"
    return """
      // MARK: Stubbable `\(method.name)`
    
      public \(regularModifiers)func \(fullNameForMatching) -> Mockingbird.Stubbable<\(invocationType), \(returnTypeName)> {
    \(matchableInvocation)
        if let stub = DispatchQueue.currentStub {
          \(contextPrefix)stubbingContext.swizzle(invocation, with: stub.implementation)
        }
        return Mockingbird.Stubbable<\(invocationType), \(returnTypeName)>()
      }
    """
  }()
  
  lazy var generatedVerification: String = {
    let returnTypeName = specializedReturnTypeName
    return """
      // MARK: Verifiable `\(method.name)`
    
      public \(regularModifiers)func \(fullNameForMatching) -> Mockingbird.Mockable<\(returnTypeName)> {
    \(matchableInvocation)
        if let expectation = DispatchQueue.currentExpectation {
          expect(\(contextPrefix)mockingContext, handled: invocation, using: expectation)
        }
        return Mockingbird.Mockable<\(returnTypeName)>()
      }
    """
  }()
  
  lazy var regularModifiers: String = { return modifiers(allowOverride: false) }()
  lazy var overridableModifiers: String = { return modifiers(allowOverride: true) }()
  func modifiers(allowOverride: Bool = true) -> String {
    let isRequired = method.attributes.contains(.required)
    let required = (isRequired ? "required " : "")
    let override = (context.kind == .class && !isRequired && allowOverride ? "override " : "")
    let `static` = (method.kind.typeScope == .static || method.kind.typeScope == .class ? "static " : "")
    return "\(required)\(override)\(`static`)"
  }
  
  lazy var genericConstraints: String = { // This might be slow, we should consider caching it.
    return method.genericTypes.map({ $0.flattenedDeclaration }).joined(separator: ", ")
  }()
  
  lazy var shortName: String = {
    guard let shortName = method.name.substringComponents(separatedBy: "(").first else {
      return method.name
    }
    let genericConstraints = self.genericConstraints
    return genericConstraints.isEmpty ? "\(shortName)" : "\(shortName)<\(genericConstraints)>"
  }()
  
  lazy var fullNameForMocking: String = { return fullName() }()
  lazy var fullNameForMatching: String = { return fullName(forMatching: true) }()
  func fullName(forMatching: Bool = false) -> String {
    let initializerParameters =
      method.isInitializer ? ["__file: StaticString = #file", "__line: UInt = #line"] : []
    let parameterNames = initializerParameters + method.parameters.map({ parameter -> String in
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
    })
    return "\(shortName)(\(parameterNames.joined(separator: ", ")))"
  }
  
  lazy var fullSelectorName: String = {
    return "\(method.name) -> \(specializedReturnTypeName)"
  }()
  
  lazy var superCallParameters: String = {
    return method.parameters.map({ parameter -> String in
      let label = parameter.argumentLabel ?? parameter.name
      return "\(label): `\(parameter.name)`"
    }).joined(separator: ", ")
  }()
  
  lazy var stubbedImplementationCall: String = {
    let returnTypeName = specializedReturnTypeName
    let shouldReturn = !method.isInitializer && returnTypeName != "Void"
    let returnStatement = shouldReturn ? "return " : ""
    let tryInvocation = self.tryInvocation
    let implementationType = "(\(methodParameterTypesForGenerics)) \(returnTypeAttributes)-> \(returnTypeName)"
    let optionalImplementation = shouldReturn ? "false" : "true"
    let typeCaster = shouldReturn ? "as!" : "as?"
    let invocationOptional = shouldReturn ? "" : "?"
    return """
        let implementation = \(contextPrefix)stubbingContext.implementation(for: invocation, optional: \(optionalImplementation))
        if let concreteImplementation = implementation as? \(implementationType) {
          \(returnStatement)\(tryInvocation)concreteImplementation(\(methodParameterNamesForInvocation))
        } else {
          \(returnStatement)\(tryInvocation)(implementation \(typeCaster) () -> \(returnTypeName))\(invocationOptional)()
        }
    """
  }()
  
  lazy var matchableInvocation: String = {
    guard !method.parameters.isEmpty else {
      return """
          let invocation = Invocation(selectorName: "\(fullSelectorName)", arguments: [])
      """
    }
    
    return """
    \(resolvedArgumentMatchers)
        let invocation = Invocation(selectorName: "\(fullSelectorName)", arguments: arguments)
    """
  }()
  
  lazy var resolvedArgumentMatchers: String = {
    let resolved = method.parameters.map({ $0.resolvedType }).joined(separator: "\n    ")
    let arguments = method.parameters.map({ $0.castedMatcherType(in: context) }).joined(separator: ",\n      ")
    return """
        \(resolved)
        let arguments: [ArgumentMatcher] = [
          \(arguments)
        ]
    """
  }()
  
  lazy var tryInvocation: String = {
    return method.attributes.contains(.throws) ? "try " : ""
  }()
  
  lazy var returnTypeAttributes: String = {
    let `throws` = method.attributes.contains(.throws) ? "throws " : ""
    let `rethrows` = method.attributes.contains(.rethrows) ? "rethrows " : ""
    return "\(`throws`)\(`rethrows`)"
  }()
  
  lazy var mockArgumentMatchers: String = {
    return method.parameters.map({ parameter -> String in
      guard !parameter.isClosure || parameter.isEscapingClosure else {
        // Can't save the parameter in the invocation because it's non-escaping
        return "ArgumentMatcher(nil)"
      }
      return "ArgumentMatcher(`\(parameter.name)`)"
    }).joined(separator: ", ")
  }()
  
  lazy var contextPrefix: String = {
    return (method.kind.typeScope == .static || method.kind.typeScope == .class ? "staticMock." : "")
  }()
  
  lazy var specializedReturnTypeName: String = {
    return context.specializeTypeName(method.returnTypeName)
  }()
  
  lazy var methodParameterTypesForGenerics: String = {
    return method.parameters.map({ $0.typeName }).joined(separator: ", ")
  }()
  
  lazy var methodParameterNamesForInvocation: String = {
    return method.parameters.map({ "`\($0.name)`" }).joined(separator: ", ")
  }()
}
