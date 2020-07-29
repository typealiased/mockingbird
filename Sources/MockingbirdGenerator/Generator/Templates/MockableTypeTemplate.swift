//
//  MockGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/6/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation

enum Declaration: String, CustomStringConvertible {
  case functionDeclaration = "Mockingbird.FunctionDeclaration"
  case throwingFunctionDeclaration = "Mockingbird.ThrowingFunctionDeclaration"
  
  case propertyGetterDeclaration = "Mockingbird.PropertyGetterDeclaration"
  case propertySetterDeclaration = "Mockingbird.PropertySetterDeclaration"
  
  case subscriptGetterDeclaration = "Mockingbird.SubscriptGetterDeclaration"
  case subscriptSetterDeclaration = "Mockingbird.SubscriptSetterDeclaration"
  
  var description: String { return rawValue }
}

extension GenericType {
  var flattenedDeclaration: String {
    guard !constraints.isEmpty else { return name }
    let flattenedInheritedTypes = constraints.sorted().joined(separator: " & ")
    return "\(name): \(flattenedInheritedTypes)"
  }
}

/// Renders a `MockableType` to a `PartialFileContent` object.
class MockableTypeTemplate: Template {
  let mockableType: MockableType
  let mockedTypeNames: Set<String>?
  
  enum Constants {
    static let mockProtocolName = "Mockingbird.Mock"
    static let thunkStub = #"fatalError("See 'Thunk Stubs' in the README")"#
  }
  
  private var methodTemplates = [Method: MethodTemplate]()
  init(mockableType: MockableType, mockedTypeNames: Set<String>?) {
    self.mockableType = mockableType
    self.mockedTypeNames = mockedTypeNames
  }
  
  func methodTemplate(for method: Method) -> MethodTemplate {
    if let existing = methodTemplates[method] { return existing }
    let template: MethodTemplate
    if method.isInitializer {
      template = InitializerMethodTemplate(method: method, context: self)
    } else if method.kind == .functionSubscript {
      template = SubscriptMethodTemplate(method: method, context: self)
    } else {
      template = MethodTemplate(method: method, context: self)
    }
    methodTemplates[method] = template
    return template
  }
  
  func render() -> String {
    let (directiveStart, directiveEnd) = compilationDirectiveDeclaration
    let header = directiveStart.isEmpty ? "" : "\n\(directiveStart)\n"
    let footer = directiveEnd.isEmpty ? "" : "\n\n\(directiveEnd)"
    
    let inheritance = !isAvailable ? Constants.mockProtocolName :
      "\(allInheritedTypes)\(allGenericConstraints)"
    
    let sourceLocationBody: String
    if shouldGenerateThunks {
      sourceLocationBody = """
      {
          get { return self.stubbingContext.sourceLocation }
          set {
            self.stubbingContext.sourceLocation = newValue
            \(mockableType.name)Mock.staticMock.stubbingContext.sourceLocation = newValue
          }
        }
      """
    } else {
      sourceLocationBody = "{ get { \(Constants.thunkStub) } set { \(Constants.thunkStub) } }"
    }
    
    let rawBody = renderBody()
    let body = rawBody.isEmpty ? "" : "\n\n\(rawBody)"
    
    return """
    // MARK: - Mocked \(mockableType.name)
    \(header)
    public final class \(mockableType.name)Mock\(allSpecializedGenericTypes): \(inheritance) {
    \(staticMockingContext)
      public let mockingContext = Mockingbird.MockingContext()
      public let stubbingContext = Mockingbird.StubbingContext()
      public let mockMetadata = Mockingbird.MockMetadata(["generator_version": "\(mockingbirdVersion.shortString)", "module_name": "\(mockableType.moduleName)"])
      public var sourceLocation: Mockingbird.SourceLocation? \(sourceLocationBody)\(body)
    }\(footer)
    """
  }
  
