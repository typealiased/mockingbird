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
    let flattenedInheritedTypes = String(list: constraints.sorted(), separator: " & ")
    return "\(name): \(flattenedInheritedTypes)"
  }
}

extension MockableType {
  func isReferenced(by typeNames: Set<String>) -> Bool {
    return typeNames.contains(fullyQualifiedName.removingGenericTyping())
        || typeNames.contains(fullyQualifiedModuleName.removingGenericTyping())
  }
}

/// Renders a `MockableType` to a `PartialFileContent` object.
class MockableTypeTemplate: Template {
  let mockableType: MockableType
  let mockedTypeNames: Set<String>?
  
  enum Constants {
    static let mockProtocolName = "Mockingbird.Mock"
    static let thunkStub = #"fatalError("See 'Thunk Pruning' in the README")"#
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
    return String(lines: [
      "// MARK: - Mocked \(mockableType.name)",
      directiveStart,
      NominalTypeDefinitionTemplate(
        declaration: "public final class \(mockableType.name)Mock",
        genericTypes: genericTypes,
        genericConstraints: mockableType.whereClauses.sorted().map({ specializeTypeName("\($0)") }),
        inheritedTypes: (isAvailable ? inheritedTypes : []) + [Constants.mockProtocolName],
        body: renderBody()).render(),
      directiveEnd,
    ])
  }
  
  lazy var compilationDirectiveDeclaration: (start: String, end: String) = {
    guard !mockableType.compilationDirectives.isEmpty else { return ("", "") }
    let start = String(lines: mockableType.compilationDirectives.map({ $0.declaration }))
    let end = String(lines: mockableType.compilationDirectives.map({ _ in "#endif" }))
    return (start, end)
  }()
  
