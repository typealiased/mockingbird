//
//  MethodTemplate.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/6/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation

/// Renders a `Method` to a `PartialFileContent` object.
class MethodTemplate: Template {
  let method: Method
  let context: MockableTypeTemplate
  init(method: Method, context: MockableTypeTemplate) {
    self.method = method
    self.context = context
  }
  
  func render() -> String {
    let (preprocessorStart, preprocessorEnd) = compilationDirectiveDeclaration
    return [preprocessorStart,
            mockedDeclarations,
            frameworkDeclarations,
            preprocessorEnd]
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  private enum Constants {
    /// Certain methods have `Self` enforced parameter constraints.
    static let reservedNamesMap: [String: String] = [
      // Equatable
      "==": "_equalTo",
      "!=": "_notEqualTo",
      
      // Comparable
      "<": "_lessThan",
      "<=": "_lessThanOrEqualTo",
      ">": "_greaterThan",
      ">=": "_greaterThanOrEqualTo",
    ]
  }
  
  var compilationDirectiveDeclaration: (start: String, end: String) {
    guard !method.compilationDirectives.isEmpty else { return ("", "") }
    let start = method.compilationDirectives
      .map({ "  " + $0.declaration })
      .joined(separator: "\n")
    let end = method.compilationDirectives
      .map({ _ in "  #endif" })
      .joined(separator: "\n")
    return (start, end)
  }
  
  var classInitializerProxy: String {
    guard method.isInitializer, context.mockableType.kind == .class else { return "" }
    // We can't usually infer what concrete arguments to pass to the designated initializer.
    guard !method.attributes.contains(.convenience) else { return "" }
    let attributes = declarationAttributes.isEmpty ? "" : "    \(declarationAttributes)\n"
    let failable = method.attributes.contains(.failable) ? "?" : ""
    let scopedName = context.createScopedName(with: [], suffix: "Mock")
    return """
    \(attributes)    public static func \(fullNameForInitializerProxy)\(returnTypeAttributesForMocking) -> \(scopedName)\(failable)\(genericConstraints) {
          let mock: \(scopedName)\(failable) = \(tryInvocation)\(scopedName)(\(superCallParameters))
          mock\(failable).sourceLocation = SourceLocation(__file, __line)
          return mock
        }
    """
  }
  
  var mockedDeclarations: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    if method.isInitializer {
      // We can't usually infer what concrete arguments to pass to the designated initializer.
      guard !method.attributes.contains(.convenience) else { return "" }
      
      let functionDeclaration = "public \(overridableModifiers)\(uniqueDeclaration)"
      let checkVersion: String
      if context.mockableType.kind == .class || context.protocolClassConformance != nil {
        let trySuper = method.attributes.contains(.throws) ? "try " : ""
        checkVersion = """
            \(trySuper)super.init(\(superCallParameters))
            Mockingbird.checkVersion(for: self)
        """
      } else {
        checkVersion = "    Mockingbird.checkVersion(for: self)"
      }
      return """
        // MARK: Mocked \(fullNameForMocking)
      \(attributes)
        \(functionDeclaration){
      \(checkVersion)
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [\(mockArgumentMatchers)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
        }
      """
    } else {
      return """
        // MARK: Mocked \(fullNameForMocking)
      \(attributes)
        public \(overridableModifiers)func \(uniqueDeclaration) {
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [\(mockArgumentMatchers)])
          \(contextPrefix)mockingContext.didInvoke(invocation)
      \(stubbedImplementationCall)
        }
      """
    }
  }
  
  lazy var uniqueDeclaration: String = {
    if method.isInitializer {
      return "\(fullNameForMocking)\(returnTypeAttributesForMocking)\(genericConstraints) "
    } else {
      return "\(fullNameForMocking)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)\(genericConstraints)"
    }
  }()
  
  var frameworkDeclarations: String {
    guard !method.isInitializer else { return "" }
    let attributes = declarationAttributes.isEmpty ? "" : "  \(declarationAttributes)\n"
    let returnTypeName = specializedReturnTypeName.removingImplicitlyUnwrappedOptionals()
    let invocationType = "(\(methodParameterTypes)) \(returnTypeAttributesForMatching)-> \(returnTypeName)"
    let mockableGenericTypes = ["Mockingbird.MethodDeclaration",
                                 invocationType,
                                 returnTypeName].joined(separator: ", ")
    let mockable = """
    \(attributes)  public \(regularModifiers)func \(fullNameForMatching) -> Mockingbird.Mockable<\(mockableGenericTypes)>\(genericConstraints) {
    \(matchableInvocation)
        return Mockingbird.Mockable<\(mockableGenericTypes)>(mock: \(mockObject), invocation: invocation)
      }
    """
    guard isVariadicMethod else { return mockable }
    
    // Allow methods with a variadic parameter to use variadics when stubbing.
    return """
    \(mockable)
    \(attributes)  public \(regularModifiers)func \(fullNameForMatchingVariadics) -> Mockingbird.Mockable<\(mockableGenericTypes)>\(genericConstraints) {
    \(matchableInvocationVariadics)
        return Mockingbird.Mockable<\(mockableGenericTypes)>(mock: \(mockObject), invocation: invocation)
      }
    """
  }