  lazy var compilationDirectiveDeclaration: (start: String, end: String) = {
    guard !mockableType.compilationDirectives.isEmpty else { return ("", "") }
    let start = mockableType.compilationDirectives
      .map({ $0.declaration })
      .joined(separator: "\n")
    let end = mockableType.compilationDirectives
      .map({ _ in "#endif" })
      .joined(separator: "\n")
    return (start, end)
  }()
  
  lazy var shouldGenerateThunks: Bool = {
    guard let typeNames = mockedTypeNames else { return true }
    return typeNames.contains(mockableType.fullyQualifiedName.removingGenericTyping()) ||
      typeNames.contains(mockableType.fullyQualifiedModuleName.removingGenericTyping())
  }()
  
  lazy var isAvailable: Bool = {
    return unavailableMockAttribute.isEmpty
  }()
  
  /// Protocols that inherit from opaque external types are considered not available as mocks
  /// because it's not possible to generate a well-formed concrete implementation unless the
  /// inheritance is trivial.
  var nonMockableOpaqueInheritanceMessage: String? {
    let hasCompleteInheritance = mockableType.kind != .protocol
      || mockableType.opaqueInheritedTypeNames.isEmpty
    guard !hasCompleteInheritance else { return nil }
    
    let opaqueTypeNames = mockableType.opaqueInheritedTypeNames.sorted()
    let allOpaqueTypeNames = opaqueTypeNames.enumerated().map({ (index, typeName) -> String in
      (index > 0 && index == opaqueTypeNames.count-1 ? "and " : "") + typeName.singleQuoted
    }).joined(separator: opaqueTypeNames.count > 2 ? ", " : " ")
    
    if opaqueTypeNames.count > 1 {
      return "\(mockableType.name.singleQuoted) inherits from the externally-defined types \(allOpaqueTypeNames) which needs to be declared in a supporting source file"
    } else {
      return "\(mockableType.name.singleQuoted) inherits from the externally-defined type \(allOpaqueTypeNames) which needs to be declared in a supporting source file"
    }
  }
  
  /// Cannot mock a type that inherits a type that isn't declared in the same module and isn't open.
  /// This mainly applies to protocols that have a Self constraint to a non-inheritable type.
  var nonMockableInheritedTypeMessage: String? {
    guard let nonInheritableType = mockableType.inheritedTypes
      .union(mockableType.selfConformanceTypes)
      .first(where: {
        $0.kind == .class && !$0.accessLevel.isInheritableType(withinSameModule: $0.shouldMock)
      })
      else { return nil }
    return "\(mockableType.name.singleQuoted) inherits from the non-open class \(nonInheritableType.name.singleQuoted) and cannot be mocked"
  }
  
  /// Protocols can inherit properties whose names conflict from other protocols, such that it is
  /// not possible to create a class that conforms to the child protocol.
  var nonMockablePropertiesMessage: String? {
    let duplicates = Dictionary(grouping: mockableType.variables, by: {Variable.Reduced(from: $0)})
      .mapValues({ $0.count })
      .filter({ $1 > 1 })
    guard !duplicates.isEmpty else { return nil }
    
    let allDuplicates = duplicates.keys
      .sorted(by: { $0.name < $1.name })
      .enumerated()
      .map({ (index, variable) -> String in
        (index > 0 && index == duplicates.count-1 ? "and " : "") + variable.name.singleQuoted
      })
      .joined(separator: duplicates.count > 2 ? ", " : " ")
    
    if duplicates.count > 1 {
      return "\(mockableType.name.singleQuoted) contains the properties \(allDuplicates) that each conflict with inherited declarations and cannot be mocked"
    } else {
      return "\(mockableType.name.singleQuoted) contains the property \(allDuplicates) that conflicts with an inherited declaration and cannot be mocked"
    }
  }
  
  /// Classes that define designated initializers but none which are accessible.
  var nonMockableDesignatedInitializerMessage: String? {
    guard mockableType.kind == .class, !shouldGenerateDefaultInitializer else { return nil }
    guard !mockableType.methods.contains(where: { $0.isDesignatedInitializer && $0.isMockable })
      else { return nil }
    return "\(mockableType.name.singleQuoted) does not declare any accessible designated initializers and cannot be mocked"
  }
  