  lazy var shouldGenerateThunks: Bool = {
    guard let typeNames = mockedTypeNames else { return true }
    return mockableType.isReferenced(by: typeNames)
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
  
  /// The static mocking context allows static or class methods to be mocked.
  var staticMockingContext: String {
    if !mockableType.genericTypes.isEmpty || mockableType.isInGenericContainingType {
      // Class-level generic types don't support static variables directly.
      let body = !shouldGenerateThunks ? Constants.thunkStub :
        "return genericStaticMockContext.resolveTypeNames([\(runtimeGenericTypeNames)])"
      return """
      static var staticMock: Mockingbird.StaticMock \(BlockTemplate(body: body, multiline: false))
      """
    } else {
      return "static let staticMock = Mockingbird.StaticMock()"
    }
  }
  
  lazy var runtimeGenericTypeNames: String = {
    let baseTypeName = "\(mockableType.name)Mock\(allGenericTypes)"
    let genericTypeSelfNames = mockableType.genericTypes
      .sorted(by: { $0.name < $1.name })
      .map({ "Swift.ObjectIdentifier(\($0.name).self).debugDescription" })
    return String(list: [baseTypeName.doubleQuoted] + genericTypeSelfNames)
  }()
  
  lazy var genericTypes: [String] = {
    return mockableType.genericTypes.map({ $0.flattenedDeclaration })
  }()
  
  lazy var allGenericTypes: String = {
    guard !mockableType.genericTypes.isEmpty else { return "" }
    return "<\(separated: mockableType.genericTypes.map({ $0.name }))>"
  }()
  
  var allInheritedTypes: String {
    return String(list: inheritedTypes + [Constants.mockProtocolName])
  }
  
  /// For scoped types referenced within their containing type.
  lazy var fullyQualifiedName: String = {
    guard mockableType.kind == .class, mockableType.isContainedType else {
      return mockableType.fullyQualifiedModuleName
    }
    return "\(mockableType.name)\(allGenericTypes)"
  }()
  
  /// For scoped types referenced at the top level but in the same module.
  func createScopedName(with containingTypeNames: [String],
                        genericTypeContext: [[String]],
                        suffix: String = "",
                        moduleQualified: Bool = false) -> String {
    let name = moduleQualified ?
      mockableType.fullyQualifiedModuleName.removingGenericTyping() : mockableType.name
    guard mockableType.kind == .class else { // Protocols can't be nested
      return name + suffix + (!suffix.isEmpty ? allGenericTypes : "")
    }
    guard mockableType.isContainedType else {
      return name + suffix + allGenericTypes
    }
    
    let typeNames = containingTypeNames.enumerated()
      .map({ (index, typeName) -> String in
        guard let genericTypeNames = genericTypeContext.get(index), !genericTypeNames.isEmpty else {
          return typeName + suffix
        }
        // Disambiguate generic types that shadow those defined by a containing type.
        return typeName + suffix + "<\(separated: genericTypeNames.map({ typeName + "_" + $0 }))>"
      })
      + [mockableType.name + suffix + allGenericTypes]
    
    if moduleQualified && mockableType.fullyQualifiedName != mockableType.fullyQualifiedModuleName {
      return String(list: [mockableType.moduleName] + typeNames, separator: ".")
    } else {
      return String(list: typeNames, separator: ".")
    }
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
    let supertypeDeclaration = "typealias MockingbirdSupertype = \(fullyQualifiedName)"
    let mockingbirdContext = """
    public let mockingbirdContext = Mockingbird.Context(["generator_version": "\(mockingbirdVersion.shortString)", "module_name": "\(mockableType.moduleName)"])
    """
    
    var components = [String(lines: [
      // Type declarations
      supertypeDeclaration,
      
      // Properties
      staticMockingContext,
      mockingbirdContext,
    ])]
    
    if isAvailable {
      components.append(contentsOf: [
        renderInitializerProxy(),
        renderVariables(),
        defaultInitializer,
        renderMethods(),
        renderContainedTypes()
      ])
    } else {
      components.append(renderContainedTypes())
    }
    
    return String(lines: components, spacing: 2)
  }
  
  func renderContainedTypes() -> String {
    guard !mockableType.containedTypes.isEmpty else { return "" }
    let containedTypesSubstructure = mockableType.containedTypes
      .map({
        MockableTypeTemplate(mockableType: $0, mockedTypeNames: mockedTypeNames)
          .render().indent()
      })
    return String(lines: containedTypesSubstructure, spacing: 2)
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
      .compactMap({ methodTemplate(for: $0).classInitializerProxy })
    
    guard !initializers.isEmpty else {
      return "public enum InitializerProxy {}"
    }
    return NominalTypeDefinitionTemplate(declaration: "public enum InitializerProxy",
                                         body: String(lines: initializers, spacing: 2)).render()
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
    let canCallSuper = mockableType.kind == .class || protocolClassConformance != nil
    return FunctionDefinitionTemplate(
      declaration: "fileprivate init(sourceLocation: Mockingbird.SourceLocation)",
      body: String(lines: [
        canCallSuper ? "super.init()" : "",
        "self.mockingbirdContext.sourceLocation = sourceLocation",
        "\(mockableType.name)Mock.staticMock.mockingbirdContext.sourceLocation = sourceLocation",
      ])).render()
  }
  
  lazy var containsOverridableDesignatedInitializer: Bool = {
    return mockableType.methods.contains(where: {
      $0.isOverridable && $0.isDesignatedInitializer && $0.isMockable
    })
  }()
  
  func renderVariables() -> String {
    return String(lines: mockableType.variables.sorted(by: <).map({
      VariableTemplate(variable: $0, context: self).render()
    }), spacing: 2)
  }
  
  func isOverridable(method: Method) -> Bool {
    let isClassMock = mockableType.kind == .class || mockableType.primarySelfConformanceType != nil
    let isGeneric = !method.whereClauses.isEmpty || !method.genericTypes.isEmpty
    guard isClassMock, isGeneric else { return true }
    
    // Not possible to override overloaded methods where uniqueness is from generic constraints.
    // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
    // This is fixed in Swift 5.2, so non-overridable methods require compilation conditions.
    return mockableType.methodsCount[Method.Reduced(from: method)] == 1
  }
  
  func renderMethods() -> String {
    return String(lines: Set(mockableType.methods).sorted(by: <).filter({ $0.isMockable }).map({
      let renderedMethod = methodTemplate(for: $0).render()
      guard !isOverridable(method: $0) else { return renderedMethod }
      return String(lines: [
        "#if swift(>=5.2)",
        renderedMethod,
        "#endif",
      ])
    }), spacing: 2)
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
