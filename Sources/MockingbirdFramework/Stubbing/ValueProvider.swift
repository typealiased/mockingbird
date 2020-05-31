//
//  ValueProvider.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/11/20.
//

import Foundation
import CoreGraphics

/// A type that can provide concrete instances of itself.
///
/// Provide wildcard instances for generic types by conforming the base type to `Providable` and
/// registering the type. Non-wildcard instances have precedence over wildcard instances.
///
///     extension Array: Providable {
///       public static func createInstance() -> Self? {
///         return Array()
///       }
///     }
///
///     var valueProvider = ValueProvider()
///     valueProvider.registerType(Array<Any>.self)
///
///     // All specializations of `Array` return an empty array
///     print(valueProvider.provideValue(for: Array<String>.self))  // Prints []
///     print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
///
///     // Register a non-wildcard instance of `Array<String>`
///     valueProvider.register(["A", "B"], for: Array<String>.self)
///     print(valueProvider.provideValue(for: Array<String>.self))  // Prints ["A", "B"]
///     print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
///
/// - Note: This can only be used for Swift types due to limitations with Objective-C generics in
/// Swift extensions.
public protocol Providable {
  /// Create a concrete instance of this type, or `nil` if no concrete instance is available.
  ///
  /// - Note: This is kept separate from the empty initializer `init()` to allow for specific
  /// construction of fake concrete instances.
  static func createInstance() -> Self?
}

extension Providable {
  static var providableIdentifier: String {
    return String(reflecting: self).removingGenericTyping()
  }
}

/// Provides concrete instances of types.
///
/// To return default values for unstubbed methods, use a `ValueProvider` with the initialized mock.
/// Mockingbird provides preset value providers which are guaranteed to be backwards compatible,
/// such as `.standardProvider`.
///
///     let bird = mock(Bird.self)
///     bird.useDefaultValues(from: .standardProvider)
///     print(bird.name)  // Prints ""
///
/// You can create custom value providers by registering values for types.
///
///     var valueProvider = ValueProvider()
///     valueProvider.register("Ryan", for: String.self)
///     
///     bird.useDefaultValues(from: valueProvider)
///     print(bird.name)  // Prints "Ryan"
public struct ValueProvider: Hashable {
  let subproviders = Synchronized<[ValueProvider]>([])
  let storedValues = Synchronized<[ObjectIdentifier: Any]>([:])
  let enabledIdentifiers = Synchronized<Set<String>>([])
  let identifier = UUID()
  
  init(subproviders: [ValueProvider] = [],
       values: [ObjectIdentifier: Any] = [:],
       identifiers: Set<String> = []) {
    self.storedValues.value = values
    self.subproviders.value = subproviders
    self.enabledIdentifiers.value = identifiers
  }
  
  /// Create an empty value provider.
  public init() {
    self.init(subproviders: [], values: [:], identifiers: [])
  }
  
  /// Copy another value provider.
  ///
  /// Mockingbird provides several preset value providers that can be used as the base template for
  /// custom value providers.
  ///
  ///     var valueProvider = ValueProvider(from: .standardProvider)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints ""
  ///
  /// - Parameter other: Another value provider to copy.
  public init(from other: ValueProvider) {
    self.init(subproviders: other.subproviders.read { Array($0) },
              values: other.storedValues.read { $0.mapValues({ $0 }) },
              identifiers: other.enabledIdentifiers.read { Set($0) })
  }
  
