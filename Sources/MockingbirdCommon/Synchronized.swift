import Foundation

/// A simple wrapper for thread-safe data access.
public class Synchronized<T> {
  private let queue = DispatchQueue(label: "co.bird.mockingbird.synchronized",
                                    attributes: .concurrent)
  private(set) public var unsafeValue: T
  public var value: T {
    get {
      var value: T!
      queue.sync {
        value = unsafeValue
      }
      return value
    }
    set {
      queue.sync(flags: .barrier) {
        unsafeValue = newValue
      }
    }
  }
  
  public init(_ value: T) {
    self.unsafeValue = value
  }
  
  @discardableResult
  public func update<R>(_ block: (inout T) throws -> R) rethrows -> R {
    return try queue.sync(flags: .barrier) {
      try block(&unsafeValue)
    }
  }
  
  public func read<R>(_ block: (T) throws -> R) rethrows -> R {
    var value: R!
    try queue.sync {
      value = try block(unsafeValue)
    }
    return value
  }
}
