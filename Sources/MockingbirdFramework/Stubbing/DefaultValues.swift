import Foundation
import XCTest

public extension Mock {
  /// Adds a value provider returning default values for unstubbed methods to this mock.
  ///
  /// Mocks are strict by default, meaning that calls to unstubbed methods will trigger a test
  /// failure. Methods returning Void do not need to be stubbed in strict mode.
  ///
  /// ```swift
  /// let bird = mock(Bird.self)
  /// print(bird.name)  // Fails because `bird.name` is not stubbed
  /// bird.fly()        // Okay because `fly()` has a `Void` return type
  /// ```
  ///
  /// To return default values for unstubbed methods, use a `ValueProvider` with the initialized
  /// mock. Mockingbird provides preset value providers which are guaranteed to be backwards
  /// compatible, such as `.standardProvider`.
  ///
  /// ```swift
  /// bird.useDefaultValues(from: .standardProvider)
  /// print(bird.name)  // Prints ""
  /// ```
  ///
  /// You can create custom value providers by registering values for types. See `Providable` for
  /// how to provide "wildcard" instances for generic types.
  ///
  /// ```swift
  /// var valueProvider = ValueProvider(from: .standardProvider)
  /// valueProvider.register("Ryan", for: String.self)
  /// bird.useDefaultValues(from: valueProvider)
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Values from concrete stubs always have a higher precedence than default values.
  ///
  /// ```swift
  /// given(bird.name) ~> "Ryan"
  /// print(bird.name)  // Prints "Ryan"
  ///
  /// bird.useDefaultValues(from: .standardProvider)
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// - Note: This does not remove previously added value providers.
  ///
  /// - Parameters:
  ///   - valueProvider: A value provider to add.
  @discardableResult
  func useDefaultValues(from valueProvider: ValueProvider) -> Self {
    mockingbirdContext.stubbing.defaultValueProvider.update { $0.add(valueProvider) }
    return self
  }
}

public extension NSObjectProtocol {
  /// Adds a value provider returning default values for unstubbed methods to this mock.
  ///
  /// Mocks are strict by default, meaning that calls to unstubbed methods will trigger a test
  /// failure. Methods returning Void do not need to be stubbed in strict mode.
  ///
  /// ```swift
  /// let bird = mock(Bird.self)
  /// print(bird.name)  // Fails because `bird.name` is not stubbed
  /// bird.fly()        // Okay because `fly()` has a `Void` return type
  /// ```
  ///
  /// To return default values for unstubbed methods, use a `ValueProvider` with the initialized
  /// mock. Mockingbird provides preset value providers which are guaranteed to be backwards
  /// compatible, such as `.standardProvider`.
  ///
  /// ```swift
  /// bird.useDefaultValues(from: .standardProvider)
  /// print(bird.name)  // Prints ""
  /// ```
  ///
  /// You can create custom value providers by registering values for types. See `Providable` for
  /// how to provide "wildcard" instances for generic types.
  ///
  /// ```swift
  /// var valueProvider = ValueProvider(from: .standardProvider)
  /// valueProvider.register("Ryan", for: String.self)
  /// bird.useDefaultValues(from: valueProvider)
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Values from concrete stubs always have a higher precedence than default values.
  ///
  /// ```swift
  /// given(bird.name) ~> "Ryan"
  /// print(bird.name)  // Prints "Ryan"
  ///
  /// bird.useDefaultValues(from: .standardProvider)
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// - Note: This does not remove previously added value providers.
  ///
  /// - Parameters:
  ///   - valueProvider: A value provider to add.
  @discardableResult
  func useDefaultValues(from valueProvider: ValueProvider) -> Self {
    mockingbirdContext?.stubbing.defaultValueProvider.update { $0.add(valueProvider) }
    return self
  }
}