  lazy var declarationAttributes: String = {
    return method.attributes.declarations.joined(separator: " ")
  }()
  
  /// Modifiers specifically for stubbing and verification methods.
  lazy var regularModifiers: String = { return modifiers(allowOverride: false) }()
  /// Modifiers for mocked methods.
  lazy var overridableModifiers: String = { return modifiers(allowOverride: true) }()
  func modifiers(allowOverride: Bool = true) -> String {
    let isRequired = method.attributes.contains(.required)
    let required = (isRequired || method.isInitializer ? "required " : "")
    let shouldOverride = method.isOverridable && !isRequired && allowOverride
    let override = shouldOverride ? "override " : ""
    let `static` = (method.kind.typeScope == .static || method.kind.typeScope == .class)
      ? "static " : ""
    return "\(required)\(override)\(`static`)"
  }
  
  lazy var genericTypes: String = {
    return method.genericTypes.map({ $0.flattenedDeclaration }).joined(separator: ", ")
  }()
  
  lazy var genericConstraints: String = {
    guard !method.whereClauses.isEmpty else { return "" }
    return " where " + method.whereClauses
      .map({ context.specializeTypeName("\($0)") }).joined(separator: ", ")
  }()
  
  func shortName(forInitializerProxy: Bool) -> String {
    let failable: String
    if forInitializerProxy {
      failable = ""
    } else if method.attributes.contains(.failable) {
      failable = "?"
    } else if method.attributes.contains(.unwrappedFailable) {
      failable = "!"
    } else {
      failable = ""
    }
    
    let tick = method.isInitializer
      || (method.shortName.first?.isLetter != true
        && method.shortName.first?.isNumber != true
        && method.shortName.first != "_")
      ? "" : "`"
    let shortName = forInitializerProxy ? "initialize" : (tick + method.shortName + tick)
    let genericTypes = self.genericTypes
    
    return genericTypes.isEmpty ?
      "\(shortName)\(failable)" : "\(shortName)\(failable)<\(genericTypes)>"
  }
  
  lazy var fullNameForMocking: String = {
    return fullName(forMatching: false, useVariadics: false, forInitializerProxy: false)
  }()
  lazy var fullNameForMatching: String = {
    return fullName(forMatching: true, useVariadics: false, forInitializerProxy: false)
  }()
  /// It's not possible to have an autoclosure with variadics. However, since a method can only have
  /// one variadic parameter, we can generate one method for wildcard matching using an argument
  /// matcher, and another for specific matching using variadics.
  lazy var fullNameForMatchingVariadics: String = {
    return fullName(forMatching: true, useVariadics: true, forInitializerProxy: false)
  }()
  lazy var fullNameForInitializerProxy: String = {
    return fullName(forMatching: false, useVariadics: false, forInitializerProxy: true)
  }()
  func fullName(forMatching: Bool, useVariadics: Bool, forInitializerProxy: Bool) -> String {
    let parameterNames = method.parameters.map({ parameter -> String in
      let typeName: String
      if forMatching && (!useVariadics || !parameter.attributes.contains(.variadic)) {
        typeName = "@escaping @autoclosure () -> \(parameter.matchableTypeName(in: self))"
      } else {
        typeName = parameter.mockableTypeName(in: self, forClosure: false)
      }
      let argumentLabel = parameter.argumentLabel ?? "_"
      if argumentLabel != parameter.name {
        return "\(argumentLabel) \(parameter.name): \(typeName)"
      } else {
        return "\(parameter.name): \(typeName)"
      }
    }) + (!forInitializerProxy ? [] : ["__file: StaticString = #file", "__line: UInt = #line"])
    
    let actualShortName = self.shortName(forInitializerProxy: forInitializerProxy)
    let shortName: String
    if forMatching, let resolvedShortName = Constants.reservedNamesMap[actualShortName] {
      shortName = resolvedShortName
    } else {
      shortName = actualShortName
    }
    
    return "\(shortName)(\(parameterNames.joined(separator: ", ")))"
  }
  
  lazy var superCallParameters: String = {
    return method.parameters.map({ parameter -> String in
      guard let label = parameter.argumentLabel else { return "`\(parameter.name)`" }
      return "\(label): `\(parameter.name)`"
    }).joined(separator: ", ")
  }()
  
  lazy var stubbedImplementationCall: String = {
    let returnTypeName = specializedReturnTypeName.removingImplicitlyUnwrappedOptionals()
    let shouldReturn = !method.isInitializer && returnTypeName != "Void"
    let returnStatement = shouldReturn ? "return " : ""
    let implementationType = "(\(methodParameterTypes)) \(returnTypeAttributesForMatching)-> \(returnTypeName)"
    let optionalImplementation = shouldReturn ? "false" : "true"
    let typeCaster = shouldReturn ? "as!" : "as?"
    let invocationOptional = shouldReturn ? "" : "?"
    return """
        let implementation = \(contextPrefix)stubbingContext.implementation(for: invocation, optional: \(optionalImplementation))
        if let concreteImplementation = implementation as? \(implementationType) {
          \(returnStatement)\(tryInvocation)concreteImplementation(\(methodParameterNamesForInvocation))
        } else {
          \(returnStatement)\(tryInvocation)(implementation \(typeCaster) () \(returnTypeAttributesForMatching)-> \(returnTypeName))\(invocationOptional)()
        }
    """
  }()
  
