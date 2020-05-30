//
//  ValueProvider.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/11/20.
//

import Foundation
import CoreGraphics

/// Provides a concrete instance of a type that cannot be easily registered to a `ValueProvider`.
/// This is primarily used to handle generics and can only be used for Swift types.
public protocol Providable {
  /// Create a concrete instance of this type, or `nil` if no concrete instance is available.
  ///
  /// This is kept separate from the empty initializer `init()` to allow for specific construction
  /// of fake concrete instances.
  static func createInstance() -> Self?
}

extension Providable {
  static var providableIdentifier: String {
    return String(reflecting: self).removingGenericTyping()
  }
}

/// Provides a concrete value when given a type, or `nil` if no value was registered for that type.
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
  
  public init() {
    self.init(subproviders: [], values: [:], identifiers: [])
  }
  
  public init(from other: ValueProvider) {
    self.init(subproviders: other.subproviders.read { Array($0) },
              values: other.storedValues.read { $0.mapValues({ $0 }) },
              identifiers: other.enabledIdentifiers.read { Set($0) })
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  public static func == (lhs: ValueProvider, rhs: ValueProvider) -> Bool {
    return lhs.identifier == rhs.identifier
  }
  
  
  // MARK: - Subproviders
  
  /// Add another value provider as a subprovider. Providers added later have higher precedence.
  ///
  /// - Parameter provider: A value provider to add.
  mutating public func addSubprovider(_ provider: ValueProvider) {
    precondition(provider != self)
    subproviders.value = [provider] + subproviders.value
  }
  
  /// Remove a previously added value provider.
  ///
  /// - Parameter provider: The value provider to remove.
  mutating public func removeSubprovider(_ provider: ValueProvider) {
    subproviders.update { $0.removeAll(where: { $0 == provider }) }
  }
  
  
  // MARK: - Value management
  
  /// Register a value for a specific type.
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
  /// - Parameter type: A `Providable` type to register.
  mutating public func registerType<V: Providable>(_ type: V.Type = V.self) {
    enabledIdentifiers.update { $0.insert(type.providableIdentifier) }
  }
  
  /// Remove a registered value for a given type.
  ///
  /// - Parameter type: The type to remove a previously registered value for.
  mutating public func remove<T>(_ type: T.Type) {
    storedValues.update { $0.removeValue(forKey: ObjectIdentifier(type)) }
  }
  
  /// Remove a registered `Providable` type.
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
