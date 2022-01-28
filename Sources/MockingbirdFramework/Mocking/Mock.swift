import Foundation

/// All generated mocks conform to this protocol.
public protocol Mock: AnyObject {
  /// Runtime metdata about the mock instance.
  var mockingbirdContext: Context { get }
  
  /// The static mocking context.
  static var mockingbirdContext: Context { get }
}

/// Stores information about generated mocks.
public struct MockMetadata {
  let dictionary: [String: Any]
  init(_ dictionary: [String: Any] = [:]) {
    self.dictionary = dictionary
  }
}