  /// Hashes the value provider instance.
  ///
  /// - Parameter hasher: The hasher to use when combining the components of this instance.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  /// Returns a Boolean value indicating whether two value provider instances are equal.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func == (lhs: ValueProvider, rhs: ValueProvider) -> Bool {
    return lhs.identifier == rhs.identifier
  }
  
  
  // MARK: - Subproviders
  
  /// Add another value provider as a subprovider
  ///
  /// Value providers can be composed hierarchically by adding subproviders. Providers added later
  /// have higher precedence.
  ///
  ///     var valueProvider = ValueProvider()
  ///
  ///     // Add a preset value provider as a subprovider.
  ///     valueProvider.addSubprovider(.standardProvider)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints ""
  ///
  ///     // Add a custom value provider a subprovider.
  ///     var stringProvider = ValueProvider()
  ///     stringProvider.register("Ryan", for: String.self)
  ///     valueProvider.addSubprovider(stringProvider)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints "Ryan"
  ///
  /// - Parameter provider: A value provider to add.
  mutating public func addSubprovider(_ provider: ValueProvider) {
    precondition(provider != self)
    subproviders.value = [provider] + subproviders.value
  }
  
  /// Remove a previously added value provider.
  ///
  /// Instances are internally unique such that it's possible to easily add and remove preset value
  /// providers.
  ///
  ///     var valueProvider = ValueProvider()
  ///     valueProvider.addSubprovider(.standardProvider)
  ///     valueProvider.removeSubprovider(.standardProvider)
  ///
  /// - Parameter provider: The value provider to remove.
  mutating public func removeSubprovider(_ provider: ValueProvider) {
    subproviders.update { $0.removeAll(where: { $0 == provider }) }
  }
  
  
  // MARK: - Value management
  
  /// Register a value for a specific type.
  ///
  /// Create custom value providers by registering values for types.
  ///
  ///     var valueProvider = ValueProvider()
  ///     valueProvider.register("Ryan", for: String.self)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints "Ryan"
  ///
  /// - Parameters:
  ///   - value: The value to register.
  ///   - type: The type to register the value under. `value` must be of kind `type`.
  mutating public func register<K, V>(_ value: V, for type: K.Type = K.self) {
    precondition(value is K)
    storedValues.update { $0[ObjectIdentifier(type)] = value }
  }
  
  /// Register a `Providable` type used to provide values for generic types.
  ///
  /// Provide wildcard instances for generic types by conforming the base type to `Providable` and
  /// registering the type. Non-wildcard instances have precedence over wildcard instances.
  ///
  ///     extension Array: Providable {
  ///       public static func createInstance() -> Self? {
  ///         return Array()
  ///       }
  ///     }
  ///
  ///     var valueProvider = ValueProvider()
  ///     valueProvider.registerType(Array<Any>.self)
  ///
  ///     // All specializations of `Array` return an empty array
  ///     print(valueProvider.provideValue(for: Array<String>.self))  // Prints []
  ///     print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
  ///
  ///     // Register a non-wildcard instance of `Array<String>`
  ///     valueProvider.register(["A", "B"], for: Array<String>.self)
  ///     print(valueProvider.provideValue(for: Array<String>.self))  // Prints ["A", "B"]
  ///     print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
  ///
  /// - Parameter type: A `Providable` type to register.
  mutating public func registerType<V: Providable>(_ type: V.Type = V.self) {
    enabledIdentifiers.update { $0.insert(type.providableIdentifier) }
  }
  
  /// Remove a registered value for a given type.
  ///
  /// Previously registered values can be removed from the top-level value provider. This does not
  /// affect values provided by subproviders.
  ///
  ///     var valueProvider = ValueProvider(from: .standardProvider)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints ""
  ///
  ///     // Override the subprovider value
  ///     valueProvider.register("Ryan", for: String.self)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints "Ryan"
  ///
  ///     // Remove the registered value
  ///     valueProvider.remove(String.self)
  ///     print(valueProvider.provideValue(for: String.self))  // Prints ""
  ///
  /// - Parameter type: The type to remove a previously registered value for.
  mutating public func remove<T>(_ type: T.Type) {
    storedValues.update { $0.removeValue(forKey: ObjectIdentifier(type)) }
  }
  
  /// Remove a registered `Providable` type.
  ///
  /// Previously registered wildcard instances for generic types can be removed from the top-level
  /// value provider.
  ///
  ///     var valueProvider = ValueProvider()
  ///
  ///     valueProvider.registerType(Array<Any>.self)
  ///     print(valueProvider.provideValue(for: Array<String>.self))  // Prints []
  ///
  ///     valueProvider.remove(Array<Any>.self)
  ///     print(valueProvider.provideValue(for: Array<String>.self))  // Prints nil
  ///
  /// - Parameter type: A `Providable` type to remove.
  mutating public func remove<V: Providable>(_ type: V.Type = V.self) {
    enabledIdentifiers.update { $0.remove(type.providableIdentifier) }
  }
  
  /// Remove all stored values, subproviders, and enabled identifiers.
  mutating func reset() {
    storedValues.update { $0.removeAll() }
    subproviders.update { $0.removeAll() }
    enabledIdentifiers.update { $0.removeAll() }
  }
  
  
  // MARK: - Value providing
  
  /// All preset value providers.
  public static let standardProvider = ValueProvider(subproviders: [
    .collectionsProvider,
    .primitivesProvider,
    .basicsProvider,
    .geometryProvider,
    .stringsProvider,
    .datesProvider,
  ])
  
  func provideValue<T>(for type: T.Type = T.self) -> T? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? T }
  }
  
  func provideValue<T: Providable>(for type: T.Type = T.self) -> T? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? T } ??
      (enabledIdentifiers
        .read({ Set($0) })
        .contains(T.providableIdentifier) ? T.createInstance() : nil)
  }
}
