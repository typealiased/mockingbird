import Foundation

/// Intermediary object for binding forwarding targets to a mock.
public struct ForwardingContext {
  /// A target that should recieve forwarded calls.
  let target: ProxyContext.Target
}

/// Forward calls for a specific declaration to the superclass.
///
/// Use `willForwardToSuper` on class mock declarations to call the superclass implementation.
/// Superclass forwarding persists until removed with `clearStubs` or shadowed by a forwarding
/// target that was added afterwards.
///
/// ```swift
/// class Bird {
///   let name: String
///   init(name: String) { self.name = name }
/// }
///
/// // `BirdMock` subclasses `Bird`
/// let bird: BirdMock = mock(Bird.self).initialize(name: "Ryan")
///
/// given(bird.name) ~> forwardToSuper()
/// print(bird.name)  // Prints "Ryan"
/// ```
///
/// The mocked type must be a class. Adding superclass forwarding to mocked protocol declarations
/// is a no-op.
///
/// ```swift
/// // Not a class
/// protocol AbstractBird {
///   var name: String { get }
/// }
///
/// let bird = mock(AbstractBird.self)
/// given(bird.name) ~> forwardToSuper()
/// print(bird.name)  // Error: Missing stubbed implementation
/// ```
///
/// - Note: To forward all calls by default to the superclass, use `forwardCallsToSuper` on the mock
/// instance instead.
public func forwardToSuper() -> ForwardingContext {
  return ForwardingContext(target: .super)
}

/// Forward calls for a specific declaration to an object.
///
/// Objects are strongly referenced and receive proxed invocations until removed with `clearStubs`.
/// Targets added afterwards have a higher precedence and only pass calls down the forwarding chain
/// if unable handle the invocation, such as when the target is unrelated to the mocked type.
///
/// ```swift
/// class Crow: Bird {
///   let name: String
///   init(name: String) { self.name = name }
/// }
///
/// given(bird.name) ~> forward(to: Crow(name: "Ryan"))
/// print(bird.name)  // Prints "Ryan"
///
/// // Additional targets take precedence
/// given(bird.name) ~> forward(to: Crow(name: "Sterling"))
/// print(bird.name)  // Prints "Sterling"
/// ```
///
/// Concrete stubs always have a higher priority than forwarding targets, regardless of the order
/// they were added.
///
/// ```swift
/// given(bird.name) ~> "Ryan"
/// given(bird.name) ~> forward(to: Crow(name: "Sterling"))
/// print(bird.name)  // Prints "Ryan"
/// ```
///
/// Objects must inherit from the mocked type to handle forwarded invocations, even if the
/// declaration is identical. Adding an unrelated type as a forwarding target is a no-op.
///
/// ```swift
/// // Not a `Bird`
/// class Person {
///   var name = "Ryan"
/// }
///
/// given(bird.name) ~> forward(to: Person())
/// print(bird.name)  // Error: Missing stubbed implementation
/// ```
///
/// - Note: To forward all calls to an object, use `forwardCalls` on the mock instance instead.
///
/// - Parameter object: An object that should handle forwarded invocations.
public func forward<T>(to object: T) -> ForwardingContext {
  return ForwardingContext(target: .object(object))
}

public extension StubbingManager {
  /// Forward calls for a specific declaration to the superclass.
  ///
  /// Use `willForwardToSuper` on class mock declarations to call the superclass implementation when
  /// receiving a matching invocation. Superclass forwarding persists until removed with
  /// `clearStubs` or shadowed by a forwarding target that was added afterwards.
  ///
  /// ```swift
  /// class Bird {
  ///   let name: String
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// // `BirdMock` subclasses `Bird`
  /// let bird: BirdMock = mock(Bird.self).initialize(name: "Ryan")
  ///
  /// given(bird.name).willForwardToSuper()
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// The mocked type must be a class. Adding superclass forwarding to mocked protocol declarations
  /// is a no-op.
  ///
  /// ```swift
  /// // Not a class
  /// protocol AbstractBird {
  ///   var name: String { get }
  /// }
  ///
  /// let bird = mock(AbstractBird.self)
  /// given(bird.name).willForwardToSuper()
  /// print(bird.name)  // Error: Missing stubbed implementation
  /// ```
  ///
  /// - Note: To forward all calls by default to the superclass, use `forwardCallsToSuper` on the
  /// mock instance instead.
  ///
  /// - Parameter object: An object that should handle forwarded invocations.
  @discardableResult
  func willForwardToSuper() -> Self {
    return addForwardingTarget(.super)
  }
  
