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
    let (directiveStart, directiveEnd) = compilationDirectiveDeclaration
    return String(lines: [
      directiveStart,
      String(lines: [mockedDeclarations, synthesizedDeclarations], spacing: 2),
      directiveEnd
    ])
  }
  
  enum Constants {
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
  
  var mockableScopedName: String {
    return context.createScopedName(with: [], genericTypeContext: [], suffix: "Mock")
  }
  
  var classInitializerProxy: String? { return nil }
  
  var mockedDeclarations: String {
    let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
      mockedImplementation()
    let declaration = "public \(overridableModifiers)func \(fullNameForMocking)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)"
    return String(lines: [
      "// MARK: Mocked \(fullNameForMocking)",
      FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                 declaration: declaration,
                                 genericConstraints: method.whereClauses.map({ context.specializeTypeName("\($0)") }),
                                 body: body).render(),
    ])
  }
  
  /// Declared in a class, or a class that the protocol conforms to.
  lazy var isClassBound: Bool = {
    let isClassDefinedProtocolConformance = context.protocolClassConformance != nil
      && method.isOverridable
    return context.mockableType.kind == .class || isClassDefinedProtocolConformance
  }()
  
  var overridableUniqueDeclaration: String {
    return "\(fullNameForMocking)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)\(genericConstraints)"
  }
  
  lazy var uniqueDeclaration: String = { return overridableUniqueDeclaration }()
  
  /// Methods synthesized specifically for the stubbing and verification APIs.
  var synthesizedDeclarations: String {
    let returnTypeName = unwrappedReturnTypeName
    let invocationType = "(\(methodParameterTypesForMatching)) \(returnTypeAttributesForMatching)-> \(returnTypeName)"
    
    var methods = [String]()
    let genericTypes = [declarationTypeForMocking, invocationType, returnTypeName]
    let returnType = "Mockingbird.Mockable<\(genericTypes.joined(separator: ", "))>"
    
    let declaration = "public \(regularModifiers)func \(fullNameForMatching) -> \(returnType)"
    let genericConstraints = method.whereClauses.map({ context.specializeTypeName("\($0)") })
    
    let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
    return \(ObjectInitializationTemplate(
              name: "Mockingbird.Mockable",
              genericTypes: genericTypes,
              arguments: [("mock", mockObject), ("invocation", matchableInvocation())]))
    """
    methods.append(
      FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                 declaration: declaration,
                                 genericConstraints: genericConstraints,
                                 body: body).render())
    
    // Variadics generate both the array and variadic-forms of the function signature to allow use
    // of either when stubbing and verifying.
    if isVariadicMethod {
      let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
      return \(ObjectInitializationTemplate(
                name: "Mockingbird.Mockable",
                genericTypes: genericTypes,
                arguments: [("mock", mockObject),
                            ("invocation", matchableInvocation(isVariadic: true))]))
      """
      let declaration = "public \(regularModifiers)func \(fullNameForMatchingVariadics) -> \(returnType)"
      methods.append(
        FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                   declaration: declaration,
                                   genericConstraints: genericConstraints,
                                   body: body).render())
    }
    
    return String(lines: methods, spacing: 2)
  }
  
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
  
  lazy var genericTypesList: [String] = {
    return method.genericTypes.map({ $0.flattenedDeclaration })
  }()
  
  lazy var genericTypes: String = {
    return genericTypesList.joined(separator: ", ")
  }()
  
  lazy var genericConstraints: String = {
    guard !method.whereClauses.isEmpty else { return "" }
    return " where " + method.whereClauses
      .map({ context.specializeTypeName("\($0)") }).joined(separator: ", ")
  }()
  
  enum FunctionVariant {
    case function, subscriptGetter, subscriptSetter
  }
  
  enum FullNameMode {
    case mocking(variant: FunctionVariant)
    case matching(useVariadics: Bool, variant: FunctionVariant)
    case initializerProxy
    
    var isMatching: Bool {
      switch self {
      case .matching: return true
      case .mocking, .initializerProxy: return false
      }
    }
    
    var isInitializerProxy: Bool {
      switch self {
      case .matching, .mocking: return false
      case .initializerProxy: return true
      }
    }
    
    var useVariadics: Bool {
      switch self {
      case .matching(let useVariadics, _): return useVariadics
      case .mocking, .initializerProxy: return false
      }
    }
    
    var variant: FunctionVariant {
      switch self {
      case .matching(_, let variant), .mocking(let variant): return variant
      case .initializerProxy: return .function
      }
    }
  }
  
  func shortName(for mode: FullNameMode) -> String {
    let failable: String
    if mode.isInitializerProxy {
      failable = ""
    } else if method.attributes.contains(.failable) {
      failable = "?"
    } else if method.attributes.contains(.unwrappedFailable) {
      failable = "!"
    } else {
      failable = ""
    }
    
    // Don't escape initializers, subscripts, and special functions with reserved tokens like `==`.
    let shouldEscape = !method.isInitializer
      && method.kind != .functionSubscript
      && (method.shortName.first?.isLetter == true
        || method.shortName.first?.isNumber == true
        || method.shortName.first == "_")
    let escapedShortName = mode.isInitializerProxy ? "initialize" :
      (shouldEscape ? method.shortName.backtickWrapped : method.shortName)
    
    let allGenericTypes = self.genericTypesList.joined(separator: ", ")
    
    return genericTypes.isEmpty ?
      "\(escapedShortName)\(failable)" : "\(escapedShortName)\(failable)<\(allGenericTypes)>"
  }
  
  lazy var fullNameForMocking: String = {
    return fullName(for: .mocking(variant: .function))
  }()
  lazy var fullNameForMatching: String = {
    return fullName(for: .matching(useVariadics: false, variant: .function))
  }()
  /// It's not possible to have an autoclosure with variadics. However, since a method can only have
  /// one variadic parameter, we can generate one method for wildcard matching using an argument
  /// matcher, and another for specific matching using variadics.
  lazy var fullNameForMatchingVariadics: String = {
    return fullName(for: .matching(useVariadics: true, variant: .function))
  }()
  func fullName(for mode: FullNameMode) -> String {
    let additionalParameters: [String]
    if mode.isInitializerProxy {
      additionalParameters = ["__file: StaticString = #file", "__line: UInt = #line"]
    } else if mode.variant == .subscriptSetter {
      let closureType = mode.isMatching ? "@escaping @autoclosure () -> " : ""
      additionalParameters = ["`newValue`: \(closureType)\(unwrappedReturnTypeName)"]
    } else {
      additionalParameters = []
    }
    
    let parameterNames = method.parameters.map({ parameter -> String in
      let typeName: String
      if mode.isMatching && (!mode.useVariadics || !parameter.attributes.contains(.variadic)) {
        typeName = "@escaping @autoclosure () -> \(parameter.matchableTypeName(in: self))"
      } else {
        typeName = parameter.mockableTypeName(in: self, forDeclaration: true)
      }
      let argumentLabel = parameter.argumentLabel?.backtickWrapped ?? "_"
      let parameterName = parameter.name.backtickWrapped
      if argumentLabel != parameterName {
        return "\(argumentLabel) \(parameterName): \(typeName)"
      } else {
        return "\(parameterName): \(typeName)"
      }
    }) + additionalParameters
    
    let actualShortName = shortName(for: mode)
    let shortName: String
    if mode.isMatching, let resolvedShortName = Constants.reservedNamesMap[actualShortName] {
      shortName = resolvedShortName
    } else {
      shortName = actualShortName
    }
    
    return "\(shortName)(\(parameterNames.joined(separator: ", ")))"
  }
  
  // It's necessary to override parts of the definition in certain cases like subscript setters.
  func mockedImplementation(parameterTypes: [String]? = nil,
                            invocation: String? = nil,
                            returnTypeName: String? = nil) -> String {
    let parameters: [(String, String)] =
      (parameterTypes ?? methodParameterTypesListForMatching).enumerated().map({
        (index, type) in
        return ("p\(index)", "\(parenthetical: type.removingParameterAttributes()).self")
      })
    let name = method.isThrowing ? "forwardThrowingSwiftInvocation" : "forwardSwiftInvocation"
    let forwardSwiftInvocation = FunctionCallTemplate(
      name: "\(contextPrefix)mockingbirdContext.\(name)",
      arguments: [(nil, invocation ?? mockableInvocation)] + parameters,
      isThrowing: method.isThrowing)
    // Returning for void return types is valid here and handled by the proxy API.
    return "\(!method.isInitializer ? "return " : "")\(forwardSwiftInvocation)"
  }
  
  lazy var callingContext: String = {
    let callType = "\(parenthetical: methodParameterTypesForMocking)\(method.isThrowing ? " throws" : "") -> \(unwrappedReturnTypeName)"
    let superCall = context.mockableType.kind != .class ? "nil" :
      "super.\(backticked: method.shortName) as \(callType)"
    let supertype = method.kind.typeScope.isStatic ?
      "MockingbirdSupertype.Type" : "MockingbirdSupertype"
    
    // Unable to specialize generic protocols for a proxy contexts.
    let isGenericProtocol = context.mockableType.kind == .protocol
      && !context.mockableType.genericTypes.isEmpty
    let proxyCall = isGenericProtocol ? "nil" : ClosureTemplate(
      body: "Mockingbird.CallingContext.createProxy($0, type: \(supertype).self) { $0.\(backticked: method.shortName) as \(callType) }").render()
    
    return ObjectInitializationTemplate(
      name: "Mockingbird.CallingContext",
      arguments: [("super", superCall), ("proxy", proxyCall)]
    ).render()
  }()
  
  lazy var mockableInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclaration)"),
        ("arguments", "[\(mockArgumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: unwrappedReturnTypeName).self)"),
        ("context", callingContext),
      ]).render()
  }()
  
  func matchableInvocation(isVariadic: Bool = false) -> String {
    let matchers = isVariadic ? resolvedVariadicArgumentMatchers : resolvedArgumentMatchers
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclaration)"),
        ("arguments", "[\(matchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: unwrappedReturnTypeName).self)"),
        ("context", callingContext),
      ]).render()
  }
  
  lazy var resolvedArgumentMatchers: String = {
    return self.resolvedArgumentMatchers(for: method.parameters.map({ ($0.name, true) }))
  }()
  
  /// Variadic parameters cannot be resolved indirectly using `resolve()`.
  lazy var resolvedVariadicArgumentMatchers: String = {
    let parameters = method.parameters.map({ ($0.name, !$0.attributes.contains(.variadic)) })
    return resolvedArgumentMatchers(for: parameters)
  }()
  
  /// Can create argument matchers via resolving (shouldResolve = true) or by direct initialization.
  func resolvedArgumentMatchers(for parameters: [(name: String, shouldResolve: Bool)]) -> String {
    return parameters.map({ (name, shouldResolve) in
      let type = shouldResolve ? "resolve" : "ArgumentMatcher"
      return "Mockingbird.\(type)(\(name.backtickWrapped))"
    }).joined(separator: ", ")
  }
  
  lazy var returnTypeAttributesForMocking: String = {
    if method.attributes.contains(.rethrows) { return " rethrows" }
    if method.attributes.contains(.throws) { return " throws" }
    return ""
  }()
  
  lazy var returnTypeAttributesForMatching: String = {
    return method.isThrowing ? "throws " : ""
  }()
  
  lazy var declarationTypeForMocking: String = {
    if method.attributes.contains(.throws) {
      return "\(Declaration.throwingFunctionDeclaration)"
    } else {
      return "\(Declaration.functionDeclaration)"
    }
  }()
  
  lazy var mockArgumentMatchersList: [String] = {
    return method.parameters.map({ parameter -> String in
      guard !parameter.isNonEscapingClosure else {
        // Can't save the argument in the invocation because it's a non-escaping closure type.
        return ObjectInitializationTemplate(
          name: "Mockingbird.ArgumentMatcher",
          arguments: [
            (nil, ObjectInitializationTemplate(
              name: "Mockingbird.NonEscapingClosure",
              genericTypes: [parameter.matchableTypeName(in: self)]).render())
          ]).render()
      }
      return ObjectInitializationTemplate(
        name: "Mockingbird.ArgumentMatcher",
        arguments: [(nil, "\(backticked: parameter.name)")]).render()
    })
  }()
  
  lazy var mockArgumentMatchers: String = {
    return mockArgumentMatchersList.joined(separator: ", ")
  }()
  
  lazy var mockObject: String = {
    return method.kind.typeScope == .static || method.kind.typeScope == .class
      ? "self.staticMock" : "self"
  }()
  
  lazy var contextPrefix: String = {
    return mockObject + "."
  }()
  
  lazy var specializedReturnTypeName: String = {
    return context.specializeTypeName(method.returnTypeName)
  }()
  
  lazy var unwrappedReturnTypeName: String = {
    return specializedReturnTypeName.removingImplicitlyUnwrappedOptionals()
  }()
  
  lazy var methodParameterTypesListForMocking: [String] = {
    return method.parameters.map({ $0.mockableTypeName(in: self, forDeclaration: true) })
  }()
  
  lazy var methodParameterTypesForMocking: String = {
    return methodParameterTypesListForMocking.joined(separator: ", ")
  }()
  
  lazy var methodParameterTypesListForMatching: [String] = {
    return method.parameters.map({ $0.mockableTypeName(in: self, forDeclaration: false) })
  }()
  
  lazy var methodParameterTypesForMatching: String = {
    return methodParameterTypesListForMatching.joined(separator: ", ")
  }()
  
  lazy var methodParameterNamesForInvocationList: [String] = {
    return method.parameters.map({ $0.invocationName })
  }()
  
  lazy var methodParameterNamesForInvocation: String = {
    return methodParameterNamesForInvocationList.joined(separator: ", ")
  }()
  
  lazy var isVariadicMethod: Bool = {
    return method.parameters.contains(where: { $0.attributes.contains(.variadic) })
  }()
}

extension Method {
  var isThrowing: Bool {
    return attributes.contains(.throws) || attributes.contains(.rethrows)
  }
}

private extension MethodParameter {
  func mockableTypeName(in context: MethodTemplate, forDeclaration: Bool) -> String {
    let rawTypeName = context.context.specializeTypeName(self.typeName)
    guard !forDeclaration else { return rawTypeName }
    
    // Type names outside of function declarations differ slightly. Variadics and implicitly
    // unwrapped optionals must be sanitized.
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
    return "\(inoutAttribute)\(name.backtickWrapped)\(autoclosureForwarding)"
  }
  
  func matchableTypeName(in context: MethodTemplate) -> String {
    let typeName = context.context.specializeTypeName(self.typeName).removingParameterAttributes()
    if attributes.contains(.variadic) {
      return "[" + typeName + "]"
    } else {
      return typeName
    }
  }
  
  var isNonEscapingClosure: Bool {
    return attributes.contains(.closure) && !attributes.contains(.escaping)
  }
}
