//
//  DefaultValues.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 5/31/20.
//

import Foundation

/// Start returning default values for unstubbed methods on multiple mocks.
///
/// Mocks are strict by default, meaning that calls to unstubbed methods will trigger a test
/// failure. Methods returning Void do not need to be stubbed in strict mode.
///
///     let bird = mock(Bird.self)
///     print(bird.name)  // Fails because `bird.getName()` is not stubbed
///     bird.fly()        // Okay because `fly()` has a `Void` return type
///
/// To return default values for unstubbed methods, use a `ValueProvider` with the initialized mock.
/// Mockingbird provides preset value providers which are guaranteed to be backwards compatible,
/// such as `.standardProvider`.
///
///     let anotherBird = mock(Bird.self)
///     useDefaultValues(from: .standardProvider, on: [bird, anotherBird])
///     print(bird.name)  // Prints ""
///     print(anotherBird.name)  // Prints ""
///
/// You can create custom value providers by registering values for types. See `Providable` for how
/// to provide "wildcard" instances for generic types.
///
///     var valueProvider = ValueProvider(from: .standardProvider)
///     valueProvider.register("Ryan", for: String.self)
///
///     useDefaultValues(from: valueProvider, on: [bird, anotherBird])
///
///     print(bird.name)  // Prints "Ryan"
///     print(anotherBird.name)  // Prints "Ryan"
///
/// Values from concrete stubs always have a higher precedence than default values.
///
///     given(bird.getName()) ~> "Ryan"
///     print(bird.name)  // Prints "Ryan"
///
///     useDefaultValues(from: .standardProvider, on: [bird, anotherBird])
///
///     print(bird.name)  // Prints "Ryan"
///     print(anotherBird.name)  // Prints ""
///
/// - Note: This does not remove previously added value providers.
///
/// - Parameters:
///   - valueProvider: A value provider to add.
///   - mocks: A list of mocks that should start using the value provider.
public func useDefaultValues(from valueProvider: ValueProvider, on mocks: [Mock]) {
  mocks.forEach({ $0.useDefaultValues(from: valueProvider) })
}

/// Start returning default values for unstubbed methods on a single mock.
///
/// Mocks are strict by default, meaning that calls to unstubbed methods will trigger a test
/// failure. Methods returning Void do not need to be stubbed in strict mode.
///
///     let bird = mock(Bird.self)
///     print(bird.name)  // Fails because `bird.getName()` is not stubbed
///     bird.fly()        // Okay because `fly()` has a `Void` return type
///
/// To return default values for unstubbed methods, use a `ValueProvider` with the initialized mock.
/// Mockingbird provides preset value providers which are guaranteed to be backwards compatible,
/// such as `.standardProvider`.
///
///     useDefaultValues(from: .standardProvider, on: bird)
///     print(bird.name)  // Prints ""
///
/// You can create custom value providers by registering values for types. See `Providable` for how
/// to provide "wildcard" instances for generic types.
///
///     var valueProvider = ValueProvider(from: .standardProvider)
///     valueProvider.register("Ryan", for: String.self)
///     useDefaultValues(from: valueProvider, on: bird)
///     print(bird.name)  // Prints "Ryan"
///
/// Values from concrete stubs always have a higher precedence than default values.
///
///     given(bird.getName()) ~> "Ryan"
///     print(bird.name)  // Prints "Ryan"
///
///     useDefaultValues(from: .standardProvider, on: bird)
///     print(bird.name)  // Prints "Ryan"
///
/// - Note: This does not remove previously added value providers.
///
/// - Parameters:
///   - valueProvider: A value provider to add.
///   - mock: A mock that should start using the value provider.
public func useDefaultValues(from valueProvider: ValueProvider, on mock: Mock) {
  mock.useDefaultValues(from: valueProvider)
}

public extension Mock {
  /// Adds a value provider returning default values for unstubbed methods to this mock.
  ///
  /// Mocks are strict by default, meaning that calls to unstubbed methods will trigger a test
  /// failure. Methods returning Void do not need to be stubbed in strict mode.
  ///
  ///     let bird = mock(Bird.self)
  ///     print(bird.name)  // Fails because `bird.getName()` is not stubbed
  ///     bird.fly()        // Okay because `fly()` has a `Void` return type
  ///
  /// To return default values for unstubbed methods, use a `ValueProvider` with the initialized
  /// mock. Mockingbird provides preset value providers which are guaranteed to be backwards
  /// compatible, such as `.standardProvider`.
  ///
  ///     bird.useDefaultValues(from: .standardProvider)
  ///     print(bird.name)  // Prints ""
  ///
  /// You can create custom value providers by registering values for types. See `Providable` for
  /// how to provide "wildcard" instances for generic types.
  ///
  ///     var valueProvider = ValueProvider(from: .standardProvider)
  ///     valueProvider.register("Ryan", for: String.self)
  ///     bird.useDefaultValues(from: valueProvider)
  ///     print(bird.name)  // Prints "Ryan"
  ///
  /// Values from concrete stubs always have a higher precedence than default values.
  ///
  ///     given(bird.getName()) ~> "Ryan"
  ///     print(bird.name)  // Prints "Ryan"
  ///
  ///     bird.useDefaultValues(from: .standardProvider)
  ///     print(bird.name)  // Prints "Ryan"
  ///
  /// - Note: This does not remove previously added value providers.
  ///
  /// - Parameters:
  ///   - valueProvider: A value provider to add.
  @discardableResult
  func useDefaultValues(from valueProvider: ValueProvider) -> Self {
    stubbingContext.defaultValueProvider.addSubprovider(valueProvider)
    return self
  }
}
