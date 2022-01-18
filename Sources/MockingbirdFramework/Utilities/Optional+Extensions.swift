import Foundation

/// Type-erased `Optional`.
public protocol AnyOptional {
  associatedtype Wrapped
}

extension Optional: AnyOptional {}

protocol Nullable {
  var isNil: Bool { get }
}

/// Used to determine if a type-erased value is `nil`.
extension Optional: Nullable {
  /// Whether the wrapped value is equal to `nil`.
  var isNil: Bool { self == nil }
}
