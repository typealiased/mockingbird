import Foundation

/// A type that can provide concrete instances of itself.
///
/// Provide wildcard instances for generic types by conforming the base type to `Providable` and
/// registering the type. Non-wildcard instances have precedence over wildcard instances.
///
/// ```swift
/// extension Array: Providable {
///   public static func createInstance() -> Self? {
///     return Array()
///   }
/// }
///
/// var valueProvider = ValueProvider()
/// valueProvider.registerType(Array<Any>.self)
///
/// // All specializations of `Array` return an empty array
/// print(valueProvider.provideValue(for: Array<String>.self))  // Prints []
/// print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
///
/// // Register a non-wildcard instance of `Array<String>`
/// valueProvider.register(["A", "B"], for: Array<String>.self)
/// print(valueProvider.provideValue(for: Array<String>.self))  // Prints ["A", "B"]
/// print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
/// ```
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
  
  func metatype() -> Self.Type {
    return type(of: self)
  }
}

/// Provides concrete instances of types.
///
/// To return default values for unstubbed methods, use a `ValueProvider` with the initialized mock.
/// Mockingbird provides preset value providers which are guaranteed to be backwards compatible,
/// such as `.standardProvider`.
///
/// ```swift
/// let bird = mock(Bird.self)
/// bird.useDefaultValues(from: .standardProvider)
/// print(bird.name)  // Prints ""
/// ```
///
/// You can create custom value providers by registering values for types.
///
/// ```swift
/// var valueProvider = ValueProvider()
/// valueProvider.register("Ryan", for: String.self)
///
/// bird.useDefaultValues(from: valueProvider)
/// print(bird.name)  // Prints "Ryan"
/// ```
public struct ValueProvider {
  var storedValues = [ObjectIdentifier: Any]()
  var enabledIdentifiers = Set<String>()
  
  /// Enables all mocks to handle methods that return `Void`.
  static let baseValues: [ObjectIdentifier: Any] = [ObjectIdentifier(Void.self): ()]
  
  init(values: [ObjectIdentifier: Any] = [:], identifiers: Set<String> = []) {
    self.storedValues = values
    self.enabledIdentifiers = identifiers
  }
  
  /// Create an empty value provider.
  public init() {
    self.init(values: Self.baseValues, identifiers: [])
  }
  
  
  // MARK: - Subproviders
  
  /// Adds the values from another value provider.
  ///
  /// Value providers can be composed by adding values from another provider. Values in the other
  /// provider have precedence and will overwrite existing values in this provider.
  ///
  /// ```swift
  /// var valueProvider = ValueProvider()
  /// valueProvider.add(.standardProvider)
  /// print(valueProvider.provideValue(for: String.self))  // Prints ""
  /// ```
  ///
  /// - Parameter other: A value provider to combine.
  mutating public func add(_ other: Self) {
    storedValues.merge(other.storedValues, uniquingKeysWith: { (_, new) in return new })
    enabledIdentifiers.formUnion(other.enabledIdentifiers)
  }
  
  /// Returns a new value provider containing the values from both providers.
  ///
  /// Value providers can be composed by adding values from another provider. Values in the added
  /// provider have precendence over those in base provider.
  ///
  /// ```swift
  /// let valueProvider = ValueProvider.collectionsProvider.adding(.primitivesProvider)
  /// print(valueProvider.provideValue(for: [Bool].self))  // Prints []
  /// print(valueProvider.provideValue(for: Int.self))     // Prints 0
  /// ```
  ///
  /// - Parameter other: A value provider to combine.
  /// - Returns: A new value provider with the values of `lhs` and `rhs`.
  public func adding(_ other: Self) -> Self {
    var newProvider = self
    newProvider.add(other)
    return newProvider
  }
  
  /// Returns a new value provider containing the values from both providers.
  ///
  /// Value providers can be composed by adding values from other providers. Values in the second
  /// provider have precendence over those in first provider.
  ///
  /// ```swift
  /// let valueProvider = .collectionsProvider + .primitivesProvider
  /// print(valueProvider.provideValue(for: [Bool].self))  // Prints []
  /// print(valueProvider.provideValue(for: Int.self))     // Prints 0
  /// ```
  ///
  /// - Parameters:
  ///   - lhs: A value provider.
  ///   - rhs: A value provider.
  /// - Returns: A new value provider with the values of `lhs` and `rhs`.
  static public func + (lhs: Self, rhs: Self) -> Self {
    return lhs.adding(rhs)
  }
  
  // MARK: - Value management
  
