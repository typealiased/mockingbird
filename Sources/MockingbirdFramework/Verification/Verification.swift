//
//  MockingbirdVerification.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// Verify that a mock recieved a specific invocation some number of times.
///
/// Verification lets you assert that a mock received a particular invocation during its lifetime.
///
///     verify(bird.doMethod()).wasCalled()
///     verify(bird.getProperty()).wasCalled()
///     verify(bird.setProperty(any())).wasCalled()
///
/// Match exact or wildcard argument values when verifying methods with parameters.
///
///     verify(bird.canChirp(volume: any())).wasCalled()     // Called with any volume
///     verify(bird.canChirp(volume: notNil())).wasCalled()  // Called with any non-nil volume
///     verify(bird.canChirp(volume: 10)).wasCalled()        // Called with volume = 10
///
/// - Parameters:
///   - mock: A mocked declaration to verify.
public func verify<DeclarationType: Declaration, InvocationType, ReturnType>(
  _ declaration: Mockable<DeclarationType, InvocationType, ReturnType>,
  file: StaticString = #file, line: UInt = #line
) -> VerificationManager<InvocationType, ReturnType> {
  return VerificationManager(with: declaration, at: SourceLocation(file, line))
}

/// An intermediate object used for verifying declarations returned by `verify`.
public struct VerificationManager<InvocationType, ReturnType> {
  let mockingContext: MockingContext
  let invocation: Invocation
  let sourceLocation: SourceLocation

  init<DeclarationType>(with declaration: Mockable<DeclarationType, InvocationType, ReturnType>,
                        at sourceLocation: SourceLocation) {
    self.mockingContext = declaration.mock.mockingContext
    self.invocation = declaration.invocation
    self.sourceLocation = sourceLocation
  }

  /// Verify that the mock received the invocation some number of times using a count matcher.
  ///
  /// - Parameter countMatcher: A count matcher defining the number of invocations to verify.
  public func wasCalled(_ countMatcher: CountMatcher) {
    verify(using: countMatcher, for: sourceLocation)
  }
  
  /// Verify that the mock received the invocation an exact number of times.
  ///
  /// - Parameter times: The exact number of invocations expected.
  public func wasCalled(_ times: Int = once) {
    verify(using: exactly(times), for: sourceLocation)
  }

  /// Verify that the mock never received the invocation.
  public func wasNeverCalled() {
    verify(using: exactly(never), for: sourceLocation)
  }
  
  /// Disambiguate methods overloaded by return type.
  ///
  /// Declarations for methods overloaded by return type cannot type inference and should be
  /// disambiguated.
  ///
  ///     protocol Bird {
  ///       func getMessage<T>() throws -> T    // Overloaded generically
  ///       func getMessage() throws -> String  // Overloaded explicitly
  ///       func getMessage() throws -> Data
  ///     }
  ///
  ///     verify(bird.send(any()))
  ///       .returning(String.self)
  ///       .wasCalled()
  ///
  /// - Parameter type: The return type of the declaration to verify.
  public func returning(_ type: ReturnType.Type = ReturnType.self) -> Self {
    return self
  }
  
  /// Runs the block within an attributed `DispatchQueue`.
  func verify(using countMatcher: CountMatcher, for sourceLocation: SourceLocation) {
    let expectation = Expectation(countMatcher: countMatcher,
                                  sourceLocation: sourceLocation,
                                  group: DispatchQueue.currentExpectationGroup)
    do {
      try expect(mockingContext, handled: invocation, using: expectation)
    } catch {
      MKBFail(String(describing: error),
              file: expectation.sourceLocation.file,
              line: expectation.sourceLocation.line)
    }
  }
}

/// Wraps a call matcher and its call site. Used by verification methods in attributed scopes.
struct Expectation {
  let countMatcher: CountMatcher
  let sourceLocation: SourceLocation
  let group: ExpectationGroup?
  
  init(countMatcher: CountMatcher,
       sourceLocation: SourceLocation,
       group: ExpectationGroup?) {
    self.countMatcher = countMatcher
    self.sourceLocation = sourceLocation
    self.group = group
  }
  
  init(from other: Expectation, withGroup: Bool = false) {
    self.init(countMatcher: other.countMatcher,
              sourceLocation: other.sourceLocation,
              group: withGroup ? other.group : nil)
  }
}

/// Filters recorded invocations by upper and lower invocation bounds.
func findInvocations(in mockingContext: MockingContext,
                     with selectorName: String,
                     before nextInvocation: Invocation?,
                     after baseInvocation: Invocation?) -> [Invocation] {
  return mockingContext
    .invocations(with: selectorName)
    .filter({ invocation in
      var isBeforeNextInvocation: Bool {
        guard let nextInvocation = nextInvocation else { return true }
        return invocation < nextInvocation
      }
      var isAfterBaseInvocation: Bool {
        guard let baseInvocation = baseInvocation else { return true }
        return invocation > baseInvocation
      }
      return isBeforeNextInvocation && isAfterBaseInvocation
    })
}

/// Used by generated mocks to verify invocations with a call matcher.
@discardableResult
func expect(_ mockingContext: MockingContext,
            handled invocation: Invocation,
            using expectation: Expectation,
            before nextInvocation: Invocation? = nil,
            after baseInvocation: Invocation? = nil) throws -> [Invocation] {
  if let group = expectation.group {
    group.addExpectation(mockingContext: mockingContext,
                         invocation: invocation,
                         expectation: Expectation(from: expectation))
    return []
  }
  
  let allInvocations = findInvocations(in: mockingContext,
                                       with: invocation.selectorName,
                                       before: nextInvocation,
                                       after: baseInvocation)
  let allMatchingInvocations = allInvocations.filter({ $0 == invocation })
  
  let actualCallCount = allMatchingInvocations.count
  guard !expectation.countMatcher.matches(actualCallCount) else { return allInvocations }
  throw TestFailure.incorrectInvocationCount(invocationCount: actualCallCount,
                                             invocation: invocation,
                                             countMatcher: expectation.countMatcher,
                                             allInvocations: allInvocations)
}
