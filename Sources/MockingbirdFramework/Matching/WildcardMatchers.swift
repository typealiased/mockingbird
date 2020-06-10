//
//  WildcardMatchers.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 5/31/20.
//

import Foundation

/// Matches all argument values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the wildcard argument matcher `any` as a type safe placeholder for matching any argument
/// value.
///
///     given(bird.canChirp(volume: any())).willReturn(true)
///     given(bird.setName(any())).will { print($0) }
///
///     print(bird.canChirp(volume: 10))  // Prints "true"
///     bird.name = "Ryan"  // Prints "Ryan"
///
///     verify(bird.canChirp(volume: any())).wasCalled()
///     verify(bird.setName(any())).wasCalled()
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
///     protocol Bird {
///       func send<T>(_ message: T)    // Overloaded generically
///       func send(_ message: String)  // Overloaded explicitly
///       func send(_ message: Data)
///     }
///
///     given(bird.send(any(String.self))).will { print($0) }
///
///     bird.send("Hello")  // Prints "Hello"
///
///     verify(bird.send(any(String.self))).wasCalled()
///     verify(bird.send(any(Data.self))).wasNeverCalled()
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func any<T>(_ type: T.Type = T.self) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>()"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    return rhs is T || rhs is NonEscapingType
  }
  return createTypeFacade(matcher)
}

/// Matches argument values equal to any of the provided values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(of:)` to match `Equatable` argument values equal to one or more of
/// the specified values.
///
///     given(bird.canChirp(volume: any(of: 1, 3)))
///       .willReturn(true)
///
///     given(bird.canChirp(volume: any(of: 2, 4)))
///       .willReturn(false)
///
///     print(bird.canChirp(volume: 1))  // Prints "true"
///     print(bird.canChirp(volume: 2))  // Prints "false"
///     print(bird.canChirp(volume: 3))  // Prints "true"
///     print(bird.canChirp(volume: 4))  // Prints "false"
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
///     protocol Bird {
///       func send<T>(_ message: T)    // Overloaded generically
///       func send(_ message: String)  // Overloaded explicitly
///       func send(_ message: Data)
///     }
///
///     given(bird.send(any(String.self, of: "Hi", "Hello")))
///       .will { print($0) }
///
///     bird.send("Hi")     // Prints "Hi"
///     bird.send("Hello")  // Prints "Hello"
///     bird.send("Bye")    // Error: Missing stubbed implementation
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - objects: A set of equatable objects that should result in a match.
public func any<T: Equatable>(_ type: T.Type = T.self, of objects: T...) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(of: [\(objects)])"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    guard let other = rhs as? T else { return false }
    return objects.contains(where: { $0 == other })
  }
  return createTypeFacade(matcher)
}

/// Matches argument values identical to any of the provided values.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `any(of:)` to match objects identical to one or more of the specified
/// values.
///
///     // Reference type
///     class Location {
///       let name: String
///       init(name: String) { self.name = name }
///     }
///
///     protocol Bird {
///       func fly(to location: Location)
///     }
///
///     let home = Location(name: "Home")
///     let work = Location("Work")
///     given(bird.fly(to: any(of: home, work)))
///       .will { print($0.name) }
///
///     bird.fly(to: home)  // Prints "Home"
///     bird.fly(to: work)  // Prints "Work"
///
///     let hawaii = Location("Hawaii")
///     bird.fly(to: hawaii))  // Error: Missing stubbed implementation
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
///     protocol Bird {
///       func fly<T>(to location: T)        // Overloaded generically
///       func fly(to location: Location)    // Overloaded explicitly
///       func fly(to locationName: String)
///     }
///
///     given(bird.fly(to: any(String.self, of: "Home", "Work")))
///       .will { print($0) }
///
///     bird.send("Home")    // Prints "Hi"
///     bird.send("Work")    // Prints "Hello"
///     bird.send("Hawaii")  // Error: Missing stubbed implementation
///
/// - Note: Objects are compared by reference.
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - objects: A set of non-equatable objects that should result in a match.
public func any<T: AnyObject>(_ type: T.Type = T.self, of objects: T...) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(of: [\(objects)]) (by reference)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
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
///     // Value type not explicitly conforming to `Equatable`
///     struct Fruit {
///       let size: Int
///     }
///
///     protocol Bird {
///       func eat(_ fruit: Fruit)
///     }
///
///     given(bird.eat(any(where: { $0.size < 100 })))
///       .will { print($0.size) }
///
///     let apple = Fruit(size: 42)
///     bird.eat(apple)  // Prints "42"
///
///     let pear = Fruit(size: 9001)
///     bird.eat(pear)   // Error: Missing stubbed implementation
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
///     protocol Bird {
///       func eat<T>(_ object: T)     // Overloaded generically
///       func eat(_ fruit: Fruit)     // Overloaded explicitly
///       func eat(_ fruits: [Fruit])
///     }
///
///     given(bird.eat(any(Fruit.self, where: { $0.size < 100 })))
///       .will { print($0) }
///
///     let apple = Fruit(size: 42)
///     bird.eat(apple)    // Prints "42"
///     bird.eat("Apple")  // Error: Missing stubbed implementation
///
/// - Parameters:
///   - type: The parameter type used to disambiguate overloaded methods.
///   - predicate: A closure that takes a value and returns `true` if it represents a match.
public func any<T>(_ type: T.Type = T.self, where predicate: @escaping (_ value: T) -> Bool) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(where:)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    guard let rhs = rhs as? T else { return false }
    return predicate(rhs)
  }
  return createTypeFacade(matcher)
}

/// Matches any non-nil argument value.
///
/// Argument matching allows you to stub or verify specific invocations of parameterized methods.
/// Use the argument matcher `notNil` to match non-nil argument values.
///
///     protocol Bird {
///       func send(_ message: String?)
///     }
///
///     given(bird.send(notNil())).will { print($0) }
///
///     bird.send("Hello")  // Prints Optional("Hello")
///     bird.send(nil)      // Error: Missing stubbed implementation
///
/// Methods overloaded by parameter type can be disambiguated by explicitly specifying the type.
///
///     protocol Bird {
///       func send<T>(_ message: T?)    // Overloaded generically
///       func send(_ message: String?)  // Overloaded explicitly
///       func send(_ messages: Data?)
///     }
///
///     given(bird.send(notNil(String?.self)))
///       .will { print($0) }
///
///     bird.send("Hello")    // Prints Optional("Hello")
///     bird.send(nil)        // Error: Missing stubbed implementation
///
/// - Parameter type: The parameter type used to disambiguate overloaded methods.
public func notNil<T>(_ type: T.Type = T.self) -> T {
  let base: T? = nil
  let description = "notNil<\(T.self)>()"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    return (rhs is T || rhs is NonEscapingType) && rhs != nil
  }
  return createTypeFacade(matcher)
}
