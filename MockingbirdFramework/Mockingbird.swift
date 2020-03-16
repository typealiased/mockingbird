//
//  Mockingbird.swift
//  BirdMockingbirdExample
//
//  Created by Andrew Chang on 7/26/19.
//

import Foundation
import XCTest

// MARK: - Stubbing

/// Stub mock objects with the same function signature to return a value or perform an operation.
///
/// - Parameter stubbable: A set of stubbable invocations.
public func given<T, I, R>(_ stubbable: Mockable<T, I, R>...) -> Stub<I, R> {
  return Stub<I, R>(from: stubbable)
}

/// Stubs a variable getter to return the last value received by the setter.
///
/// - Parameter initial: The initial value to return.
public func lastSetValue<T, R>(initial: R) -> StubImplementation<T, R> {
  var currentValue = initial
  let implementation: () -> R = { return currentValue }
  let callback = { (stub: StubbingContext.Stub, context: StubbingContext) in
    guard let setterInvocation = stub.invocation.toSetter() else { return }
    let setterImplementation = { (newValue: R) -> Void in
      currentValue = newValue
    }
    _ = context.swizzle(setterInvocation, with: setterImplementation)
  }
  return StubImplementation(handler: implementation as! T, callback: callback)
}

// MARK: - Verification

/// Verify that a mock recieved a specific invocation some number of times.
///
/// - Parameters:
///   - mock: A mockable invocation to verify.
public func verify<T, I, R>(file: StaticString = #file, line: UInt = #line,
                            _ mockable: Mockable<T, I, R>) -> Verification<I, R> {
  return Verification(with: mockable, at: SourceLocation(file, line))
}

/// Enforce the relative order of invocations verified within the scope of `block`.
///
/// - Parameters:
///   - options: Options to use when verifying invocations.
///   - block: A block containing ordered verification calls.
public func inOrder(file: StaticString = #file, line: UInt = #line,
                    with options: OrderedVerificationOptions = [],
                    _ block: () -> Void) {
  createOrderedContext(at: SourceLocation(file, line), options: options, block: block)
}

/// Create a deferrable test expectation from a block containing verification calls.
///
/// - Parameters:
///   - description: An optional description for the created `XCTestExpectation`.
///   - block: A block containing verification calls.
/// - Returns: An XCTestExpectation that fulfilles once all verifications in the block are met.
public func eventually(_ description: String? = nil,
                       _ block: () -> Void) -> XCTestExpectation {
  return createAsyncContext(description: description, block: block)
}

// MARK: - Expectation resetting

/// Remove all observed invocations _and_ stubbed implementations on a set of mocks.
///
/// - Parameter mocks: A set of mocks to reset.
public func reset<M: Mock>(_ mocks: M...) {
  mocks.forEach({
    $0.mockingContext.clearInvocations()
    $0.stubbingContext.clearStubs()
  })
}

/// Remove all observed invocations on a set of mocks.
///
/// - Parameter mocks: A set of mocks to reset.
public func clearInvocations<M: Mock>(on mocks: M...) {
  mocks.forEach({ $0.mockingContext.clearInvocations() })
}

/// Remove all stubbed implementations on a set of mocks.
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs<M: Mock>(on mocks: M...) {
  mocks.forEach({ $0.stubbingContext.clearStubs() })
}

// MARK: - Standard argument matchers

/// Matches any argument value of a specific type `T`.
///
/// - Parameter type: Optionally provide an explicit type to disambiguate overloaded methods.
public func any<T>(_ type: T.Type = T.self) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>()"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    return rhs is T || rhs is NonEscapingClosureProtocol
  }
  return createTypeFacade(matcher)
}

/// Matches any of the provided values by equality.
///
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
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

/// Matches any of the provided values by reference.
///
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
///   - objects: A set of non-equatable objects that should result in a match.
public func any<T>(_ type: T.Type = T.self, of objects: T...) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(of: [\(objects)]) (by reference)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    return objects.contains(where: { $0 as AnyObject === rhs as AnyObject })
  }
  return createTypeFacade(matcher)
}

/// Matches any values where the predicate returns `true`.
///
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
///   - predicate: A closure that takes a value `T` and returns `true` if it represents a match.
public func any<T>(_ type: T.Type = T.self, where predicate: @escaping (_ value: T) -> Bool) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(where:)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    guard let rhs = rhs as? T else { return false }
    return predicate(rhs)
  }
  return createTypeFacade(matcher)
}

/// Matches any non-nil argument value of a specific type `T`.
///
/// - Parameter type: Optionally provide an explicit type to disambiguate overloaded methods.
public func notNil<T>(_ type: T.Type = T.self) -> T {
  let base: T? = nil
  let description = "notNil<\(T.self)>()"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    return (rhs is T || rhs is NonEscapingClosureProtocol) && rhs != nil
  }
  return createTypeFacade(matcher)
}

// MARK: Collection matchers

