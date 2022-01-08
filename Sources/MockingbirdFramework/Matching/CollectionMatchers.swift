import Foundation

/// Matches any collection containing all of the values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(containing:)` to match collections that contain all specified
/// values.
///
/// ```swift
/// protocol Bird {
///   func send(_ messages: [String])
/// }
///
/// given(bird.send(any(containing: "Hi", "Hello")))
///   .will { print($0) }
///
/// bird.send(["Hi", "Hello"])  // Prints ["Hi", "Hello"]
/// bird.send(["Hi", "Bye"])    // Error: Missing stubbed implementation
/// bird.send(["Bye"])          // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ messages: [T])    // Overloaded generically
///   func send(_ messages: [String])  // Overloaded explicitly
///   func send(_ messages: [Data])
/// }
///
/// given(bird.send(any([String].self, containing: ["Hi", "Hello"])))
///   .will { print($0) }
///
/// bird.send(["Hi", "Hello"])       // Prints ["Hi", "Hello"]
/// bird.send([Data([1]), Data(2)])  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - values: A set of values that must all exist in the collection to match.
public func any<T: Collection>(_ type: T.Type = T.self, containing values: T.Element...) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>(containing:)",
                                declaration: "any(containing: …)",
                                priority: .high) { (_, rhs) in
    guard let collection = rhs as? T else { return false }
    return values.allSatisfy({
      let valueMatcher = ArgumentMatcher($0)
      return collection.contains(where: { valueMatcher == ArgumentMatcher($0) })
    })
  }
  return createTypeFacade(matcher)
}

/// Matches any dictionary containing all of the values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(containing:)` to match dictionaries that contain all specified
/// values.
///
/// ```swift
/// protocol Bird {
///   func send(_ messages: [UUID: String])
/// }
///
/// given(bird.send(any(containing: "Hi", "Hello")))
///   .will { print($0) }
///
/// bird.send([
///   UUID(): "Hi",
///   UUID(): "Hello",
/// ])  // Prints ["Hi", "Hello"]
///
/// bird.send([
///   UUID(): "Hi",
///   UUID(): "Bye",
/// ])  // Error: Missing stubbed implementation
///
/// bird.send([
///   UUID(): "Bye",
/// ]) // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ messages: [UUID: T])    // Overloaded generically
///   func send(_ messages: [UUID: String])  // Overloaded explicitly
///   func send(_ messages: [UUID: Data])
/// }
///
/// given(bird.send(any([UUID: String].self, containing: "Hi", "Hello")))
///   .will { print($0) }
///
/// bird.send([
///   UUID(): "Hi",
///   UUID(): "Hello",
/// ])  // Prints ["Hi", "Hello"]
///
/// bird.send([
///   UUID(): Data([1]),
///   UUID(): Data([2]),
/// ])  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - values: A set of values that must all exist in the dictionary to match.
public func any<K, V>(_ type: Dictionary<K, V>.Type = Dictionary<K, V>.self,
                      containing values: V...) -> Dictionary<K, V> {
  let matcher = ArgumentMatcher(nil as Dictionary<K, V>?,
                                description: "any<\(Dictionary<K, V>.self)>(containing:)",
                                declaration: "any(containing: …)",
                                priority: .high) { (_, rhs) in
    guard let collection = rhs as? Dictionary<K, V> else { return false }
    return values.allSatisfy({
      let valueMatcher = ArgumentMatcher($0)
      return collection.contains(where: { valueMatcher == ArgumentMatcher($0.value) })
    })
  }
  return createTypeFacade(matcher)
}

