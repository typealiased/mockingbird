//
//  ArgumentCaptor.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Captures method arguments passed during mock invocations.
///
/// An argument captor extracts received argument values which can be used in other parts of the
/// test.
///
///     let bird = mock(Bird.self)
///     bird.name = "Ryan"
///
///     let nameCaptor = ArgumentCaptor<String>()
///     verify(bird.setName(nameCaptor.matcher)).wasCalled()
///     print(nameCaptor.value)  // Prints "Ryan"
public class ArgumentCaptor<ParameterType>: ArgumentMatcher {
  final class WeakBox<A: AnyObject> {
    weak var value: A?
    init(_ value: A) {
      self.value = value
    }
  }

  /// Passed as a parameter to mock verification contexts.
  public var matcher: ParameterType { return createTypeFacade(self) }

  /// All recorded argument values.
  public var allValues: [ParameterType] {
    return capturedValues.compactMap({ $0 as? ParameterType })
  }

  /// The last recorded argument value.
  public var value: ParameterType? { return allValues.last }

  /// Whether captured arguments are stored weakly.
  let weak: Bool

  var capturedValues = [Any?]()

  /// Create a new argument captor.
  ///
  /// - Parameter weak: Whether captured arguments should be stored weakly.
  public init(weak: Bool = false) {
    self.weak = weak
    let base: ParameterType? = nil
    super.init(base, description: "any<\(ParameterType.self)>()", priority: .high) { (_, rhs) in
      return rhs is ParameterType
    }
  }

  override func compare(with rhs: Any?) -> Bool {
    if let value = rhs as? ParameterType {
      let shouldStoreWeakly = type(of: value) is AnyClass && weak
      capturedValues.append(shouldStoreWeakly ? WeakBox<AnyObject>(value as AnyObject) : value)
    }
    return super.compare(with: rhs)
  }
}
