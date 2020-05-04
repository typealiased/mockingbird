//
//  ValueProvider.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/11/20.
//

import Foundation
import CoreGraphics

/// Static preset value providers are not safe to modify at runtime!
public class PresetValueProvider: ValueProvider {
  // Rather than initializing a new preset value provider each time
  // e.g. `static var myPresetProvider: ValueProvider { ... }`
  // having fixed instances allows for adding and removing subproviders using the dot-name notation
  // e.g. `ValueProvider().addSubprovider(.standardProvider).removeSubprovider(.standardProvider)`
  
  @available(*, unavailable, message: "Initialize a mutable copy of this value provider using 'init(from:)'")
  @discardableResult
  override public func addSubprovider(_ provider: ValueProvider) -> Self { fatalError() }
  
  @available(*, unavailable, message: "Initialize a mutable copy of this value provider using 'init(from:)'")
  @discardableResult
  override public func removeSubprovider(_ provider: ValueProvider) -> Self { fatalError() }
  
  @available(*, unavailable, message: "Initialize a mutable copy of this value provider using 'init(from:)'")
  @discardableResult
  public override func register<K, V>(_ value: V, for type: K.Type = K.self) -> Self { fatalError() }
  
  @available(*, unavailable, message: "Initialize a mutable copy of this value provider using 'init(from:)'")
  @discardableResult
  public override func removeValue<T>(for type: T.Type) -> Self { fatalError() }
}

/// Provides a concrete value when given a type, or `nil` if no value was registered for that type.
public class ValueProvider {
  let subproviders = Synchronized<[ValueProvider]>([])
  let storedValues = Synchronized<[ObjectIdentifier: Any]>([:])
  
  init(subproviders: [ValueProvider] = [], values: [ObjectIdentifier: Any] = [:]) {
    self.storedValues.value = values
    self.subproviders.value = subproviders
  }
  
  public convenience init() {
    self.init(subproviders: [], values: [:])
  }
  
  public convenience init(from other: ValueProvider) {
    self.init(subproviders: other.subproviders.value, values: other.storedValues.value)
  }
  
  
  // MARK: - Subproviders
  
  /// Add another value provider as a subprovider. Providers added later have higher precedence.
  ///
  /// - Parameter provider: A value provider to add.
  @discardableResult
  public func addSubprovider(_ provider: ValueProvider) -> Self {
    precondition(provider !== self)
    subproviders.value = [provider] + subproviders.value
    return self
  }
  
  /// Remove a previously added value provider.
  ///
  /// - Parameter provider: The value provider to remove.
  @discardableResult
  public func removeSubprovider(_ provider: ValueProvider) -> Self {
    subproviders.update { $0.removeAll(where: { $0 === provider }) }
    return self
  }
  
  
  // MARK: - Value management
  
  /// Register a value for a specific type.
  ///
  /// - Parameters:
  ///   - value: The value to register.
  ///   - type: The type to register the value under. `value` must be of kind `type`.
  @discardableResult
  public func register<K, V>(_ value: V, for type: K.Type = K.self) -> Self {
    precondition(value is K)
    storedValues.update { $0[ObjectIdentifier(type)] = value }
    return self
  }
  
  /// Remove a registered value for a given type.
  ///
  /// - Parameter type: The type to remove a previously registered value for.
  @discardableResult
  public func removeValue<T>(for type: T.Type) -> Self {
    storedValues.update { $0.removeValue(forKey: ObjectIdentifier(type)) }
    return self
  }
  
  func reset() {
    storedValues.update { $0.removeAll() }
    subproviders.update { $0.removeAll() }
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
  
  // Swift cannot infer generic type names for types like `Array<T>` when wrapped in another generic
  // type, so making helper functions doesn't work here.
  
  func provideValue<T>(for type: T.Type = T.self) -> T? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? T }
  }
  
  // MARK: Collections
  
  func provideValue<T>(for type: Array<T>.Type) -> Array<T>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? Array<T> }
  }
  
  func provideValue<T>(for type: Set<T>.Type) -> Set<T>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? Set<T> }
  }
  
  func provideValue<K, V>(for type: Dictionary<K, V>.Type) -> Dictionary<K, V>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? Dictionary<K, V> }
  }
  
  func provideValue<K, V>(for type: NSCache<K, V>.Type) -> NSCache<K, V>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? NSCache<K, V> }
  }
  
  func provideValue<K, V>(for type: NSMapTable<K, V>.Type) -> NSMapTable<K, V>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? NSMapTable<K, V> }
  }
  
  func provideValue<T>(for type: NSHashTable<T>.Type) -> NSHashTable<T>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? NSHashTable<T> }
  }
  
  // MARK: Foundation
  
  func provideValue<T>(for type: Optional<T>.Type) -> Optional<T>? {
    for provider in subproviders.read({ Array($0) }) {
      if let value = provider.provideValue(for: type) { return value }
    }
    return storedValues.read { $0[ObjectIdentifier(type)] as? Optional<T> }
  }
}
