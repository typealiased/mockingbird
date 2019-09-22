//
//  MockGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/6/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation

private enum Constants {
  static let mockProtocolName = "Mockingbird.Mock"
  static let equatableConformanceTypes: Set<String> = [
    "Equatable",
    "Comparable",
    "Hashable",
  ]
  static let codableConformanceTypes: Set<String> = [
    "Codable",
    "Encodable",
    "Decodable",
  ]
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
  private var methodTemplates = [Method: MethodTemplate]()
  init(mockableType: MockableType) {
    self.mockableType = mockableType
  }
  
  func methodTemplate(for method: Method) -> MethodTemplate {
    if let existing = methodTemplates[method] { return existing }
    let template = MethodTemplate(method: method, context: self)
    methodTemplates[method] = template
    return template
  }
  
  func render() -> String {
    let (start, end) = compilationDirectiveDeclaration
    let preprocessorStart = start.isEmpty ? "" : "\n\(start)\n"
    let preprocessorEnd = end.isEmpty ? "" : "\n\n\(end)"
    return """
    // MARK: - Mocked \(mockableType.name)
    \(preprocessorStart)
    public final class \(mockableType.name)Mock\(allSpecializedGenericTypes): \(allInheritedTypes)\(allGenericConstraints) {
    \(staticMockingContext)
      public let mockingContext = Mockingbird.MockingContext()
      public let stubbingContext = Mockingbird.StubbingContext()
      public let mockMetadata = Mockingbird.MockMetadata(["generator_version": "\(mockingbirdVersion.shortString)", "module_name": "\(mockableType.moduleName)"])
      public var sourceLocation: Mockingbird.SourceLocation? {
        get { return stubbingContext.sourceLocation }
        set {
          stubbingContext.sourceLocation = newValue
          \(mockableType.name)Mock.staticMock.stubbingContext.sourceLocation = newValue
        }
      }
    
    \(renderBody())
    }\(preprocessorEnd)
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
  
  /// The static mocking context allows static (or class) declared methods to be mocked.
  var staticMockingContext: String {
    guard !mockableType.genericTypes.isEmpty else { return "  static let staticMock = Mockingbird.StaticMock()" }
    // Since class-level generic types don't support static variables, we instead use a global
    // variable `genericTypesStaticMocks` that maps a runtime generated `staticMockIdentifier` to a
    // `StaticMock` instance.
    return """
      static var staticMock: Mockingbird.StaticMock {
        let runtimeGenericTypeNames = \(runtimeGenericTypeNames)
        let staticMockIdentifier = "\(mockableType.name)Mock\(allSpecializedGenericTypes)," + runtimeGenericTypeNames
        if let staticMock = genericTypesStaticMocks.value[staticMockIdentifier] { return staticMock }
        let staticMock = Mockingbird.StaticMock()
        genericTypesStaticMocks.update { $0[staticMockIdentifier] = staticMock }
        return staticMock
      }
    """
  }
  
  lazy var runtimeGenericTypeNames: String = {
    let genericTypeSelfNames = mockableType.genericTypes
      .map({ "\"\\(\($0.name).self)\"" })
      .joined(separator: ", ")
    return "[\(genericTypeSelfNames)].joined(separator: \",\")"
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
      .map({ specializeTypeName("\($0)") }).joined(separator: ", ")
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
  func createScopedName(with containingTypeNames: [String], suffix: String = "") -> String {
    guard mockableType.kind == .class else { // Protocols can't be nested
      return mockableType.name + suffix + (!suffix.isEmpty ? allGenericTypes : "")
    }
    guard mockableType.isContainedType else {
      return "\(mockableType.name)\(suffix)\(allGenericTypes)"
    }
    let containingTypeNames = containingTypeNames.map({ $0 + suffix }).joined(separator: ".")
      + (containingTypeNames.isEmpty ? "" : ".")
    return "\(containingTypeNames)\(mockableType.name)\(suffix)\(allGenericTypes)"
  }
  
  var inheritedTypes: [String] {
    var types = [fullyQualifiedName]
    if mockableType.kind != .class && mockableType.hasOpaqueInheritedType {
      // Default to subclassing `NSObject` in order to satisfy what could be an `NSObjectProtocol`
      // conformance (since the inheritance is at least partially opaque).
      types.insert("Foundation.NSObject", at: 0)
    }
    let conformanceTypes = mockableType.selfConformanceTypes
      .map({ $0.moduleName + "." + $0.name })
      .sorted()
    return types + conformanceTypes
  }
  
  func renderBody() -> String {
    return [renderInitializerProxy(),
            renderVariables(),
            defaultInitializer,
            renderMethods(),
            renderContainedTypes()]
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  func renderContainedTypes() -> String {
    guard !mockableType.containedTypes.isEmpty else { return "" }
    let containedTypesSubstructure = mockableType.containedTypes
      .map({ MockableTypeTemplate(mockableType: $0).render().indent() })
    return containedTypesSubstructure.joined(separator: "\n\n")
  }
  
  func renderInitializerProxy() -> String {
    let isProxyable: (Method) -> Bool = {
      // This needs to be a designated initializer since if it's a convenience initializer, we can't
      // always infer what concrete argument values to pass to the designated initializer.
      $0.isDesignatedInitializer
    }
    guard !shouldGenerateDefaultInitializer else { return "" }
    let initializers = mockableType.methods
      .filter(isProxyable)
      .sorted()
      .map({ methodTemplate(for: $0).classInitializerProxy })
    
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
  
  var equatableConformance: Method? {
    guard mockableType.kind == .protocol && (mockableType.hasOpaqueInheritedType
      || mockableType.inheritedTypes.contains(where: {
        Constants.equatableConformanceTypes.contains($0.name)
      })) else { return nil }
    return Method.createEquatableConformance(for: mockableType)
  }
  
  var comparableConformance: Method? {
    guard mockableType.kind == .protocol && (mockableType.hasOpaqueInheritedType
      || mockableType.inheritedTypes.contains(where: { $0.name == "Comparable" }))
      else { return nil }
    return Method.createComparableConformance(for: mockableType)
  }
  
  var hashableConformance: Method? {
    guard mockableType.kind == .protocol
      && mockableType.inheritedTypes.contains(where: { $0.name == "Hashable" })
      else { return nil }
    return Method.createHashableConformance()
  }
  
  var encodableConformance: Method? {
    guard mockableType.kind == .protocol && (mockableType.hasOpaqueInheritedType ||
      mockableType.inheritedTypes.contains(where: {
        $0.name == "Encodable" || $0.name == "Codable"
      }))
      else { return nil }
    return Method.createEncodableConformance()
  }
  
  var decodableConformance: Method? {
    guard mockableType.kind == .protocol && (mockableType.hasOpaqueInheritedType ||
      mockableType.inheritedTypes.contains(where: {
        $0.name == "Decodable" || $0.name == "Codable"
      }))
      else { return nil }
    return Method.createDecodableConformance()
  }
  
  /// For automatic UIView conformance.
  var codableViewConformance: Method? {
    guard mockableType.kind == .protocol && mockableType.hasOpaqueInheritedType else { return nil }
    return Method.createCodableViewConformance()
  }
  
  /// Store the source location of where the mock was initialized. This allows XCTest errors from
  /// unstubbed method invocations to show up in the testing code.
  var shouldGenerateDefaultInitializer: Bool {
    return mockableType.kind == .protocol || (!mockableType.hasOpaqueInheritedType &&
      !mockableType.methods.contains(where: { $0.isDesignatedInitializer }))
  }
  var defaultInitializer: String {
    guard shouldGenerateDefaultInitializer else { return "" }
    let superInit = mockableType.kind == .class
      || (mockableType.kind == .protocol && mockableType.hasOpaqueInheritedType)
      ? "super.init()\n    " : ""
    return """
      fileprivate init(sourceLocation: Mockingbird.SourceLocation) {
        \(superInit)Mockingbird.checkVersion(for: self)
        self.sourceLocation = sourceLocation
      }
    """
  }
  
  func renderVariables() -> String {
    return mockableType.variables
      .sorted(by: <)
      .map({ VariableTemplate(variable: $0, context: self).render() })
      .joined(separator: "\n\n")
  }
  
  func renderMethods() -> String {
    let inferredMethods = [equatableConformance,
                           comparableConformance,
                           hashableConformance,
                           encodableConformance,
                           decodableConformance,
                           codableViewConformance].compactMap({ $0 })
    return Set(inferredMethods + mockableType.methods)
      .sorted(by: <)
      .filter({ method -> Bool in
        // Not possible to override overloaded methods where uniqueness is from generic constraints.
        // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
        guard mockableType.kind == .class else { return true }
        guard !method.whereClauses.isEmpty else { return true }
        return mockableType.methodsCount[Method.Reduced(from: method)] == 1
      })
      .map({ methodTemplate(for: $0).render() })
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  func specializeTypeName(_ typeName: String) -> String {
    guard typeName.contains(SerializationRequest.Constants.selfTokenIndicator) else {
      return typeName // Checking prior to running `replacingOccurrences` is 4x faster.
    }
    return typeName
      .replacingOccurrences(of: SerializationRequest.Constants.selfToken,
                            with: mockableType.name + "Mock")
  }
}
