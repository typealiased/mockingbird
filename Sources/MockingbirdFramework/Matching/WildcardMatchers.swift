import Foundation

/// Matches all argument values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the wildcard argument matcher `any` as a type safe placeholder for matching any argument
/// value.
///
/// ```swift
/// given(bird.canChirp(volume: any())).willReturn(true)
/// print(bird.canChirp(volume: 10))  // Prints "true"
/// verify(bird.canChirp(volume: any())).wasCalled()
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ message: T)    // Overloaded generically
///   func send(_ message: String)  // Overloaded explicitly
///   func send(_ message: Data)
/// }
///
/// given(bird.send(any(String.self))).will { print($0) }
///
/// bird.send("Hello")  // Prints "Hello"
///
/// verify(bird.send(any(String.self))).wasCalled()
/// verify(bird.send(any(Data.self))).wasNeverCalled()
/// ```
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func any<T>(_ type: T.Type = T.self) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>()",
                                declaration: "any()",
                                priority: .high) { (_, rhs) in
    return rhs is T || rhs is NonEscapingType
  }
  return createTypeFacade(matcher)
}

/// Matches all Objective-C object argument values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the wildcard argument matcher `any` as a type safe placeholder for matching any argument
/// value.
///
/// ```swift
/// // Protocol referencing Obj-C object types
/// protocol Bird {
///   func canChirp(volume: NSNumber) -> Bool
/// }
///
/// given(bird.canChirp(volume: any())).willReturn(true)
/// print(bird.canChirp(volume: 10))  // Prints "true"
/// verify(bird.canChirp(volume: any())).wasCalled()
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// // Protocol referencing Obj-C object types
/// protocol Bird {
///   func send<T: NSObject>(_ message: T)  // Overloaded generically
///   func send(_ message: NSString)        // Overloaded explicitly
///   func send(_ message: NSData)
/// }
///
/// given(bird.send(any(NSString.self))).will { print($0) }
///
/// bird.send("Hello")  // Prints "Hello"
///
/// verify(bird.send(any(NSString.self))).wasCalled()
/// verify(bird.send(any(NSData.self))).wasNeverCalled()
/// ```
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func any<T: NSObjectProtocol>(_ type: T.Type = T.self) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>() (Obj-C)",
                                declaration: "any()",
                                priority: .high) { (_, rhs) in
    return rhs is T || rhs is NonEscapingType
  }
  return MKBTypeFacade(mock: MKBMock(T.self), object: matcher).fixupType()
}

/// Matches argument values equal to any of the provided values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(of:)` to match `Equatable` argument values equal to one or more of
/// the specified values.
///
/// ```swift
/// given(bird.canChirp(volume: any(of: 1, 3)))
///   .willReturn(true)
///
/// given(bird.canChirp(volume: any(of: 2, 4)))
///   .willReturn(false)
///
/// print(bird.canChirp(volume: 1))  // Prints "true"
/// print(bird.canChirp(volume: 2))  // Prints "false"
/// print(bird.canChirp(volume: 3))  // Prints "true"
/// print(bird.canChirp(volume: 4))  // Prints "false"
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ message: T)    // Overloaded generically
///   func send(_ message: String)  // Overloaded explicitly
///   func send(_ message: Data)
/// }
///
/// given(bird.send(any(String.self, of: "Hi", "Hello")))
///   .will { print($0) }
///
/// bird.send("Hi")     // Prints "Hi"
/// bird.send("Hello")  // Prints "Hello"
/// bird.send("Bye")    // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - objects: A set of equatable objects that should result in a match.
public func any<T: Equatable>(_ type: T.Type = T.self, of objects: T...) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>(of: [\(objects.count)])",
                                declaration: "any(of: …)",
                                priority: .high) { (_, rhs) in
    guard let other = rhs as? T else { return false }
    return objects.contains(where: { $0 == other })
  }
  return createTypeFacade(matcher)
}

/// Matches argument values identical to any of the provided values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(of:)` to match class instances by identity.
///
/// - Note: Only objects that don’t conform to `Equatable` are compared by reference.
///
/// ```swift
/// // Reference type
/// class Location {
///   let name: String
///   init(_ name: String) { self.name = name }
/// }
///
/// protocol Bird {
///   func fly(to location: Location)
/// }
///
/// let home = Location("Home")
/// let work = Location("Work")
/// given(bird.fly(to: any(of: home, work)))
///   .will { print($0.name) }
///
/// bird.fly(to: home)  // Prints "Home"
/// bird.fly(to: work)  // Prints "Work"
///
/// let hawaii = Location("Hawaii")
/// bird.fly(to: hawaii))  // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func fly<T>(to location: T)        // Overloaded generically
///   func fly(to location: Location)    // Overloaded explicitly
///   func fly(to locationName: String)
/// }
///
/// given(bird.fly(to: any(String.self, of: "Home", "Work")))
///   .will { print($0) }
///
/// bird.send("Home")    // Prints "Hi"
/// bird.send("Work")    // Prints "Hello"
/// bird.send("Hawaii")  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - objects: A set of reference type objects that should result in a match.
public func any<T: AnyObject>(_ type: T.Type = T.self, of objects: T...) -> T {
  let matcher = ArgumentMatcher(
    nil as T?,
    description: "any<\(T.self)>(of: [\(objects.count)]) (by reference)",
    declaration: "any(of: …)",
    priority: .high) { (_, rhs) in
    return objects.contains(where: { $0 as AnyObject === rhs as AnyObject })
  }
  return createTypeFacade(matcher)
}

