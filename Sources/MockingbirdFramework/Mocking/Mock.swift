//
//  Mock.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// All generated mocks conform to this protocol.
public protocol Mock {
  /// Information about received invocations.
  var mockingContext: MockingContext { get }
  
  /// Implementations for stubbing behaviors.
  var stubbingContext: StubbingContext { get }
  
  /// Static metadata about the mock created at generation time.
  var mockMetadata: MockMetadata { get }
  
  /// Where the mock was initialized.
  var sourceLocation: SourceLocation? { get set }
}

/// Used to store invocations on static or class scoped methods.
public class StaticMock: Mock {
  /// Information about received invocations.
  public let mockingContext = MockingContext()
  
  /// Implementations for stubbing behaviors.
  public let stubbingContext = StubbingContext()
  
  /// Static metadata about the mock created at generation time.
  public let mockMetadata = MockMetadata()
  
  /// Where the mock was initialized.
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

/// Represents a mocked declaration that can be stubbed or verified.
public struct Mockable<DeclarationType: Declaration, InvocationType, ReturnType> {
  let mock: Mock
  let invocation: Invocation
}

/// All mockable declaration types conform to this protocol.
public protocol Declaration {}

/// Mockable variable declarations.
public class VariableDeclaration: Declaration {}
/// Mockable property getter declarations.
public class PropertyGetterDeclaration: VariableDeclaration {}
/// Mockable property setter declarations.
public class PropertySetterDeclaration: VariableDeclaration {}

/// Mockable function declarations.
public class FunctionDeclaration: Declaration {}
/// Mockable throwing function declarations.
public class ThrowingFunctionDeclaration: FunctionDeclaration {}

/// Mockable subscript declarations.
public class SubscriptDeclaration: Declaration {}
/// Mockable subscript getter declarations.
public class SubscriptGetterDeclaration: SubscriptDeclaration {}
/// Mockable subscript setter declarations.
public class SubscriptSetterDeclaration: SubscriptDeclaration {}
