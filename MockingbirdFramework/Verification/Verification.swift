//
//  MockingbirdVerification.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

struct MockingbirdSourceLocation {
  let file: StaticString
  let line: UInt
  init(_ file: StaticString, _ line: UInt) {
    self.file = file
    self.line = line
  }
}

/// Intermediate verification object.
public struct Verification: RunnableScope {
  let uuid = UUID()
  let sourceLocation: MockingbirdSourceLocation

  private let runnable: () -> Any?

  init(_ runnable: @escaping () -> Any?, at sourceLocation: MockingbirdSourceLocation) {
    self.runnable = runnable
    self.sourceLocation = sourceLocation
  }

  public func wasCalled(_ callMatcher: CallMatcher = once) {
    verify(self, using: callMatcher, for: sourceLocation)
  }

  public func wasNeverCalled() {
    verify(self, using: never, for: sourceLocation)
  }

  func run() -> Any? { return runnable() }
}

struct Expectation {
  static let verificationScopeKey = DispatchSpecificKey<Expectation>()
  static let asyncGroupKey = DispatchSpecificKey<AsyncExpectationGroup>()
  
  let callMatcher: CallMatcher
  let sourceLocation: MockingbirdSourceLocation
  let asyncGroup: AsyncExpectationGroup?
  
  func copy(withAsyncGroup: Bool = false) -> Expectation {
    return Expectation(callMatcher: callMatcher,
                                  sourceLocation: sourceLocation,
                                  asyncGroup: withAsyncGroup ? asyncGroup : nil)
  }
}

/// Defers expectations until an invocation arrives later.
struct AsyncExpectation {
  let mockingContext: MockingContext
  let invocation: Invocation
  let expectation: Expectation
}
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

internal func verify(_ verificationScope: Verification,
                     using callMatcher: CallMatcher,
                     for sourceLocation: MockingbirdSourceLocation) {
  let queue = DispatchQueue(label: "co.bird.mockingbird.verification-scope")
  let expectation = Expectation(callMatcher: callMatcher,
                                sourceLocation: sourceLocation,
                                asyncGroup: DispatchQueue.currentAsyncGroup)
  queue.setSpecific(key: Expectation.verificationScopeKey, value: expectation)
  _ = queue.sync { verificationScope.run() }
}

internal func createTestExpectation(with scope: () -> Void,
                                    description: String?) -> XCTestExpectation {
  let asyncGroup = AsyncExpectationGroup()
  let queue = DispatchQueue(label: "co.bird.mockingbird.async-verification-scope")
  queue.setSpecific(key: Expectation.asyncGroupKey, value: asyncGroup)
  queue.sync { scope() }
  
  let testExpectation = XCTestExpectation(description: description ?? "Async verification group")
  testExpectation.expectedFulfillmentCount = asyncGroup.expectations.count
  asyncGroup.expectations.forEach({ asyncExpectation in
    let observer = MockingbirdInvocationObserver({ (invocation, mockingContext) -> Bool in
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
internal func expect(_ mockingContext: MockingContext,
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
