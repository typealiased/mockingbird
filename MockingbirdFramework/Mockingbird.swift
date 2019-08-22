//
//  Mockingbird.swift
//  BirdMockingbirdExample
//
//  Created by Andrew Chang on 7/26/19.
//

import Foundation
import XCTest

// MARK: - Stubbing

/// Stub a single mock object to return a value or perform an operation.
///
/// - Parameter mock: A mock and its invocation to stub.
public func given<T, R>(_ mock: @escaping @autoclosure () -> Stubbable<T, R>) -> Stub<T, R> {
    return Stub<T, R>(mock)
}

/// Stubs a variable getter to return the last value received by the setter.
///
/// - Parameter initial: The initial value to return.
public func lastSetValue<T, R>(initial: R) -> StubImplementation<T, R> {
  var currentValue = initial
  let implementation: () -> R = { return currentValue }
  let callback: StubbingRequest.StubbingCallback = { (stub, context) in
    guard let setterInvocation = stub.invocation.toSetter() else { return }
    let setterImplementation = { (newValue: R) -> Void in
      currentValue = newValue
    }
    context.swizzle(setterInvocation, with: setterImplementation)
  }
  return StubImplementation(handler: implementation as! T, callback: callback as AnyObject)
}

// MARK: - Verification

/// Verify that a single mock recieved a specific invocation some number of times.
///
/// - Parameters:
///   - callMatcher: A call matcher defining the total number of invocations.
///   - mock: A mock and its invocation to verify.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification(mock, at: SourceLocation(file, line))
}

/// Create a deferrable test expectation from a block containing verification calls.
///
/// - Parameters:
///   - description: An optional description for the created `XCTestExpectation`.
///   - block: A block containing verification calls.
/// - Returns: An XCTestExpectation that fulfilles once all verifications in the block are met.
public func eventually(_ description: String? = nil,
                       _ block: @escaping () -> Void) -> XCTestExpectation {
  return createTestExpectation(with: block, description: description)
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
/// - Parameter type: Provide an explicit type to help Swift disambiguate overloaded methods.
public func any<T>(type: T.Type = T.self) -> T {
  let matcher = ArgumentMatcher(nil, description: "any()", priority: .high, true)
  return createTypeFacade(matcher)
}

/// Matches any of the provided values by equality.
///
/// - Parameter objects: A set of equatable objects that should result in a match.
public func any<T: Equatable>(of objects: T...) -> T {
  let matcher = ArgumentMatcher(nil, description: "any(of:)", priority: .high) { (_, rhs) in
    guard let other = rhs as? T else { return false }
    return objects.contains(where: { $0 == other })
  }
  return createTypeFacade(matcher)
}

/// Matches any of the provided values by reference.
///
/// - Parameter objects: A set of non-equatable objects that should result in a match.
public func any<T>(of objects: T...) -> T {
  let matcher = ArgumentMatcher(nil, description: "any(of:) (by reference)", priority: .high) {
    (_, rhs) in
    return objects.contains(where: { $0 as AnyObject === rhs as AnyObject })
  }
  return createTypeFacade(matcher)
}

/// Matches any non-nil argument value of a specific type `T`.
public func notNil<T>() -> T {
  let matcher = ArgumentMatcher(nil, description: "notNil()", priority: .high, { $1 != nil })
  return createTypeFacade(matcher)
}

// MARK: - Standard call matchers

/// Matches exactly the number of calls.
public func exactly(_ times: UInt) -> CallMatcher {
  return CallMatcher({ $0 == times }, describedBy: { "`\($1)` \($2 ? "≠" : "=") \(times)" })
}

/// Matches exactly a single call.
public var once: CallMatcher { return exactly(1) }

/// Matches no calls.
public var never: CallMatcher { return exactly(0) }

/// Matches greater than or equal to the number of calls.
public func atLeast(_ times: UInt) -> CallMatcher {
  return CallMatcher({ $0 >= times }, describedBy: { "`\($1)` \($2 ? "<" : "≥") \(times)" })
}

/// Matches less than or equal to the number of calls.
public func atMost(_ times: UInt) -> CallMatcher {
  return CallMatcher({ $0 <= times }, describedBy: { "`\($1)` \($2 ? ">" : "≤") \(times)" })
}

/// Matches calls that fall within a certain inclusive range.
public func between(_ range: Range<UInt>) -> CallMatcher {
  return atLeast(range.lowerBound).and(atMost(range.upperBound))
}

// MARK: Composing multiple call matchers
extension CallMatcher {
  public func or(_ callMatcher: CallMatcher) -> CallMatcher {
    let matcherCopy = self
    let otherMatcherCopy = callMatcher
    return CallMatcher({ matcherCopy.matcher($0) || otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let operand = $2 ? "&&" : "||"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }

  public func and(_ callMatcher: CallMatcher) -> CallMatcher {
    let matcherCopy = self
    let otherMatcherCopy = callMatcher
    return CallMatcher({ matcherCopy.matcher($0) && otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let operand = $2 ? "||" : "&&"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }

  public func xor(_ callMatcher: CallMatcher) -> CallMatcher {
    let matcherCopy = self
    let otherMatcherCopy = callMatcher
    return CallMatcher({ matcherCopy.matcher($0) != otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let operand = $2 ? "≠" : "="
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
}

public func not(_ callMatcher: CallMatcher) -> CallMatcher {
  let matcherCopy = callMatcher
  return CallMatcher({ !matcherCopy.matcher($0) },
    describedBy: {
      let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: !$2)
      return "\(matcherDescription)"
  })
}
