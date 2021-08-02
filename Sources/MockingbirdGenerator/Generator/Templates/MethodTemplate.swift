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
    let start = String(lines: method.compilationDirectives.map({ $0.declaration }))
    let end = String(lines: method.compilationDirectives.map({ _ in "#endif" }))
    return (start, end)
  }
  
  var mockableScopedName: String {
    return context.createScopedName(with: [], genericTypeContext: [], suffix: "Mock")
  }
  
  var classInitializerProxy: String? { return nil }
  
  var mockedDeclarations: String {
    let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
      ThunkTemplate(mockableType: context.mockableType,
                    invocation: mockableInvocation,
                    shortSignature: method.parameters.isEmpty ? nil : shortSignature,
                    longSignature: longSignature,
                    returnType: matchableReturnType,
                    isBridged: false,
                    isThrowing: method.isThrowing,
                    isStatic: method.kind.typeScope.isStatic,
                    callMember: { scope in
                      let scopedName = "\(scope).\(backticked: self.method.shortName)"
                      guard self.method.isVariadic else {
                        return FunctionCallTemplate(
                          name: scopedName,
                          arguments: self.invocationArguments,
                          isThrowing: self.method.isThrowing).render()
                      }
                      
                      // Variadic functions require casting since Swift doesn't support splatting.
                      let name = FunctionCallTemplate(
                        name: "Swift.unsafeBitCast",
                        arguments: [
                          (nil, "\(scopedName) as \(self.originalSignature)"),
                          ("to", "\(parenthetical: self.longSignature).self")])
                      return FunctionCallTemplate(
                        name: name.render(),
                        unlabeledArguments: self.invocationArguments.map({ $0.parameterName }),
                        isThrowing: self.method.isThrowing).render()
                    },
                    invocationArguments: invocationArguments).render()
    let declaration = "public \(overridableModifiers)func \(fullNameForMocking)\(returnTypeAttributesForMocking) -> \(mockableReturnType)"
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
    return "\(fullNameForMocking)\(returnTypeAttributesForMocking) -> \(mockableReturnType)\(genericConstraints)"
  }
  
  lazy var uniqueDeclaration: String = { return overridableUniqueDeclaration }()
  
  /// Methods synthesized specifically for the stubbing and verification APIs.
  var synthesizedDeclarations: String {
    let invocationType = "(\(separated: matchableParameterTypes)) \(returnTypeAttributesForMatching)-> \(matchableReturnType)"
    
    var methods = [String]()
    let genericTypes = [declarationTypeForMocking, invocationType, matchableReturnType]
    let returnType = "Mockingbird.Mockable<\(separated: genericTypes)>"
    
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
    if method.isVariadic {
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
    let `static` = method.kind.typeScope.isStatic ? "static " : ""
    return "\(required)\(override)\(`static`)"
  }
  
  lazy var genericTypes: [String] = {
    return method.genericTypes.map({ $0.flattenedDeclaration })
  }()
  
  lazy var genericConstraints: String = {
    guard !method.whereClauses.isEmpty else { return "" }
    return " where \(separated: method.whereClauses.map({ context.specializeTypeName("\($0)") }))"
  }()
  
  enum FunctionVariant {
    case function, subscriptGetter, subscriptSetter
    
    var isSubscript: Bool {
      switch self {
      case .function: return false
      case .subscriptGetter, .subscriptSetter: return true
      }
    }
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
    
    return genericTypes.isEmpty
      ? "\(escapedShortName)\(failable)"
      : "\(escapedShortName)\(failable)<\(separated: genericTypes)>"
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
      let closureType = mode.isMatching ? "@autoclosure () -> " : ""
      additionalParameters = ["`newValue`: \(closureType)\(matchableReturnType)"]
    } else {
      additionalParameters = []
    }
    
    let parameterNames = method.parameters.map({ parameter -> String in
      let typeName: String
      if mode.isMatching && (!mode.useVariadics || !parameter.attributes.contains(.variadic)) {
        typeName = "@autoclosure () -> \(parameter.matchableTypeName(in: self))"
      } else {
        typeName = parameter.mockableTypeName(context: self)
      }
      let argumentLabel = parameter.argumentLabel ?? "_"
      let parameterName = parameter.name.backtickWrapped
      if argumentLabel.backtickUnwrapped != parameter.name {
        return "\(argumentLabel) \(parameterName): \(typeName)"
      } else if mode.isMatching && mode.variant.isSubscript {
        // Synthesized declarations for subscripts don't use argument labels (unless the parameter
        // name differs) for parity with bracket syntax.
        return "_ \(parameterName): \(typeName)"
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
    
    return "\(shortName)(\(separated: parameterNames))"
  }
  
  lazy var mockableInvocation: String = {
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclaration)"),
        ("selectorType", "Mockingbird.SelectorType.method"),
        ("arguments", "[\(separated: mockArgumentMatchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: matchableReturnType).self)"),
      ]).render()
  }()
  
  func matchableInvocation(isVariadic: Bool = false) -> String {
    let matchers = isVariadic ? resolvedVariadicArgumentMatchers : resolvedArgumentMatchers
    return ObjectInitializationTemplate(
      name: "Mockingbird.SwiftInvocation",
      arguments: [
        ("selectorName", "\(doubleQuoted: uniqueDeclaration)"),
        ("selectorType", "Mockingbird.SelectorType.method"),
        ("arguments", "[\(matchers)]"),
        ("returnType", "Swift.ObjectIdentifier(\(parenthetical: matchableReturnType).self)"),
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
    return String(list: parameters.map({ (name, shouldResolve) in
      let type = shouldResolve ? "resolve" : "ArgumentMatcher"
      return "Mockingbird.\(type)(\(name.backtickWrapped))"
    }))
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
  
  lazy var mockArgumentMatchers: [String] = {
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
  
  lazy var mockObject: String = {
    return method.kind.typeScope.isStatic ? "self.staticMock" : "self"
  }()
  
  /// Original function signature for casting to a matchable signature (variadics support).
  lazy var originalSignature: String = {
    let modifiers = method.isThrowing ? " throws" : ""
    let parameterTypes = method.parameters.map({
      $0.matchableTypeName(context: self, bridgeVariadics: false)
    })
    return "(\(separated: parameterTypes))\(modifiers) -> \(matchableReturnType)"
  }()
  
  /// General function signature for matching.
  lazy var longSignature: String = {
    let modifiers = method.isThrowing ? " throws" : ""
    return "(\(separated: matchableParameterTypes))\(modifiers) -> \(matchableReturnType)"
  }()
  
  /// Convenience function signature for matching without any arguments.
  lazy var shortSignature: String = {
    let modifiers = method.isThrowing ? " throws" : ""
    return "()\(modifiers) -> \(matchableReturnType)"
  }()
  
  lazy var mockableReturnType: String = {
    return context.specializeTypeName(method.returnTypeName)
  }()
  
  lazy var matchableReturnType: String = {
    return mockableReturnType.removingImplicitlyUnwrappedOptionals()
  }()
  
  lazy var mockableParameterTypes: [String] = {
    return method.parameters.map({ $0.mockableTypeName(context: self) })
  }()
  
  lazy var matchableParameterTypes: [String] = {
    return method.parameters.map({ $0.matchableTypeName(context: self) })
  }()
  
  lazy var invocationArguments: [(argumentLabel: String?, parameterName: String)] = {
    return method.parameters.map({ ($0.argumentLabel, $0.parameterName) })
  }()
}

extension Method {
  var isThrowing: Bool {
    return attributes.contains(.throws) || attributes.contains(.rethrows)
  }
  
  var isVariadic: Bool {
    return parameters.contains(where: { $0.attributes.contains(.variadic) })
  }
}

private extension MethodParameter {
  func mockableTypeName(context: MethodTemplate) -> String {
    return context.context.specializeTypeName(self.typeName)
  }
  
  func matchableTypeName(context: MethodTemplate, bridgeVariadics: Bool = true) -> String {
    let rawTypeName = mockableTypeName(context: context)
    
    // Type names outside of function declarations differ slightly. Variadics and implicitly
    // unwrapped optionals must be sanitized.
    let typeName = rawTypeName.removingImplicitlyUnwrappedOptionals()
    if bridgeVariadics && attributes.contains(.variadic) {
      return "[\(typeName.dropLast(3))]"
    } else {
      return "\(typeName)"
    }
  }
  
  var parameterName: String {
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
