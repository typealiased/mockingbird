//
//  Mockingbird.swift
//  BirdMockingbirdExample
//
//  Created by Andrew Chang on 7/26/19.
//

import Foundation

// MARK: - Stubbing

/// Convenience method to stub a single mock object.
///
/// - Parameter scope: A mock and its invocation to stub.
/// - Returns: An internal stubbing scope.
public func given<T>(_ scope: @escaping @autoclosure () -> MockingbirdScopedStub<T>)
  -> MockingbirdStubbingScope<T> {
    return MockingbirdStubbingScope<T>(scope)
}

/// Stub any number of mock objects.
///
/// - Note: This part of the DSL will likely improve once function builders are available.
///
/// - Parameter scope: A set of mocks and invocations to stub.
/// - Returns: An internal stubbing scope.
public func given<T>(_ scope: @escaping @autoclosure () -> [MockingbirdScopedStub<T>]) -> MockingbirdStubbingScope<T> {
    return MockingbirdStubbingScope<T>(scope)
}

// MARK: - Verification

/// Verify that a single mock recieved a specific invocation some number of times.
///
/// - Parameters:
///   - callMatcher: A call matcher defining the total number of invocations.
///   - scope: A mock and its invocation to verify.
public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope(scope, at: MockingbirdSourceLocation(file, line))
}

/// Verify that a set of mocks received invocations some number of times.
///
/// - Note: This part of the DSL will likely improve once function builders are available.
///
/// - Parameters:
///   - callMatcher: A call matcher defining the total number of invocations.
///   - scope: A set of mock and invocations to verify.
public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope: @escaping @autoclosure () -> [MockingbirdScopedMock]) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope(scope, at: MockingbirdSourceLocation(file, line))
}

// MARK: - Expectation resetting

/// Remove all observed invocations _and_ stubbed implementations on a set of mocks.
///
/// - Parameter mocks: A set of mocks to reset.
public func reset<M: MockingbirdMock>(_ mocks: M...) {
  mocks.forEach({
    $0.mockingContext.clearInvocations()
    $0.stubbingContext.clearStubs()
  })
}

/// Remove all observed invocations on a set of mocks.
///
/// - Parameter mocks: A set of mocks to reset.
public func clearInvocations<M: MockingbirdMock>(on mocks: M...) {
  mocks.forEach({ $0.mockingContext.clearInvocations() })
}

/// Remove all stubbed implementations on a set of mocks.
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs<M: MockingbirdMock>(on mocks: M...) {
  mocks.forEach({ $0.stubbingContext.clearStubs() })
}

// MARK: - Standard argument matchers

/// Matches any argument value of a specific type `T`.
public func any<T>() -> T {
  return createTypeFacade(MockingbirdMatcher(nil, description: "any()", true))
}

/// Matches any non-nil argument value of a specific type `T`.
public func notNil<T>() -> T {
  return createTypeFacade(MockingbirdMatcher(nil, description: "notNil()", { $1 != nil }))
}

// MARK: - Standard call matchers

/// Matches exactly the number of calls.
public func exactly(_ times: UInt) -> MockingbirdCallMatcher {
  return MockingbirdCallMatcher({ $0 == times },
                                describedBy: { "`\($1)` \($2 ? "≠" : "=") \(times)" })
}

/// Matches exactly a single call.
public var once: MockingbirdCallMatcher { return exactly(1) }

/// Matches no calls.
public var never: MockingbirdCallMatcher { return exactly(0) }

/// Matches greater than or equal to the number of calls.
public func atLeast(_ times: UInt) -> MockingbirdCallMatcher {
  return MockingbirdCallMatcher({ $0 >= times },
                                describedBy: { "`\($1)` \($2 ? "<" : "≥") \(times)" })
}

/// Matches less than or equal to the number of calls.
public func atMost(_ times: UInt) -> MockingbirdCallMatcher {
  return MockingbirdCallMatcher({ $0 <= times },
                                describedBy: { "`\($1)` \($2 ? ">" : "≤") \(times)" })
}

// MARK: Composing multiple call matchers
extension MockingbirdCallMatcher {
  public func or(_ callMatcher: MockingbirdCallMatcher) -> MockingbirdCallMatcher {
    let matcherCopy = self
    let otherMatcherCopy = callMatcher
    return MockingbirdCallMatcher({ matcherCopy.matcher($0) || otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let operand = $2 ? "&&" : "||"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }

  public func and(_ callMatcher: MockingbirdCallMatcher) -> MockingbirdCallMatcher {
    let matcherCopy = self
    let otherMatcherCopy = callMatcher
    return MockingbirdCallMatcher({ matcherCopy.matcher($0) && otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let operand = $2 ? "||" : "&&"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }

  public func xor(_ callMatcher: MockingbirdCallMatcher) -> MockingbirdCallMatcher {
    let matcherCopy = self
    let otherMatcherCopy = callMatcher
    return MockingbirdCallMatcher({ matcherCopy.matcher($0) != otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, count: $1, negated: $2)
        let operand = $2 ? "≠" : "="
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
}

public func not(_ callMatcher: MockingbirdCallMatcher) -> MockingbirdCallMatcher {
  let matcherCopy = callMatcher
  return MockingbirdCallMatcher({ !matcherCopy.matcher($0) },
    describedBy: {
      let matcherDescription = matcherCopy.describe(invocation: $0, count: $1, negated: !$2)
      return "\(matcherDescription)"
  })
}
