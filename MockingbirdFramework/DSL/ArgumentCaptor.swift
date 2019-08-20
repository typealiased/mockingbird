//
//  ArgumentCaptor.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Captures method arguments passed during mock invocations.
public class ArgumentCaptor<Type>: ArgumentMatcher {
  final class WeakBox<A: AnyObject> {
    weak var value: A?
    init(_ value: A) {
      self.value = value
    }
  }

  /// Passed as a parameter to mock verification contexts.
  public var matcher: Type { return createTypeFacade(self) }

  /// All argument values received.
  public var allValues: [Type] { return capturedValues.filter({ $0 is Type }).map({ $0 as! Type }) }

  /// The last argument value received.
  public var value: Type? { return allValues.last }

  /// Whether captured arguments are weakly captured.
  let weak: Bool

  var capturedValues = [Any?]()

  /// Create a new argument captor.
  ///
  /// - Parameter weak: Whether captured arguments should be weakly captured.
  public init(weak: Bool = false) {
    self.weak = weak
    super.init(nil, description: "any()", true)
  }

  override func compare(with rhs: Any?) -> Bool {
    if let value = rhs as? Type {
      let shouldStoreWeakly = type(of: value) is AnyClass && weak
      capturedValues.append(shouldStoreWeakly ? WeakBox<AnyObject>(value as AnyObject) : value)
    }
    return super.compare(with: rhs)
  }
}