/// Matches any collection containing all of the values.
///
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
///   - values: A set of concrete values to look for in the collection.
public func any<T: Collection>(_ type: T.Type = T.self, containing values: T.Element...) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(containing:)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
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
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
///   - values: A set of concrete values to look for in the dictionary.
public func any<K, V>(_ type: Dictionary<K, V>.Type = Dictionary<K, V>.self,
                      containing values: V...) -> Dictionary<K, V> {
  let base: Dictionary<K, V>? = nil
  let description = "any<\(Dictionary<K, V>.self)>(containing:)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
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
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
///   - keys: A set of concrete keys to look for in the dictionary.
public func any<K, V>(_ type: Dictionary<K, V>.Type = Dictionary<K, V>.self,
                      keys: K...) -> Dictionary<K, V> {
  let base: Dictionary<K, V>? = nil
  let description = "any<\(Dictionary<K, V>.self)>(keys:)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    guard let collection = rhs as? Dictionary<K, V> else { return false }
    return keys.allSatisfy({
      let keyMatcher = ArgumentMatcher($0)
      return collection.contains(where: { keyMatcher == ArgumentMatcher($0.key) })
    })
  }
  return createTypeFacade(matcher)
}

/// Matches any collection with a specific number of elements defined by a count matcher.
///
/// - Parameters:
///   - type: Optionally provide an explicit type to disambiguate overloaded methods.
///   - countMatcher: A count matcher defining the number of acceptable elements in the collection.
public func any<T: Collection>(_ type: T.Type = T.self, count countMatcher: CountMatcher) -> T {
  let base: T? = nil
  let description = "any<\(T.self)>(count:)"
  let matcher = ArgumentMatcher(base, description: description, priority: .high) { (_, rhs) in
    guard let collection = rhs as? T else { return false }
    return countMatcher.matches(UInt(collection.count))
  }
  return createTypeFacade(matcher)
}

/// Matches any collection with at least one element.
///
/// - Parameter type: Optionally provide an explicit type to disambiguate overloaded methods.
public func notEmpty<T: Collection>(_ type: T.Type = T.self) -> T {
  return any(count: atLeast(1))
}

// MARK: Floating point matchers

/// Matches floating point arguments within some tolerance.
///
/// - Parameters:
///   - value: The expected value.
///   - tolerance: Only matches if the absolute difference is strictly less than this value.
public func around<T: FloatingPoint>(_ value: T, tolerance: T) -> T {
  let description = "around<\(T.self)>()"
  let matcher = ArgumentMatcher(value, description: description, priority: .high) { (lhs, rhs) in
    guard let base = lhs as? T, let other = rhs as? T else { return false }
    return abs(other - base) < tolerance
  }
  return createTypeFacade(matcher)
}

// MARK: - Nominal count matchers

/// A count of zero.
public let never: UInt = 0

/// A count of one.
public let once: UInt = 1

/// A count of two.
public let twice: UInt = 2

// MARK: - Standard count matchers

/// Matches an exact count.
public func exactly(_ times: UInt) -> CountMatcher {
  return CountMatcher({ $0 == times }, describedBy: { "n \($1 ? "≠" : "=") \(times)" })
}

/// Matches greater than or equal to some count.
public func atLeast(_ times: UInt) -> CountMatcher {
  return CountMatcher({ $0 >= times }, describedBy: { "n \($1 ? "<" : "≥") \(times)" })
}

/// Matches less than or equal to some count.
public func atMost(_ times: UInt) -> CountMatcher {
  return CountMatcher({ $0 <= times }, describedBy: { "n \($1 ? ">" : "≤") \(times)" })
}

/// Matches counts that fall within a certain inclusive range.
public func between(_ range: Range<UInt>) -> CountMatcher {
  return atLeast(range.lowerBound).and(atMost(range.upperBound))
}

// MARK: Composing multiple count matchers
extension CountMatcher {
  public func or(_ countMatcher: CountMatcher) -> CountMatcher {
    let matcherCopy = self
    let otherMatcherCopy = countMatcher
    return CountMatcher({ matcherCopy.matcher($0) || otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, negated: $1)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, negated: $1)
        let operand = $1 ? "&&" : "||"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
  
  public func or(_ times: UInt) -> CountMatcher { return or(exactly(times)) }

  public func and(_ countMatcher: CountMatcher) -> CountMatcher {
    let matcherCopy = self
    let otherMatcherCopy = countMatcher
    return CountMatcher({ matcherCopy.matcher($0) && otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, negated: $1)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, negated: $1)
        let operand = $1 ? "||" : "&&"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
  
  public func and(_ times: UInt) -> CountMatcher { return and(exactly(times)) }

  public func xor(_ countMatcher: CountMatcher) -> CountMatcher {
    let matcherCopy = self
    let otherMatcherCopy = countMatcher
    return CountMatcher({ matcherCopy.matcher($0) != otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, negated: $1)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, negated: $1)
        let operand = $1 ? "≠" : "="
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
  
  public func xor(_ times: UInt) -> CountMatcher { return xor(exactly(times)) }
}

public func not(_ countMatcher: CountMatcher) -> CountMatcher {
  let matcherCopy = countMatcher
  return CountMatcher({ !matcherCopy.matcher($0) },
    describedBy: {
      let matcherDescription = matcherCopy.describe(invocation: $0, negated: !$1)
      return "\(matcherDescription)"
  })
}

public func not(_ times: UInt) -> CountMatcher { return not(exactly(times)) }
