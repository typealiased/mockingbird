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
  func generate(memoizedVariables: inout [Variable: String],
                memoizedMethods: inout [Method: String]) -> String {
    return """
    // MARK: - Mocked \(name)
    
    public final class \(name)Mock\(allSpecializedGenericTypes): \(allInheritedTypes)\(allGenericConstraints) {
    \(staticMockingContext)
      public let mockingContext = Mockingbird.MockingContext()
      public let stubbingContext = Mockingbird.StubbingContext()
      private var sourceLocation: Mockingbird.SourceLocation? {
        get { return stubbingContext.sourceLocation }
        set {
          stubbingContext.sourceLocation = newValue
          \(name)Mock.staticMock.stubbingContext.sourceLocation = newValue
        }
      }
    
    \(generateBody(memoizedVariables: &memoizedVariables, memoizedMethods: &memoizedMethods))
    }
    """
  }
  
  var staticMockingContext: String {
    guard !genericTypes.isEmpty else { return "  static let staticMock = Mockingbird.StaticMock()" }
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
  
  var fullyQualifiedName: String { return "\(moduleName).\(name)\(allGenericTypes)" }
  
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
  
  func generateBody(memoizedVariables: inout [Variable: String],
                    memoizedMethods: inout [Method: String]) -> String {
    return [generateVariables(with: &memoizedVariables),
            equatableConformance,
            codeableInitializer,
            defaultInitializer,
            generateMethods(with: &memoizedMethods)]
      .filter({ !$0.isEmpty })
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
  
  var defaultInitializer: String {
    return """
      public init(__file: StaticString = #file, __line: UInt = #line) {
        let sourceLocation = Mockingbird.SourceLocation(__file, __line)
        self.stubbingContext.sourceLocation = sourceLocation
        \(name)Mock.staticMock.stubbingContext.sourceLocation = sourceLocation
      }
    """
  }
  
  func generateVariables(with memoizedVariables: inout [Variable: String]) -> String {
    return variables.sorted(by: <).map({
      if let memoized = memoizedVariables[$0] { return memoized }
      let generated = $0.createGenerator(in: self).generate()
      memoizedVariables[$0] = generated
      return generated
    }).joined(separator: "\n\n")
  }
  
  func generateMethods(with memoizedMethods: inout [Method: String]) -> String {
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
        if let memoized = memoizedMethods[$0] { return memoized }
        let generated = $0.createGenerator(in: self).generate()
        memoizedMethods[$0] = generated
        return generated
      })
      .joined(separator: "\n\n")
  }
  
  func specializeTypeName(_ typeName: String, unwrapOptional: Bool = false) -> String {
    guard typeName != "Self" else { return name }
    guard unwrapOptional, typeName.hasSuffix("?") else { return typeName }
    return typeName.replacingOccurrences(of: "?", with: "")
  }
}
