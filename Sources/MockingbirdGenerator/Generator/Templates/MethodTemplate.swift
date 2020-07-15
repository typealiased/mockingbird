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
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    
    let body: String
    if context.shouldGenerateThunks {
      body = """
      {
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [\(mockArgumentMatchers)], returnType: Swift.ObjectIdentifier((\(unwrappedReturnTypeName)).self))
      \(stubbedImplementationCall())
        }
      """
    } else {
      body = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
    }
    
    return """
      // MARK: Mocked \(fullNameForMocking)
    \(attributes)
      public \(overridableModifiers)func \(uniqueDeclaration) \(body)
    """
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
  
  var frameworkDeclarations: String {
    let attributes = declarationAttributes.isEmpty ? "" : "  \(declarationAttributes)\n"
    let returnTypeName = unwrappedReturnTypeName
    let invocationType = "(\(methodParameterTypes)) \(returnTypeAttributesForMatching)-> \(returnTypeName)"
    
    var mockableMethods = [String]()
    let mockableGenericTypes = [declarationTypeForMocking,
                                invocationType,
                                returnTypeName].joined(separator: ", ")
    
    let body: String
      
    if context.shouldGenerateThunks {
      body = """
      {
      \(matchableInvocation)
          return Mockingbird.Mockable<\(mockableGenericTypes)>(mock: \(mockObject), invocation: invocation)
        }
      """
    } else {
      body = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
    }
    
    mockableMethods.append("""
    \(attributes)  public \(regularModifiers)func \(fullNameForMatching) -> Mockingbird.Mockable<\(mockableGenericTypes)>\(genericConstraints) \(body)
    """)
    
    // Allow methods with a variadic parameter to use variadics when stubbing.
    if isVariadicMethod {
      let variadicBody: String
      if context.shouldGenerateThunks {
        variadicBody = """
        {
        \(resolvedVariadicArgumentMatchers)
            let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: arguments, returnType: Swift.ObjectIdentifier((\(unwrappedReturnTypeName)).self))
            return Mockingbird.Mockable<\(mockableGenericTypes)>(mock: \(mockObject), invocation: invocation)
          }
        """
      } else {
        variadicBody = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
      }
      mockableMethods.append("""
      \(attributes)  public \(regularModifiers)func \(fullNameForMatchingVariadics) -> Mockingbird.Mockable<\(mockableGenericTypes)>\(genericConstraints) \(variadicBody)
      """)
    }
    
    return mockableMethods.joined(separator: "\n\n")
  }

  lazy var declarationAttributes: String = {
    return method.attributes.safeDeclarations.joined(separator: " ")
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
        typeName = parameter.mockableTypeName(in: self, forClosure: false)
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
  
  lazy var superCallParameters: String = {
    return method.parameters.map({ parameter -> String in
      guard let label = parameter.argumentLabel else { return parameter.name.backtickWrapped }
      return "\(label): \(parameter.name.backtickWrapped)"
    }).joined(separator: ", ")
  }()
  
  // In certain cases, e.g. subscript setters, it's necessary to override parts of the definition.
  func stubbedImplementationCall(parameterTypes: String? = nil,
                                 parameterNames: String? = nil,
                                 returnTypeName: String? = nil) -> String {
    let returnTypeName = returnTypeName ?? unwrappedReturnTypeName
    let shouldReturn = !method.isInitializer && returnTypeName != "Void"
    let returnStatement = !shouldReturn ? "" : "return "
    let returnExpression = !shouldReturn ? "" : """
     else if let defaultValue = \(contextPrefix)stubbingContext.defaultValueProvider.provideValue(for: (\(returnTypeName)).self) {
            \(returnStatement)defaultValue
          } else {
            fatalError(\(contextPrefix)stubbingContext.failTest(for: invocation))
          }
    """
    
    let parameterTypes = parameterTypes ?? methodParameterTypes
    let parameterNames = parameterNames ?? methodParameterNamesForInvocation
    let implementationType = "(\(parameterTypes)) \(returnTypeAttributesForMatching)-> \(returnTypeName)"
    let noArgsImplementationType = "() \(returnTypeAttributesForMatching)-> \(returnTypeName)"
    let noArgsImplementation = method.parameters.isEmpty ? "" : """
     else if let concreteImplementation = implementation as? \(noArgsImplementationType) {
            \(returnStatement)\(tryInvocation)concreteImplementation()
          }
    """
    
    // 1. Stubbed implementation with args
    // 2. Stubbed implementation without args
    // 3. Fakeable default value fallback
    return """
        \(returnStatement)\(tryInvocation)\(contextPrefix)mockingContext.didInvoke(invocation) { () -> \(returnTypeName) in
          let implementation = \(contextPrefix)stubbingContext.implementation(for: invocation)
          if let concreteImplementation = implementation as? \(implementationType) {
            \(returnStatement)\(tryInvocation)concreteImplementation(\(parameterNames))
          }\(noArgsImplementation)\(returnExpression)
        }
    """
  }
  
  lazy var matchableInvocation: String = {
    guard !method.parameters.isEmpty else {
      return """
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [], returnType: Swift.ObjectIdentifier((\(unwrappedReturnTypeName)).self))
      """
    }
    return """
    \(resolvedArgumentMatchers)
        let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: arguments, returnType: Swift.ObjectIdentifier((\(unwrappedReturnTypeName)).self))
    """
  }()
  
  lazy var resolvedArgumentMatchers: String = {
    return self.resolvedArgumentMatchers(for: method.parameters.map({ ($0.name, true) }))
  }()
  
  lazy var resolvedArgumentMatchersForSubscriptSetter: String = {
    let parameters = method.parameters.map({ ($0.name, true) }) + [("newValue", true)]
    return resolvedArgumentMatchers(for: parameters)
  }()
  
  /// Variadic parameters cannot be resolved indirectly using `resolve()`.
  lazy var resolvedVariadicArgumentMatchers: String = {
    let parameters = method.parameters.map({ ($0.name, !$0.attributes.contains(.variadic)) })
    return resolvedArgumentMatchers(for: parameters)
  }()
  
  lazy var resolvedVariadicArgumentMatchersForSubscriptSetter: String = {
    let parameters = method.parameters.map({ ($0.name, !$0.attributes.contains(.variadic)) })
      + [("newValue", true)]
    return resolvedArgumentMatchers(for: parameters)
  }()
  
  /// Can create argument matchers via resolving (shouldResolve = true) or by direct initialization.
  func resolvedArgumentMatchers(for parameters: [(name: String, shouldResolve: Bool)]) -> String {
    let resolved = parameters.map({ (name, shouldResolve) in
      let type = shouldResolve ? "resolve" : "ArgumentMatcher"
      return "Mockingbird.\(type)(\(name.backtickWrapped))"
    }).joined(separator: ", ")
    return "    let arguments: [Mockingbird.ArgumentMatcher] = [\(resolved)]"
  }
  
  lazy var tryInvocation: String = {
    return !returnTypeAttributesForMatching.isEmpty ? "try " : ""
  }()
  
  lazy var returnTypeAttributesForMocking: String = {
    if method.attributes.contains(.rethrows) { return " rethrows" }
    if method.attributes.contains(.throws) { return " throws" }
    return ""
  }()
  
  lazy var returnTypeAttributesForMatching: String = {
    if method.attributes.contains(.throws) || method.attributes.contains(.rethrows) {
      return "throws "
    } else {
      return ""
    }
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
      // Can't save the argument in the invocation because it's a non-escaping parameter.
      guard !parameter.attributes.contains(.closure) || parameter.attributes.contains(.escaping) else {
        return "Mockingbird.ArgumentMatcher(Mockingbird.NonEscapingClosure<\(parameter.matchableTypeName(in: self))>())"
      }
      return "Mockingbird.ArgumentMatcher(\(parameter.name.backtickWrapped))"
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
  
  lazy var methodParameterTypesList: [String] = {
    return method.parameters.map({ $0.mockableTypeName(in: self, forClosure: true) })
  }()
  
  lazy var methodParameterTypes: String = {
    return methodParameterTypesList.joined(separator: ", ")
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
}
