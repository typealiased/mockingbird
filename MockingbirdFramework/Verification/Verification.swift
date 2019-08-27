//
//  MockingbirdVerification.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// References a line of code in a file.
struct SourceLocation {
  let file: StaticString
  let line: UInt
  init(_ file: StaticString, _ line: UInt) {
    self.file = file
    self.line = line
  }
}

/// Intermediate verification object.
public struct Verification<T>: RunnableScope {
  let uuid = UUID()
  let sourceLocation: SourceLocation

  private let runnable: () -> Any?

  init(_ runnable: @escaping () -> Any?, at sourceLocation: SourceLocation) {
    self.runnable = runnable
    self.sourceLocation = sourceLocation
  }
  
  func run() -> Any? { return runnable() }

  /// Verify that the mock received the invocation some number of times.
  ///
  /// - Parameter callMatcher: A call matcher defining the number of invocations to verify.
  public func wasCalled(_ callMatcher: CallMatcher = once) {
    verify(using: callMatcher, for: sourceLocation)
  }

  /// Verify that the mock never received the invocation.
  public func wasNeverCalled() {
    verify(using: never, for: sourceLocation)
  }
  
  /// Disambiguate methods overloaded by return type.
  ///
  /// - Parameter type: The return type of the method.
  public func returning(_ type: T.Type = T.self) -> Verification<T> {
    return self
  }
  
  /// Runs the block within an attributed `DispatchQueue`.
  func verify(using callMatcher: CallMatcher, for sourceLocation: SourceLocation) {
    let queue = DispatchQueue(label: "co.bird.mockingbird.verification-scope")
    let expectation = Expectation(callMatcher: callMatcher,
                                  sourceLocation: sourceLocation,
                                  asyncGroup: DispatchQueue.currentAsyncGroup)
    queue.setSpecific(key: Expectation.verificationScopeKey, value: expectation)
    _ = queue.sync { self.run() }
  }
}

/// Packages a call matcher and its call site. Used by verification methods in attributed scopes.
struct Expectation {
  static let verificationScopeKey = DispatchSpecificKey<Expectation>()
  static let asyncGroupKey = DispatchSpecificKey<AsyncExpectationGroup>()
  
  let callMatcher: CallMatcher
  let sourceLocation: SourceLocation
  let asyncGroup: AsyncExpectationGroup?
  
  func copy(withAsyncGroup: Bool = false) -> Expectation {
    return Expectation(callMatcher: callMatcher,
                       sourceLocation: sourceLocation,
                       asyncGroup: withAsyncGroup ? asyncGroup : nil)
  }
}

/// A deferred expectation that can be fulfilled when an invocation arrives later.
struct AsyncExpectation {
  let mockingContext: MockingContext
  let invocation: Invocation
  let expectation: Expectation
}

/// Stores all expectations invoked by verification methods within an `eventually` scope.
class AsyncExpectationGroup {
  private(set) var expectations = [AsyncExpectation]()
  func addExpectation(_ expectation: AsyncExpectation) {
    expectations.append(expectation)
  }
}

extension DispatchQueue {
  class var currentExpectation: Expectation? {
    return DispatchQueue.getSpecific(key: Expectation.verificationScopeKey)
  }
  
  class var currentAsyncGroup: AsyncExpectationGroup? {
    return DispatchQueue.getSpecific(key: Expectation.asyncGroupKey)
  }
}

/// Internal helper for `eventually` async verification scopes.
///   1. Creates an attributed `DispatchQueue` scope which collects all verifications.
///   2. Observes invocations on each mock and fulfills the test expectation if there is a match.
func createTestExpectation(with scope: () -> Void, description: String?) -> XCTestExpectation {
  let asyncGroup = AsyncExpectationGroup()
  let queue = DispatchQueue(label: "co.bird.mockingbird.async-verification-scope")
  queue.setSpecific(key: Expectation.asyncGroupKey, value: asyncGroup)
  queue.sync { scope() }
  
  let testExpectation = XCTestExpectation(description: description ?? "Async verification group")
  testExpectation.expectedFulfillmentCount = asyncGroup.expectations.count
  asyncGroup.expectations.forEach({ asyncExpectation in
    let observer = InvocationObserver({ (invocation, mockingContext) -> Bool in
      let allInvocations = mockingContext.invocations(for: asyncExpectation.invocation.selectorName)
        .filter({ $0 == asyncExpectation.invocation })
      let actualCallCount = UInt(allInvocations.count)
      guard asyncExpectation.expectation.callMatcher.matches(actualCallCount) else { return false }
      testExpectation.fulfill()
      return true
    })
    asyncExpectation.mockingContext.addObserver(observer,
                                                for: asyncExpectation.invocation.selectorName)
  })
  return testExpectation
}

/// Used by generated mocks to verify invocations with a call matcher.
func expect(_ mockingContext: MockingContext,
            handled invocation: Invocation,
            using expectation: Expectation) {
  if let asyncGroup = expectation.asyncGroup {
    let asyncExpectation = AsyncExpectation(mockingContext: mockingContext,
                                            invocation: invocation,
                                            expectation: expectation.copy())
    asyncGroup.addExpectation(asyncExpectation)
    return
  }
  
  let allInvocations =
    mockingContext.invocations(for: invocation.selectorName).filter({ $0 == invocation })
  let actualCallCount = UInt(allInvocations.count)
  guard !expectation.callMatcher.matches(actualCallCount) else { return }
  let description = expectation.callMatcher.describe(invocation: invocation, count: actualCallCount)
  let failure = TestFailure.incorrectInvocationCount(invocation: invocation,
                                                     description: description)
  XCTFail(String(describing: failure),
          file: expectation.sourceLocation.file,
          line: expectation.sourceLocation.line)
}