  /// Forward calls for a specific declaration to an object.
  ///
  /// Objects are strongly referenced and receive forwarded invocations until removed with
  /// `clearStubs`. Targets added afterwards have a higher precedence and only pass calls down the
  /// forwarding chain if unable handle the invocation, such as when the target is unrelated to the
  /// mocked type.
  ///
  /// ```swift
  /// class Crow: Bird {
  ///   let name: String
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// given(bird.name).willForward(to: Crow(name: "Ryan"))
  /// print(bird.name)  // Prints "Ryan"
  ///
  /// // Additional targets take precedence
  /// given(bird.name).willForward(to: Crow(name: "Sterling"))
  /// print(bird.name)  // Prints "Sterling"
  /// ```
  ///
  /// Concrete stubs always have a higher priority than forwarding targets, regardless of the order
  /// they were added.
  ///
  /// ```swift
  /// given(bird.name).willReturn("Ryan")
  /// given(bird.name).willForward(to: Crow(name: "Sterling"))
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Objects must inherit from the mocked type to handle forwarded invocations, even if the
  /// declaration is identical. Adding an unrelated type as a forwarding target is a no-op.
  ///
  /// ```swift
  /// // Not a `Bird`
  /// class Person {
  ///   var name = "Ryan"
  /// }
  ///
  /// given(bird.name).willForward(to: Person())
  /// print(bird.name)  // Error: Missing stubbed implementation
  /// ```
  ///
  /// - Note: To forward all calls to an object, use `forwardCalls` on the mock instance instead.
  ///
  /// - Parameter object: An object that should handle forwarded invocations.
  @discardableResult
  func willForward<T>(to object: T) -> Self {
    return addForwardingTarget(.object(object))
  }
}

public extension Mock {
  /// Create a partial mock, forwarding all calls without an explicit stub to the superclass.
  ///
  /// Use `forwardCallsToSuper` on class mocks to call the superclass implementation. Superclass
  /// forwarding persists until removed with `clearStubs` or shadowed by a forwarding target that
  /// was added afterwards.
  ///
  /// ```swift
  /// class Bird {
  ///   let name: String
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// // `BirdMock` subclasses `Bird`
  /// let bird: BirdMock = mock(Bird.self).initialize(name: "Ryan")
  ///
  /// bird.forwardCallsToSuper()
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Concrete stubs always have a higher priority than forwarding targets, regardless of the order
  /// they were added.
  ///
  /// ```swift
  /// let bird = mock(Bird.self).initialize(name: "Sterling")
  /// given(bird.name).willReturn("Ryan")
  /// bird.forwardCallsToSuper()
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Objects must inherit from the mocked type to handle forwarded invocations, even if the
  /// declaration is identical. Adding an unrelated type as a forwarding target is a no-op.
  ///
  /// ```swift
  /// // Not a class
  /// protocol AbstractBird {
  ///   var name: String { get }
  /// }
  ///
  /// let bird = mock(AbstractBird.self)
  /// bird.forwardCallsToSuper()
  /// print(bird.name)  // Error: Missing stubbed implementation
  /// ```
  ///
  /// - Returns: A partial mock using the superclass to handle invocations.
  @discardableResult
  func forwardCallsToSuper() -> Self {
    mockingbirdContext.proxy.addTarget(.super)
    return self
  }
  
  /// Create a partial mock, forwarding all calls without an explicit stub to an object.
  ///
  /// Objects are strongly referenced and receive proxed invocations until removed with
  /// `clearStubs`. Targets added afterwards have a higher precedence and only pass calls down the forwarding chain if unable handle the invocation, such as when the target is unrelated to the
  /// mocked type.
  ///
  /// ```swift
  /// class Crow: Bird {
  ///   let name: String
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// let bird = mock(Bird.self)
  /// bird.forwardCalls(to: Crow(name: "Ryan"))
  /// print(bird.name)  // Prints "Ryan"
  ///
  /// // Additional targets take precedence
  /// bird.forwardCalls(to: Crow(name: "Sterling"))
  /// print(bird.name)  // Prints "Sterling"
  /// ```
  ///
  /// Concrete stubs always have a higher priority than forwarding targets, regardless of the order
  /// they were added.
  ///
  /// ```swift
  /// given(bird.name).willReturn("Ryan")
  /// bird.forwardCalls(to: Crow(name: "Sterling"))
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Objects must inherit from the mocked type to handle forwarded invocations, even if the
  /// declaration is identical. Adding an unrelated type as a forwarding target is a no-op.
  ///
  /// ```swift
  /// // Not a `Bird`
  /// class Person {
  ///   var name = "Ryan"
  /// }
  ///
  /// bird.forwardCalls(to: Person())
  /// print(bird.name)  // Error: Missing stubbed implementation
  /// ```
  ///
  /// - Parameter object: An object that should handle forwarded invocations.
  /// - Returns: A partial mock using `object` to handle invocations.
  @discardableResult
  func forwardCalls<T>(to object: T) -> Self {
    mockingbirdContext.proxy.addTarget(.object(object))
    return self
  }
}

