//
//  Mock.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// All generated mocks conform to this protocol.
public protocol Mock {
  var mockingContext: MockingContext { get }
  var stubbingContext: StubbingContext { get }
  var mockMetadata: MockMetadata { get }
  var sourceLocation: SourceLocation? { get set }
}

/// Used to store invocations on static or class scoped methods.
public class StaticMock: Mock {
  public let mockingContext = MockingContext()
  public let stubbingContext = StubbingContext()
  public let mockMetadata = MockMetadata()
  public var sourceLocation: SourceLocation? {
    get { return stubbingContext.sourceLocation }
    set { stubbingContext.sourceLocation = newValue }
  }
}

/// Stores information about generated mocks.
public struct MockMetadata {
  let dictionary: [String: Any]
  init(_ dictionary: [String: Any] = [:]) {
    self.dictionary = dictionary
  }
}

/// A object used as a stubbing or verification request for a particular concrete mock instance.
/// T = Declaration type, I = Invocation function type, R = Return type
public struct Mockable<T: DeclarationType, I, R> {
  let mock: Mock
  let invocation: Invocation
}

/// Used for disambiguating methods with the same function signature as a variable accessor.
public protocol DeclarationType {}
public enum VariableDeclaration: DeclarationType {}
public enum MethodDeclaration: DeclarationType {}
