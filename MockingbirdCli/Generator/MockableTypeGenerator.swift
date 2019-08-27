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
    guard !inheritedTypes.isEmpty else { return name }
    let flattenedInheritedTypes = Array(inheritedTypes).joined(separator: " & ")
    return "\(name): \(flattenedInheritedTypes)"
  }
}

extension MockableType {
  func generate(moduleName: String) -> String {
    return """
    // MARK: - Mocked \(name)
    
    public final class \(name)Mock\(allSpecializedGenericTypes): \(allInheritedTypes)\(allGenericConstraints) {
    \(staticMockingContext)
      public let mockingContext = Mockingbird.MockingContext()
      public let stubbingContext = Mockingbird.StubbingContext()
      public let mockMetadata = Mockingbird.MockMetadata(["generator_version": "\(mockingbirdVersion.shortString)", "module_name": "\(moduleName)"])
      private var sourceLocation: Mockingbird.SourceLocation? {
        get { return stubbingContext.sourceLocation }
        set {
          stubbingContext.sourceLocation = newValue
          \(name)Mock.staticMock.stubbingContext.sourceLocation = newValue
        }
      }
    
    \(generateBody())
    }
    """
  }
  
  /// The static mocking context allows static (or class) declared methods to be mocked.
  var staticMockingContext: String {
    guard !genericTypes.isEmpty else { return "  static let staticMock = Mockingbird.StaticMock()" }
    // Since class-level generic types don't support static variables, we instead use a global
    // variable `genericTypesStaticMocks` that maps a runtime generated `staticMockIdentifier` to a
    // `StaticMock` instance.
    return """
      static var staticMock: Mockingbird.StaticMock {
        let runtimeGenericTypeNames = \(runtimeGenericTypeNames)
        let staticMockIdentifier = "\(name)Mock\(allSpecializedGenericTypes)," + runtimeGenericTypeNames
        if let staticMock = genericTypesStaticMocks.value[staticMockIdentifier] {
          return staticMock
        }
        let staticMock = Mockingbird.StaticMock()
        genericTypesStaticMocks.update { $0[staticMockIdentifier] = staticMock }
        return staticMock
      }
    """
  }
  
  var runtimeGenericTypeNames: String {
    let genericTypeSelfNames = genericTypes.map({ "\"\\(\($0.name).self)\"" }).joined(separator: ", ")
    return "[\(genericTypeSelfNames)].joined(separator: \",\")"
  }
  
  var allSpecializedGenericTypes: String {
    guard !genericTypes.isEmpty else { return "" }
    return "<" + genericTypes.map({ $0.flattenedDeclaration }).joined(separator: ", ") + ">"
  }
  
  var allGenericTypes: String {
    guard !genericTypes.isEmpty, kind == .class else { return "" }
    return "<" + genericTypes.map({ $0.name }).joined(separator: ", ") + ">"
  }
  
  var allGenericConstraints: String {
    guard !genericConstraints.isEmpty else { return "" }
    return " where " + genericConstraints.joined(separator: ", ")
  }
  
  var allInheritedTypes: String {
    return [subclass,
            inheritedProtocol,
            Constants.mockProtocolName]
      .compactMap({ $0 })
      .joined(separator: ", ")
  }
  
  var fullyQualifiedName: String {
    guard !isContainedType else { return "\(name)\(allGenericTypes)" }
    return "\(moduleName).\(name)\(allGenericTypes)"
  }
  
  var subclass: String? {
    guard kind != .class else { return fullyQualifiedName }
    let prefix = String(name.prefix(2))
    if Constants.objectProtocolPrefixes.contains(prefix) {
      return "NSObject"
    } else {
      return nil
    }
  }
  
  var inheritedProtocol: String? {
    guard kind == .protocol else { return nil }
    return fullyQualifiedName
  }
  
  func generateBody() -> String {
    return [generateVariables(),
            equatableConformance,
            codeableInitializer,
            defaultInitializer,
            generateMethods(),
            generateContainedTypes()]
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  func generateContainedTypes() -> String {
    guard !containedTypes.isEmpty else { return "" }
    return containedTypes
      .map({ $0.generate(moduleName: moduleName).indent(by: 1) })
      .joined(separator: "\n\n")
  }
  
  var equatableConformance: String {
    return """
      public static func ==(lhs: \(name)Mock, rhs: \(name)Mock) -> Bool {
        return true
      }
    """
  }
  
  var codeableInitializer: String {
    guard inheritedTypes.contains(where: { $0.name == "Codable" || $0.name == "Decodable" }) else {
      return ""
    }
    guard !methods.contains(where: { $0.name == "init(from:)" }) else { return "" }
    return """
      public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
      }
    """
  }
  
  /// For types that don't define any initializers, we generate an empty default initializer that
  /// stores the source location of where the mock was initialized. This allows us to show XCTest
  /// errors from unstubbed method invocations in the testing code rather than just in the console.
  var defaultInitializer: String {
    guard !methods.contains(where: { $0.isInitializer }) else { return "" }
    let checkVersion: String
    if kind == .class {
      checkVersion = """
          super.init()
          Mockingbird.checkVersion(for: self)
      """
    } else {
      checkVersion = "    Mockingbird.checkVersion(for: self)"
    }
    return """
      public init(__file: StaticString = #file, __line: UInt = #line) {
    \(checkVersion)
        let sourceLocation = Mockingbird.SourceLocation(__file, __line)
        self.stubbingContext.sourceLocation = sourceLocation
        \(name)Mock.staticMock.stubbingContext.sourceLocation = sourceLocation
      }
    """
  }
  
  func generateVariables() -> String {
    return variables.sorted(by: <).map({
      let generated = $0.createGenerator(in: self).generate()
      return generated
    }).joined(separator: "\n\n")
  }
  
  func generateMethods() -> String {
    return methods
      .sorted(by: <)
      .filter({ method -> Bool in
        // Not possible to override overloaded methods where uniqueness is from generic constraints.
        // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
        guard self.kind == .class else { return true }
        guard !method.genericConstraints.isEmpty else { return true }
        return methodsCount[Method.Reduced(from: method)] == 1
      })
      .map({
        let generated = $0.createGenerator(in: self).generate()
        return generated
      })
      .filter({ !$0.isEmpty })
      .joined(separator: "\n\n")
  }
  
  func specializeTypeName(_ typeName: String, unwrapOptional: Bool = false) -> String {
    guard typeName != "Self" else { return name }
    guard unwrapOptional, typeName.hasSuffix("?") else { return typeName }
    return typeName.replacingOccurrences(of: "?", with: "")
  }
}