  /// Register a value for a specific type.
  ///
  /// Create custom value providers by registering values for types.
  ///
  /// ```swift
  /// var valueProvider = ValueProvider()
  /// valueProvider.register("Ryan", for: String.self)
  /// print(valueProvider.provideValue(for: String.self))  // Prints "Ryan"
  /// ```
  ///
  /// - Parameters:
  ///   - value: The value to register.
  ///   - type: The type to register the value under. `value` must be of kind `type`.
  mutating public func register<K, V>(_ value: V, for type: K.Type) {
    precondition(value is K)
    storedValues[ObjectIdentifier(type)] = value
  }
  
  /// Register a `Providable` type used to provide values for generic types.
  ///
  /// Provide wildcard instances for generic types by conforming the base type to `Providable` and
  /// registering the type. Non-wildcard instances have precedence over wildcard instances.
  ///
  /// ```swift
  /// extension Array: Providable {
  ///   public static func createInstance() -> Self? {
  ///     return Array()
  ///   }
  /// }
  ///
  /// var valueProvider = ValueProvider()
  /// valueProvider.registerType(Array<Any>.self)
  ///
  /// // All specializations of `Array` return an empty array
  /// print(valueProvider.provideValue(for: Array<String>.self))  // Prints []
  /// print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
  ///
  /// // Register a non-wildcard instance of `Array<String>`
  /// valueProvider.register(["A", "B"], for: Array<String>.self)
  /// print(valueProvider.provideValue(for: Array<String>.self))  // Prints ["A", "B"]
  /// print(valueProvider.provideValue(for: Array<Data>.self))    // Prints []
  /// ```
  ///
  /// - Parameter type: A `Providable` type to register.
  mutating public func registerType<T: Providable>(_ type: T.Type = T.self) {
    enabledIdentifiers.insert(type.providableIdentifier)
  }
  
  /// Remove a registered value for a given type.
  ///
  /// Previously registered values can be removed from the top-level value provider. This does not
  /// affect values provided by subproviders.
  ///
  /// ```swift
  /// var valueProvider = ValueProvider(from: .standardProvider)
  /// print(valueProvider.provideValue(for: String.self))  // Prints ""
  ///
  /// // Override the subprovider value
  /// valueProvider.register("Ryan", for: String.self)
  /// print(valueProvider.provideValue(for: String.self))  // Prints "Ryan"
  ///
  /// // Remove the registered value
  /// valueProvider.remove(String.self)
  /// print(valueProvider.provideValue(for: String.self))  // Prints ""
  /// ```
  ///
  /// - Parameter type: The type to remove a previously registered value for.
  mutating public func remove<T>(_ type: T.Type) {
    storedValues.removeValue(forKey: ObjectIdentifier(type))
  }
  
  /// Remove a registered `Providable` type.
  ///
  /// Previously registered wildcard instances for generic types can be removed from the top-level
  /// value provider.
  ///
  /// ```swift
  /// var valueProvider = ValueProvider()
  ///
  /// valueProvider.registerType(Array<Any>.self)
  /// print(valueProvider.provideValue(for: Array<String>.self))  // Prints []
  ///
  /// valueProvider.remove(Array<Any>.self)
  /// print(valueProvider.provideValue(for: Array<String>.self))  // Prints nil
  /// ```
  ///
  /// - Parameter type: A `Providable` type to remove.
  mutating public func remove<T: Providable>(_ type: T.Type = T.self) {
    enabledIdentifiers.remove(type.providableIdentifier)
  }
  
  /// Remove all stored values, subproviders, and enabled identifiers.
  mutating func reset() {
    storedValues = Self.baseValues
    enabledIdentifiers.removeAll()
  }
  
  
  // MARK: - Value providing
  
  /// All preset value providers.
  public static let standardProvider = ValueProvider() +
    .collectionsProvider +
    .primitivesProvider +
    .basicsProvider +
    .stringsProvider +
    .datesProvider
  
  /// Provide a value for a given type.
  ///
  /// - Parameter type: A type to provide a value for.
  /// - Returns: A concrete instance of the given type, or `nil` if no value could be provided.
  public func provideValue<T>(for type: T.Type = T.self) -> T? {
    if let value = storedValues[ObjectIdentifier(type)] as? T {
      return value
    }
    
    // Handle providable generic types.
    guard let providableType = type as? Providable.Type,
          enabledIdentifiers.contains(providableType.providableIdentifier) else {
      return nil
    }
    return providableType.createInstance() as? T
  }
  
  func provideValue(for objcType: String) -> Any? {
    guard let objectIdentifier = objCTypeEncodings[objcType] else { return nil }
    return storedValues[objectIdentifier]
  }
}