  /// Classes that cannot be initialized due to imported accessibility from an external module.
  var nonMockableExternalInitializerMessage: String? {
    guard mockableType.kind == .class, mockableType.subclassesExternalType else { return nil }
    guard !mockableType.methods.contains(where: { $0.isInitializer && $0.isMockable })
      else { return nil }
    return "\(mockableType.name.singleQuoted) subclasses a type from a different module but does not declare any accessible initializers and cannot be mocked"
  }
  
  lazy var unavailableMockAttribute: String = {
    guard let message = nonMockableOpaqueInheritanceMessage
      ?? nonMockableInheritedTypeMessage
      ?? nonMockablePropertiesMessage
      ?? nonMockableDesignatedInitializerMessage
      ?? nonMockableExternalInitializerMessage
      else { return "" }
    
    logWarning(
      message,
      diagnostic: .notMockable,
      filePath: mockableType.filePath,
      line: self.mockableType.lineNumber
    )
    
    return """
    @available(*, unavailable, message: "\(message)")
    """
  }()
  
  /// The static mocking context allows static (or class) declared methods to be mocked.
  var staticMockingContext: String {
    guard !mockableType.genericTypes.isEmpty || mockableType.isInGenericContainingType
      else { return "  static let staticMock = Mockingbird.StaticMock()" }
    
    let body: String
    if shouldGenerateThunks {
      body = """
      {
          let runtimeGenericTypeNames: [String] = [\(runtimeGenericTypeNames)]
          let staticMockIdentifier: String = runtimeGenericTypeNames.joined(separator: ",")
          if let staticMock: Mockingbird.StaticMock = genericTypesStaticMocks.read({ $0[staticMockIdentifier] }) { return staticMock }
          let staticMock: Mockingbird.StaticMock = Mockingbird.StaticMock()
          genericTypesStaticMocks.update { $0[staticMockIdentifier] = staticMock }
          return staticMock
        }
      """
    } else {
      body = "{ \(Constants.thunkStub) }"
    }
    
    // Since class-level generic types don't support static variables, we instead use a global
    // variable `genericTypesStaticMocks` that maps a runtime generated `staticMockIdentifier` to a
    // `StaticMock` instance.
    return """
      static var staticMock: Mockingbird.StaticMock \(body)
    """
  }
  
  lazy var runtimeGenericTypeNames: String = {
    let baseTypeName = "\(mockableType.name)Mock\(allSpecializedGenericTypes)"
    let genericTypeSelfNames = mockableType.genericTypes
      .sorted(by: { $0.name < $1.name })
      .map({ "Swift.ObjectIdentifier(\($0.name).self).debugDescription" })
    return ([baseTypeName.doubleQuoted] + genericTypeSelfNames).joined(separator: ", ")
  }()
  
  lazy var allSpecializedGenericTypesList: [String] = {
    return mockableType.genericTypes.map({ $0.flattenedDeclaration })
  }()
  
  lazy var allSpecializedGenericTypes: String = {
    guard !mockableType.genericTypes.isEmpty else { return "" }
    return "<" + allSpecializedGenericTypesList.joined(separator: ", ") + ">"
  }()
  
  lazy var allGenericTypes: String = {
    guard !mockableType.genericTypes.isEmpty else { return "" }
    return "<" + mockableType.genericTypes.map({ $0.name }).joined(separator: ", ") + ">"
  }()
  
  lazy var allGenericConstraints: String = {
    guard !mockableType.whereClauses.isEmpty else { return "" }
    return " where " + mockableType.whereClauses
      .sorted().map({ specializeTypeName("\($0)") }).joined(separator: ", ")
  }()
  
  var allInheritedTypes: String {
    return (inheritedTypes + [Constants.mockProtocolName]).joined(separator: ", ")
  }
  
  /// For scoped types referenced within their containing type.
  lazy var fullyQualifiedName: String = {
    guard mockableType.kind == .class else {
      return "\(mockableType.moduleName).\(mockableType.name)"
    }
    guard !mockableType.isContainedType else { return "\(mockableType.name)\(allGenericTypes)" }
    return "\(mockableType.moduleName).\(mockableType.name)\(allGenericTypes)"
  }()
  
