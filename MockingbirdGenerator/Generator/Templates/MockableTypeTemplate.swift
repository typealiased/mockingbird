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
  /// A heuristic set of class prefixes used by system frameworks requiring NSObjectProtocol
  /// conformance. In the future, we want to mock Obj-C classes and system frameworks instead.
  static let objectProtocolPrefixes = Set(["NS", "CB", "UI"])
  static let mockProtocolName = "Mockingbird.Mock"
}

extension GenericType {
  var flattenedDeclaration: String {
    guard !constraints.isEmpty else { return name }
    let flattenedInheritedTypes = Array(constraints).joined(separator: " & ")
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
  
  @inlinable
  func methodTemplate(for method: Method) -> MethodTemplate {
    if let existing = methodTemplates[method] { return existing }
    let template = MethodTemplate(method: method, context: self)
    methodTemplates[method] = template
    return template
  }
  
  func render() -> String {
    return """
    // MARK: - Mocked \(mockableType.name)
    
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
    }
    """
  }
  
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
        if let staticMock = genericTypesStaticMocks.value[staticMockIdentifier] {
          return staticMock
        }
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
    guard !mockableType.genericConstraints.isEmpty else { return "" }
    return " where " + mockableType.genericConstraints.joined(separator: ", ")
  }()
  
  var allInheritedTypes: String {
    return [subclass,
            inheritedProtocol,
            Constants.mockProtocolName]
      .compactMap({ $0 })
      .joined(separator: ", ")
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
  
  var subclass: String? {
    guard mockableType.kind != .class else { return fullyQualifiedName }
    let prefix = String(mockableType.name.prefix(2))
    if Constants.objectProtocolPrefixes.contains(prefix) {
      return "NSObject"
    } else {
      return nil
    }
  }
  
  var inheritedProtocol: String? {
    guard mockableType.kind == .protocol else { return nil }
    return fullyQualifiedName
  }
  
  func renderBody() -> String {
    return [renderInitializerProxy(),
            renderVariables(),
            equatableConformance,
            codeableInitializer,
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
      // We can't usually infer what concrete arguments to pass to the designated initializer.
      $0.isInitializer && !$0.attributes.contains(.convenience)
    }
    guard mockableType.kind == .class, mockableType.methods.contains(where: isProxyable)
      else { return "" }
    let initializers = mockableType.methods
      .filter(isProxyable)
      .sorted()
      .map({ methodTemplate(for: $0).classInitializerProxy })
    
    return """
      public enum InitializerProxy {
    \(initializers.joined(separator: "\n\n"))
      }
    """
  }
  
  var equatableConformance: String {
    return """
      public static func ==(lhs: \(mockableType.name)Mock, rhs: \(mockableType.name)Mock) -> Bool {
        return true
      }
    """
  }
  
  var codeableInitializer: String {
    guard mockableType.inheritedTypes.contains(where: { $0.name == "Codable" || $0.name == "Decodable" }) else {
      return ""
    }
    guard !mockableType.methods.contains(where: { $0.name == "init(from:)" }) else { return "" }
    return """
      public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
      }
    """
  }
  
  /// Store the source location of where the mock was initialized. This allows XCTest errors from
  /// unstubbed method invocations to show up in the testing code.
  var defaultInitializer: String {
    guard mockableType.kind == .protocol || !mockableType.methods.contains(where: {
      $0.isInitializer && !$0.attributes.contains(.convenience)
    }) else { return "" }
    let superInit = (mockableType.kind == .class ? "super.init()\n    " : "")
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
    return mockableType.methods
      .sorted(by: <)
      .filter({ method -> Bool in
        // Not possible to override overloaded methods where uniqueness is from generic constraints.
        // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
        guard mockableType.kind == .class else { return true }
        guard !method.genericConstraints.isEmpty else { return true }
        return mockableType.methodsCount[Method.Reduced(from: method)] == 1
      })
      .map({ methodTemplate(for: $0).render() })
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  @inlinable
  func specializeTypeName(_ typeName: String) -> String {
    guard typeName.contains(SerializationRequest.Constants.selfTokenIndicator) else {
      return typeName // Checking prior to running `replacingOccurrences` is 4x faster.
    }
    return typeName
      .replacingOccurrences(of: SerializationRequest.Constants.selfToken,
                            with: mockableType.name + "Mock")
  }
}