  lazy var matchableInvocation: String = {
    guard !method.parameters.isEmpty else {
      return """
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [])
      """
    }
    return """
    \(resolvedArgumentMatchers)
        let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: arguments)
    """
  }()
  
  lazy var matchableInvocationVariadics: String = {
    return """
    \(resolvedArgumentMatchersVariadics)
        let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: arguments)
    """
  }()
  
  lazy var resolvedArgumentMatchers: String = {
    let resolved = method.parameters.map({
      return "Mockingbird.resolve(`\($0.name)`)"
    }).joined(separator: ", ")
    return "    let arguments: [Mockingbird.ArgumentMatcher] = [\(resolved)]"
  }()
  
  /// Variadic parameters cannot be resolved indirectly using `resolve()`.
  lazy var resolvedArgumentMatchersVariadics: String = {
    let resolved = method.parameters.map({
      guard $0.attributes.contains(.variadic) else { return "Mockingbird.resolve(`\($0.name)`)" }
      // Directly create an ArgumentMatcher if this parameter is variadic.
      return "Mockingbird.ArgumentMatcher(`\($0.name)`)"
    }).joined(separator: ", ")
    return "    let arguments: [Mockingbird.ArgumentMatcher] = [\(resolved)]"
  }()
  
  lazy var tryInvocation: String = {
    // We only try the invocation for throwing methods, not rethrowing ones since the stubbed
    // implementation is not actually the passed-in parameter to the wrapped function.
    return method.attributes.contains(.throws) ? "try " : ""
  }()
  
  lazy var returnTypeAttributesForMocking: String = {
    if method.attributes.contains(.rethrows) { return " rethrows" }
    if method.attributes.contains(.throws) { return " throws" }
    return ""
  }()
  
  lazy var returnTypeAttributesForMatching: String = {
    if method.attributes.contains(.throws) {
      return "throws "
    } else { // Cannot rethrow stubbed implementations.
      return ""
    }
  }()
  
  lazy var mockArgumentMatchers: String = {
    return method.parameters.map({ parameter -> String in
      // Can't save the argument in the invocation because it's a non-escaping parameter.
      guard !parameter.attributes.contains(.closure) || parameter.attributes.contains(.escaping) else {
        return "Mockingbird.ArgumentMatcher(Mockingbird.NonEscapingClosure<\(parameter.matchableTypeName(in: self))>())"
      }
      return "Mockingbird.ArgumentMatcher(`\(parameter.name)`)"
    }).joined(separator: ", ")
  }()
  
  lazy var mockObject: String = {
    return method.kind.typeScope == .static || method.kind.typeScope == .class
      ? "staticMock" : "self"
  }()
  
  lazy var contextPrefix: String = {
    return method.kind.typeScope == .static || method.kind.typeScope == .class
      ? "staticMock." : ""
  }()
  
  lazy var specializedReturnTypeName: String = {
    return context.specializeTypeName(method.returnTypeName)
  }()
  
  lazy var methodParameterTypes: String = {
    return method.parameters
      .map({ $0.mockableTypeName(in: self, forClosure: true) })
      .joined(separator: ", ")
  }()
  
  lazy var methodParameterNamesForInvocation: String = {
    return method.parameters.map({ $0.invocationName }).joined(separator: ", ")
  }()
  
  lazy var isVariadicMethod: Bool = {
    return method.parameters.contains(where: { $0.attributes.contains(.variadic) })
  }()
}

private extension MethodParameter {
  func mockableTypeName(in context: MethodTemplate, forClosure: Bool) -> String {
    let rawTypeName = context.context.specializeTypeName(self.typeName)
    
    // When the type names are used for invocations instead of declaring the method parameters.
    guard forClosure else {
      return "\(rawTypeName)"
    }
    
    let typeName = rawTypeName.removingImplicitlyUnwrappedOptionals()
    if attributes.contains(.variadic) {
      return "[\(typeName.dropLast(3))]"
    } else {
      return "\(typeName)"
    }
  }
  
  var invocationName: String {
    let inoutAttribute = attributes.contains(.inout) ? "&" : ""
    let autoclosureForwarding = attributes.contains(.autoclosure) ? "()" : ""
    return "\(inoutAttribute)`\(name)`\(autoclosureForwarding)"
  }
  
  func matchableTypeName(in context: MethodTemplate) -> String {
    let typeName = context.context.specializeTypeName(self.typeName).removingParameterAttributes()
    if attributes.contains(.variadic) {
      return "[" + typeName + "]"
    } else {
      return typeName
    }
  }
}
