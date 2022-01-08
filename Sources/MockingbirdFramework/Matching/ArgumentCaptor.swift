import Foundation

/// Captures method arguments passed during mock invocations.
///
/// An argument captor extracts received argument values which can be used in other parts of the
/// test.
///
/// ```swift
/// let bird = mock(Bird.self)
/// bird.name = "Ryan"
///
/// let nameCaptor = ArgumentCaptor<String>()
/// verify(bird.name = any()).wasCalled()
/// print(nameCaptor.value)  // Prints "Ryan"
/// ```
public class ArgumentCaptor<ParameterType>: ArgumentMatcher {
  final class WeakBox<A: AnyObject> {
    weak var value: A?
    init(_ value: A) {
      self.value = value
    }
  }

  /// Creates an argument matcher that can be passed to a mockable declaration.
  @available(*, deprecated, renamed: "any()")
  public var matcher: ParameterType {
    return createTypeFacade(self)
  }
  
  /// Creates an argument matcher that can be passed to a mockable declaration.
  // The generic constraint shadows the class constraint so the ObjC overload is picked up.
  public func any<ParameterType>() -> ParameterType {
    return createTypeFacade(self)
  }
  
  /// Creates an argument matcher that can be passed to a mockable declaration.
  public func any<ParameterType: NSObjectProtocol>() -> ParameterType {
    return createTypeFacade(self)
  }

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
    super.init(nil as ParameterType?,
               description: "any<\(ParameterType.self)>() (captor)",
               declaration: "any()",
               priority: .high) { (_, rhs) in
      return rhs is ParameterType || rhs is NonEscapingType
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