  /// For scoped types referenced at the top level but in the same module.
  func createScopedName(with containingTypeNames: [String],
                        genericTypeContext: [[String]],
                        suffix: String = "") -> String {
    guard mockableType.kind == .class else { // Protocols can't be nested
      return mockableType.name + suffix + (!suffix.isEmpty ? allGenericTypes : "")
    }
    guard mockableType.isContainedType else {
      return "\(mockableType.name)\(suffix)\(allGenericTypes)"
    }
    let containingTypeNames = containingTypeNames.enumerated()
      .map({ (index, typeName) in
        guard let genericTypeNames = genericTypeContext.get(index), !genericTypeNames.isEmpty
          else { return typeName + suffix }
        
        // Disambiguate generic types that shadow those defined by a containing type.
        let allGenericTypeNames = genericTypeNames
          .map({ typeName + "_" + $0 })
          .joined(separator: ", ")
        return typeName + suffix + "<" + allGenericTypeNames + ">"
      })
      .joined(separator: ".")
      + (containingTypeNames.isEmpty ? "" : ".")
    return "\(containingTypeNames)\(mockableType.name)\(suffix)\(allGenericTypes)"
  }
  
  lazy var protocolClassConformance: String? = {
    guard mockableType.kind == .protocol,
      let classConformance = mockableType.primarySelfConformanceTypeName
      else { return nil }
    
    // Handle class conformance constraints from where clauses.
    return classConformance
  }()
  
  var inheritedTypes: [String] {
    var types = [String]()
    if let protocolClassConformance = self.protocolClassConformance {
      types.append(protocolClassConformance)
    }
    types.append(fullyQualifiedName)
    
    let classConformanceTypeNames = Set(
      mockableType.selfConformanceTypes
        .filter({ $0.kind == .class })
        .map({ $0.fullyQualifiedModuleName })
    )
    let conformanceTypes = Set(mockableType.allSelfConformanceTypeNames)
      .subtracting(classConformanceTypeNames)
      .subtracting(types)
      .sorted()
    return types + conformanceTypes
  }
  
  func renderBody() -> String {
    let components: [String]
    if isAvailable {
      components = [renderInitializerProxy(),
                    renderVariables(),
                    defaultInitializer,
                    renderMethods(),
                    renderContainedTypes()]
    } else {
      components = [renderContainedTypes()]
    }
    return components.filter({ !$0.isEmpty }).joined(separator: "\n\n")
  }
  
  func renderContainedTypes() -> String {
    guard !mockableType.containedTypes.isEmpty else { return "" }
    let containedTypesSubstructure = mockableType.containedTypes
      .map({
        MockableTypeTemplate(mockableType: $0, mockedTypeNames: mockedTypeNames)
          .render().indent()
      })
    return containedTypesSubstructure.joined(separator: "\n\n")
  }
  
  func renderInitializerProxy() -> String {
    let isProxyable: (Method) -> Bool = {
      // This needs to be a designated initializer since if it's a convenience initializer, we can't
      // always infer what concrete argument values to pass to the designated initializer.
      $0.isDesignatedInitializer && $0.isMockable
    }
    
    guard !shouldGenerateDefaultInitializer else { return "" }
    let initializers = mockableType.methods
      .filter(isProxyable)
      .filter(isOverridable)
      .sorted()
      .compactMap({ methodTemplate(for: $0).classInitializerProxy?.indent(by: 2) })
    
    guard !initializers.isEmpty else {
      return """
        public enum InitializerProxy {}
      """
    }
    return """
      public enum InitializerProxy {
    \(initializers.joined(separator: "\n\n"))
      }
    """
  }
  