public extension NSObjectProtocol {
  /// Create a partial mock, forwarding all calls without an explicit stub to the superclass.
  ///
  /// Use `forwardCallsToSuper` on class mocks to call the superclass implementation. Superclass
  /// forwarding persists until removed with `clearStubs` or shadowed by a forwarding target that
  /// was added afterwards.
  ///
  /// ```swift
  /// class Bird {
  ///   let name: String
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// // `BirdMock` subclasses `Bird`
  /// let bird: BirdMock = mock(Bird.self).initialize(name: "Ryan")
  ///
  /// bird.forwardCallsToSuper()
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Concrete stubs always have a higher priority than forwarding targets, regardless of the order
  /// they were added.
  ///
  /// ```swift
  /// let bird = mock(Bird.self).initialize(name: "Sterling")
  /// given(bird.name).willReturn("Ryan")
  /// bird.forwardCallsToSuper()
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Objects must inherit from the mocked type to handle forwarded invocations, even if the
  /// declaration is identical. Adding an unrelated type as a forwarding target is a no-op.
  ///
  /// ```swift
  /// // Not a class
  /// protocol AbstractBird {
  ///   var name: String { get }
  /// }
  ///
  /// let bird = mock(AbstractBird.self)
  /// bird.forwardCallsToSuper()
  /// print(bird.name)  // Error: Missing stubbed implementation
  /// ```
  ///
  /// - Returns: A partial mock using the superclass to handle invocations.
  @_disfavoredOverload
  @discardableResult
  func forwardCallsToSuper() -> Self {
    mockingbirdContext?.proxy.addTarget(.super)
    return self
  }
  
  /// Create a partial mock, forwarding all calls without an explicit stub to an object.
  ///
  /// Objects are strongly referenced and receive proxed invocations until removed with
  /// `clearStubs`. Targets added afterwards have a higher precedence and only pass calls down the forwarding chain if unable handle the invocation, such as when the target is unrelated to the
  /// mocked type.
  ///
  /// ```swift
  /// class Crow: Bird {
  ///   let name: String
  ///   init(name: String) { self.name = name }
  /// }
  ///
  /// let bird = mock(Bird.self)
  /// bird.forwardCalls(to: Crow(name: "Ryan"))
  /// print(bird.name)  // Prints "Ryan"
  ///
  /// // Additional targets take precedence
  /// bird.forwardCalls(to: Crow(name: "Sterling"))
  /// print(bird.name)  // Prints "Sterling"
  /// ```
  ///
  /// Concrete stubs always have a higher priority than forwarding targets, regardless of the order
  /// they were added.
  ///
  /// ```swift
  /// given(bird.name).willReturn("Ryan")
  /// bird.forwardCalls(to: Crow(name: "Sterling"))
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Objects must inherit from the mocked type to handle forwarded invocations, even if the
  /// declaration is identical. Adding an unrelated type as a forwarding target is a no-op.
  ///
  /// ```swift
  /// // Not a `Bird`
  /// class Person {
  ///   var name = "Ryan"
  /// }
  ///
  /// bird.forwardCalls(to: Person())
  /// print(bird.name)  // Error: Missing stubbed implementation
  /// ```
  ///
  /// - Parameter object: An object that should handle forwarded invocations.
  /// - Returns: A partial mock using `object` to handle invocations.
  @_disfavoredOverload
  @discardableResult
  func forwardCalls<T>(to target: T) -> Self {
    mockingbirdContext?.proxy.addTarget(.object(target))
    return self
  }
}