/// Matches any argument values where the predicate returns `true`.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(where:)` to match objects with custom equality logic. This is
/// particularly useful for parameter types that do not conform to `Equatable`.
///
/// ```swift
/// // Value type not explicitly conforming to `Equatable`
/// struct Fruit {
///   let size: Int
/// }
///
/// protocol Bird {
///   func eat(_ fruit: Fruit)
/// }
///
/// given(bird.eat(any(where: { $0.size < 100 })))
///   .will { print($0.size) }
///
/// let apple = Fruit(size: 42)
/// bird.eat(apple)  // Prints "42"
///
/// let pear = Fruit(size: 9001)
/// bird.eat(pear)   // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func eat<T>(_ object: T)     // Overloaded generically
///   func eat(_ fruit: Fruit)     // Overloaded explicitly
///   func eat(_ fruits: [Fruit])
/// }
///
/// given(bird.eat(any(Fruit.self, where: { $0.size < 100 })))
///   .will { print($0) }
///
/// let apple = Fruit(size: 42)
/// bird.eat(apple)    // Prints "42"
/// bird.eat("Apple")  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - predicate: A closure that takes a value and returns `true` if it represents a match.
public func any<T>(_ type: T.Type = T.self, where predicate: @escaping (_ value: T) -> Bool) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>(where:)",
                                declaration: "any(where: …)",
                                priority: .high) { (_, rhs) in
    guard let rhs = rhs as? T else { return false }
    return predicate(rhs)
  }
  return createTypeFacade(matcher)
}

/// Matches any Objective-C object argument values where the predicate returns `true`.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(where:)` to match objects with custom equality logic. This is
/// particularly useful for parameter types that do not conform to `Equatable`.
///
/// ```swift
/// // Non-equatable class subclassing `NSObject`
/// class Fruit: NSObject {
///   let size: Int
///   init(size: Int) { self.size = size }
/// }
///
/// protocol Bird {
///   func eat(_ fruit: Fruit)
/// }
///
/// given(bird.eat(any(where: { $0.size < 100 })))
///   .will { print($0.size) }
///
/// let apple = Fruit(size: 42)
/// bird.eat(apple)  // Prints "42"
///
/// let pear = Fruit(size: 9001)
/// bird.eat(pear)   // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func eat<T: NSObject>(_ object: T)  // Overloaded generically
///   func eat(_ fruit: Fruit)            // Overloaded explicitly
///   func eat(_ fruits: [Fruit])
/// }
///
/// given(bird.eat(any(Fruit.self, where: { $0.size < 100 })))
///   .will { print($0) }
///
/// let apple = Fruit(size: 42)
/// bird.eat(apple)    // Prints "42"
/// bird.eat("Apple")  // Error: Missing stubbed implementation
/// ```
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - predicate: A closure that takes a value and returns `true` if it represents a match.
public func any<T: NSObjectProtocol>(_ type: T.Type = T.self,
                                     where predicate: @escaping (_ value: T) -> Bool) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "any<\(T.self)>(where:) (Obj-C)",
                                declaration: "any(where: …)",
                                priority: .high) { (_, rhs) in
    guard let rhs = rhs as? T else { return false }
    return predicate(rhs)
  }
  return MKBTypeFacade<T>(mock: MKBMock(T.self), object: matcher).fixupType()
}

/// Matches any non-nil argument value.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `notNil` to match non-nil argument values.
///
/// ```swift
/// protocol Bird {
///   func send(_ message: String?)
/// }
///
/// given(bird.send(notNil())).will { print($0) }
///
/// bird.send("Hello")  // Prints Optional("Hello")
/// bird.send(nil)      // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// protocol Bird {
///   func send<T>(_ message: T?)    // Overloaded generically
///   func send(_ message: String?)  // Overloaded explicitly
///   func send(_ messages: Data?)
/// }
///
/// given(bird.send(notNil(String?.self)))
///   .will { print($0) }
///
/// bird.send("Hello")  // Prints Optional("Hello")
/// bird.send(nil)      // Error: Missing stubbed implementation
/// ```
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func notNil<T>(_ type: T.Type = T.self) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "notNil<\(T.self)>()",
                                declaration: "notNil()",
                                priority: .high) { (_, rhs) in
    return (rhs is T || rhs is NonEscapingType) && rhs != nil
  }
  return createTypeFacade(matcher)
}

/// Matches any non-nil Objective-C object argument value.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `notNil` to match non-nil argument values.
///
/// ```swift
/// // Protocol referencing Obj-C object types
/// protocol Bird {
///   func send(_ message: NSString?)
/// }
///
/// given(bird.send(notNil())).will { print($0) }
///
/// bird.send("Hello")  // Prints Optional("Hello")
/// bird.send(nil)      // Error: Missing stubbed implementation
/// ```
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
/// ```swift
/// // Protocol referencing Obj-C object types
/// protocol Bird {
///   func send<T: NSObject>(_ message: T?)  // Overloaded generically
///   func send(_ message: NSString?)        // Overloaded explicitly
///   func send(_ messages: NSData?)
/// }
///
/// given(bird.send(notNil(NSString?.self)))
///   .will { print($0) }
///
/// bird.send("Hello")  // Prints Optional("Hello")
/// bird.send(nil)      // Error: Missing stubbed implementation
/// ```
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func notNil<T: NSObjectProtocol>(_ type: T.Type = T.self) -> T {
  let matcher = ArgumentMatcher(nil as T?,
                                description: "notNil<\(T.self)>() (Obj-C)",
                                declaration: "notNil()",
                                priority: .high) { (_, rhs) in
    return (rhs is T || rhs is NonEscapingType) && rhs != nil
  }
  return createTypeFacade(matcher)
}