  /// Store the source location of where the mock was initialized. This allows `XCTest` errors from
  /// unstubbed method invocations to show up in the testing code.
  var shouldGenerateDefaultInitializer: Bool {
    // Opaque types can have designated initializers we don't know about, so it's best to ignore.
    guard mockableType.opaqueInheritedTypeNames.isEmpty else {
      logWarning(
        "Unable to synthesize default initializer for \(mockableType.name.singleQuoted) which inherits from an external type not defined in a supporting source file",
        diagnostic: .undefinedType,
        filePath: mockableType.filePath,
        line: self.mockableType.lineNumber
      )
      return false
    }
    
    let hasDesignatedInitializer =
      mockableType.methods.contains(where: { $0.isDesignatedInitializer })
    
    guard mockableType.kind == .protocol else { // Handle classes.
      if hasDesignatedInitializer {
        log("Skipping default initializer generation for \(mockableType.name.singleQuoted) because it is a class with a designated initializer")
      }
      return !hasDesignatedInitializer
    }
    
    // We can always generate a default initializer for protocols without class conformance.
    guard protocolClassConformance != nil else { return true }
    
    // Ignore protocols conforming to a class with a designated initializer.
    guard !hasDesignatedInitializer else {
      log("Skipping default initializer generation for \(mockableType.name.singleQuoted) because it is a protocol conforming to a class with a designated initializer")
      return false
    }
    
    let isMockableClassConformance = mockableType.primarySelfConformanceType?.shouldMock ?? true
    if !isMockableClassConformance {
      logWarning(
        "\(mockableType.name.singleQuoted) conforms to a class without public initializers and cannot be initialized",
        diagnostic: .notMockable,
        filePath: mockableType.filePath,
        line: self.mockableType.lineNumber
      )
    }
    return isMockableClassConformance
  }
  var defaultInitializer: String {
    guard shouldGenerateDefaultInitializer else { return "" }
    let superInit = mockableType.kind == .class || protocolClassConformance != nil
      ? "super.init()\n    " : ""
    return """
      fileprivate init(sourceLocation: Mockingbird.SourceLocation) {
        \(superInit)Mockingbird.checkVersion(for: self)
        self.sourceLocation = sourceLocation
      }
    """
  }
  
  lazy var containsOverridableDesignatedInitializer: Bool = {
    return mockableType.methods.contains(where: {
      $0.isOverridable && $0.isDesignatedInitializer && $0.isMockable
    })
  }()
  
  func renderVariables() -> String {
    return mockableType.variables
      .sorted(by: <)
      .map({ VariableTemplate(variable: $0, context: self).render() })
      .joined(separator: "\n\n")
  }
  
  func isOverridable(method: Method) -> Bool {
    // Not possible to override overloaded methods where uniqueness is from generic constraints.
    // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
    // This is fixed in Swift 5.2, so non-overridable methods require compilation conditions.
    guard mockableType.kind == .class || mockableType.primarySelfConformanceType != nil
      else { return true }
    guard !method.whereClauses.isEmpty || !method.genericTypes.isEmpty else { return true }
    return mockableType.methodsCount[Method.Reduced(from: method)] == 1
  }
  
  func renderMethods() -> String {
    return Set(mockableType.methods)
      .sorted(by: <)
      .filter({ $0.isMockable })
      .map({
        let renderedMethod = methodTemplate(for: $0).render()
        guard !isOverridable(method: $0) else { return renderedMethod }
        return """
          #if swift(>=5.2)
        
        \(renderedMethod)
        
          #endif
        """
      })
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  func specializeTypeName(_ typeName: String) -> String {
    // NOTE: Checking for an indicator prior to running `replacingOccurrences` is 4x faster.
    let concreteMockTypeName = mockableType.name + "Mock"
    
    if typeName.contains(SerializationRequest.Constants.selfTokenIndicator) {
      return typeName.replacingOccurrences(of: SerializationRequest.Constants.selfToken,
                                           with: concreteMockTypeName)
    }
    
    if typeName.contains(SerializationRequest.Constants.syntheticSelfTokenIndicator) {
      return typeName.replacingOccurrences(of: SerializationRequest.Constants.syntheticSelfToken,
                                           with: concreteMockTypeName)
    }
    
    return typeName
  }
}
