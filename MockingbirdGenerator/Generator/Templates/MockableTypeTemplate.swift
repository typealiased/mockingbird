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
  static let abstractMockSuffix = "AbstractMockType"
  static let abstractMockPrefixSeparator = "_"
  
  /// Mapping from protocol to concrete subclass conformance, mainly used for `NSObjectProtocol`.
  static let automaticConformanceMap: [String: String] = [
    "Foundation.NSObjectProtocol": "Foundation.NSObject"
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
  let abstractTypeNamePrefix: String
  private var methodTemplates = [Method: MethodTemplate]()
  init(mockableType: MockableType, abstractTypeNamePrefix: String) {
    self.mockableType = mockableType
    self.abstractTypeNamePrefix = abstractTypeNamePrefix
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
    guard !mockableType.genericTypes.isEmpty || mockableType.isInGenericContainingType
      else { return "  static let staticMock = Mockingbird.StaticMock()" }
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
      .sorted(by: { $0.name < $1.name })
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
      .sorted().map({ specializeTypeName("\($0)") }).joined(separator: ", ")
  }()
  
  var allInheritedTypes: String {
    let additionalInheritedTypes = [Constants.mockProtocolName,
                                    abstractMockProtocolName]
    return (inheritedTypes + additionalInheritedTypes).joined(separator: ", ")
  }
  
  /// For scoped types referenced within their containing type.
  lazy var fullyQualifiedName: String = {
    guard mockableType.kind == .class else {
      return "\(mockableType.moduleName).\(mockableType.name)"
    }
    guard !mockableType.isContainedType else { return "\(mockableType.name)\(allGenericTypes)" }
    return "\(mockableType.moduleName).\(mockableType.name)\(allGenericTypes)"
  }()
  
  lazy var abstractMockProtocolName: String = {
    return [abstractTypeNamePrefix, mockableType.name + Constants.abstractMockSuffix]
      .filter({ !$0.isEmpty })
      .joined(separator: Constants.abstractMockPrefixSeparator)
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
    guard mockableType.kind == .protocol else { return nil }
    
    if let classConformance = mockableType.primarySelfConformanceTypeName {
      // Handle class conformance constraints from where clauses.
      return classConformance
      
    } else if let autoConformance = mockableType.allInheritedTypeNames
      .compactMap({ Constants.automaticConformanceMap[$0] }).first {
      // Automatically conform unmockable protocols like `NSObjectProtocol` to `NSObject`.
      return autoConformance
      
    }
    
    return nil
  }()
  
  var inheritedTypes: [String] {
    var types = [String]()
    if let protocolClassConformance = self.protocolClassConformance {
      types.append(protocolClassConformance)
    }
    types.append(fullyQualifiedName)
    
    let classConformanceTypeNames = Set(mockableType.selfConformanceTypes
      .filter({ $0.kind == .class })
      .map({ $0.fullyQualifiedModuleName }))
    let conformanceTypes = Set(mockableType.allSelfConformanceTypeNames)
      .subtracting(classConformanceTypeNames)
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
      .map({
        MockableTypeTemplate(mockableType: $0, abstractTypeNamePrefix: abstractMockProtocolName)
          .render()
          .indent()
      })
    return containedTypesSubstructure.joined(separator: "\n\n")
  }
  
  func renderInitializerProxy() -> String {
    let isProxyable: (Method) -> Bool = {
      // This needs to be a designated initializer since if it's a convenience initializer, we can't
      // always infer what concrete argument values to pass to the designated initializer.
      $0.isDesignatedInitializer
    }
    
    guard !shouldGenerateDefaultInitializer else { return "" }
    let (initializers, dummyInitializers) = mockableType.methods
      .filter(isProxyable)
      .filter(isOverridable)
      .sorted()
      .flatMap({ methodTemplate(for: $0).classInitializerProxy })
      .uniqued()
      .reduce(into: ([String](), [String]())) {
        (result, initializer) in
        switch initializer.style {
        case .implicit, .explicit, .unavailable:
          result.0.append(initializer.body.indent(by: 2))
        case .dummy:
          result.1.append(initializer.body.indent(by: 3))
        }
      }
    
    guard !initializers.isEmpty || !dummyInitializers.isEmpty else {
      return """
        public class InitializerProxy: Mockingbird.Initializable {
          public class Dummy: Mockingbird.Initializable {}
        }
      """
    }
    return """
      public class InitializerProxy: Mockingbird.Initializable {
        fileprivate init() {}
    
        public class Dummy: Mockingbird.Initializable {
    \(dummyInitializers.joined(separator: "\n\n"))
        }
    
    \(initializers.joined(separator: "\n\n"))
      }
    """
  }
  
  /// Store the source location of where the mock was initialized. This allows `XCTest` errors from
  /// unstubbed method invocations to show up in the testing code.
  var shouldGenerateDefaultInitializer: Bool {
    // Opaque types can have designated initializers we don't know about, so it's best to ignore.
    guard !mockableType.hasOpaqueInheritedType else {
      logWarning("Skipping default initializer generation for `\(mockableType.name)` because it has an opaque inherited type")
      return false
    }
    
    let hasDesignatedInitializer =
      mockableType.methods.contains(where: { $0.isDesignatedInitializer })
    
    guard mockableType.kind == .protocol else { // Handle classes.
      if hasDesignatedInitializer {
        log("Skipping default initializer generation for `\(mockableType.name)` because it is a class with a designated initializer")
      }
      return !hasDesignatedInitializer
    }
    
    // We can always generate a default initializer for protocols without class conformance.
    guard protocolClassConformance != nil else { return true }
    
    // Ignore protocols conforming to a class with a designated initializer.
    guard !hasDesignatedInitializer else {
      log("Skipping default initializer generation for `\(mockableType.name)` because it is a protocol conforming to a class with a designated initializer")
      return false
    }
    
    let isMockableClassConformance = mockableType.primarySelfConformanceType?.shouldMock ?? true
    if !isMockableClassConformance {
      logWarning("The type `\(mockableType.name)` is uninitializable because it is a protocol conforming to a class without public initializers")
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
    return mockableType.methods.contains(where: { $0.isOverridable && $0.isDesignatedInitializer })
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
    guard mockableType.kind == .class || mockableType.primarySelfConformanceType != nil
      else { return true }
    guard !method.whereClauses.isEmpty || !method.genericTypes.isEmpty else { return true }
    return mockableType.methodsCount[Method.Reduced(from: method)] == 1
  }
  
  func renderMethods() -> String {
    return Set(mockableType.methods)
      .filter(isOverridable)
      .sorted(by: <)
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