/// Matches any dictionary containing all of the keys.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(keys:)` to match dictionaries that contain all specified keys.
///
/// ```swift
/// protocol Bird {
///   func send(_ messages: [UUID: String])
/// }
///
/// let messageId1 = UUID()
/// let messageId2 = UUID()
/// given(bird.send(any(keys: messageId1, messageId2)))
///   .will { print($0) }
///
/// bird.send([
///   messageId1: "Hi",
///   messageId2: "Hello",
/// ])  // Prints ["Hi", "Hello"]
///
/// bird.send([
///   UUID(): "Hi",
///   UUID(): "Hello",
/// ])  // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ messages: [UUID: T])    // Overloaded generically
///   func send(_ messages: [UUID: String])  // Overloaded explicitly
///   func send(_ messages: [UUID: Data])
/// }
///
/// let messageId1 = UUID()
/// let messageId2 = UUID()
/// given(bird.send(any([UUID: String].self, keys: messageId1, messageId2)))
///   .will { print($0) }
///
/// bird.send([
///   messageId1: "Hi",
///   messageId2: "Hello",
/// ])  // Prints ["Hi", "Hello"]
///
/// bird.send([
///   messageId1: Data([1]),
///   messageId2: Data([2]),
/// ])  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - keys: A set of keys that must all exist in the dictionary to match.
public func any<K, V>(_ type: Dictionary<K, V>.Type = Dictionary<K, V>.self,
                      keys: K...) -> Dictionary<K, V> {
  let matcher = ArgumentMatcher(nil as Dictionary<K, V>?,
                                description: "any<\(Dictionary<K, V>.self)>(keys:)",
                                declaration: "any(keys: …)",
                                priority: .high) { (_, rhs) in
    guard let collection = rhs as? Dictionary<K, V> else { return false }
    return keys.allSatisfy({
      let keyMatcher = ArgumentMatcher($0)
      return collection.contains(where: { keyMatcher == ArgumentMatcher($0.key) })
    })
  }
  return createTypeFacade(matcher)
}

/// Matches any collection with a specific number of elements.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(count:)` to match collections with a specific number of elements.
///
/// ```swift
/// protocol Bird {
///   func send(_ messages: [String])
/// }
///
/// given(bird.send(any(count: 2))).will { print($0) }
///
/// bird.send(["Hi", "Hello"])  // Prints ["Hi", "Hello"]
/// bird.send(["Hi"])           // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ messages: [T])    // Overloaded generically
///   func send(_ messages: [String])  // Overloaded explicitly
///   func send(_ messages: [Data])
/// }
///
/// given(bird.send(any([String].self, count: 2)))
///   .will { print($0) }
///
/// bird.send(["Hi", "Hello"])         // Prints ["Hi", "Hello"]
/// bird.send([Data([1]), Data([2])])  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - countMatcher: A count matcher defining the number of acceptable elements in the collection.
public func any<T: Collection>(_ type: T.Type = T.self, count countMatcher: CountMatcher) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>(count:)",
                                declaration: "any(count: …)",
                                priority: .high) { (_, rhs) in
    guard let collection = rhs as? T else { return false }
    return countMatcher.matches(collection.count)
  }
  return createTypeFacade(matcher)
}

/// Matches any collection with at least one element.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `notEmpty` to match collections with one or more elements.
///
/// ```swift
/// protocol Bird {
///   func send(_ messages: [String])
/// }
///
/// given(bird.send(any(count: 2))).will { print($0) }
///
/// bird.send(["Hi"])  // Prints ["Hi"]
/// bird.send([])      // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ messages: [T])    // Overloaded generically
///   func send(_ messages: [String])  // Overloaded explicitly
///   func send(_ messages: [Data])
/// }
///
/// given(bird.send(notEmpty([String].self)))
///   .will { print($0) }
///
/// bird.send(["Hi"])       // Prints ["Hi"]
/// bird.send([Data([1])])  // Error: Missing stubbed implementation
/// ```
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func notEmpty<T: Collection>(_ type: T.Type = T.self) -> T {
  return any(count: atLeast(1))
}

// MARK: Floating point matchers

/// Matches floating point arguments within some tolerance.
///
/// Mathematical operations on floating point numbers can cause loss of precision. Fuzzily match floating point arguments instead of using exact values to increase the robustness of tests.
///
/// ```swift
/// protocol Bird {
///   func canChirp(volume: Double) -> Bool
/// }
///
/// given(bird.canChirp(volume: around(42.0, tolerance: 0.1)))
///   .willReturn(true)
///
/// print(bird.canChirp(volume: 42.0))     // Prints "true"
/// print(bird.canChirp(volume: 42.0999))  // Prints "true"
/// print(bird.canChirp(volume: 42.1))     // Prints "false"
/// ```
///
/// - Parameters:
///   - value: The expected value.
///   - tolerance: Only matches if the absolute difference is strictly less than this value.
public func around<T: FloatingPoint>(_ value: T, tolerance: T) -> T {
  let matcher = ArgumentMatcher(value,
                                description: "around<\(T.self)>()",
                                declaration: "around(…)",
                                priority: .high) { (lhs, rhs) in
    guard let base = lhs as? T, let other = rhs as? T else { return false }
    return abs(other - base) < tolerance
  }
  return createTypeFacade(matcher)
}
