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

public struct MockingbirdVerificationScope: MockingbirdRunnableScope {
  let uuid = UUID()
  let sourceLocation: MockingbirdSourceLocation

  private let runnable: () -> Any?

  init(_ runnable: @escaping () -> Any?, at sourceLocation: MockingbirdSourceLocation) {
    self.runnable = runnable
    self.sourceLocation = sourceLocation
  }

  public func wasCalled(_ callMatcher: MockingbirdCallMatcher = once) {
    verify(self, using: callMatcher, for: sourceLocation)
  }

  public func wasNeverCalled() {
    verify(self, using: never, for: sourceLocation)
  }

  func run() -> Any? { return runnable() }
}

struct MockingbirdExpectation {
  static let verificationScopeKey = DispatchSpecificKey<MockingbirdExpectation>()
  static let asyncGroupKey = DispatchSpecificKey<MockingbirdAsyncExpectationGroup>()
  
  let callMatcher: MockingbirdCallMatcher
  let sourceLocation: MockingbirdSourceLocation
  let asyncGroup: MockingbirdAsyncExpectationGroup?
  
  func copy(withAsyncGroup: Bool = false) -> MockingbirdExpectation {
    return MockingbirdExpectation(callMatcher: callMatcher,
                                  sourceLocation: sourceLocation,
                                  asyncGroup: withAsyncGroup ? asyncGroup : nil)
  }
}

/// Defers expectations until an invocation arrives later.
struct MockingbirdAsyncExpectation {
  let mockingContext: MockingbirdMockingContext
  let invocation: MockingbirdInvocation
  let expectation: MockingbirdExpectation
}
class MockingbirdAsyncExpectationGroup {
  private(set) var expectations = [MockingbirdAsyncExpectation]()
  func addExpectation(_ expectation: MockingbirdAsyncExpectation) {
    expectations.append(expectation)
  }
}

extension DispatchQueue {
  class var currentExpectation: MockingbirdExpectation? {
    return DispatchQueue.getSpecific(key: MockingbirdExpectation.verificationScopeKey)
  }
  
  class var currentAsyncGroup: MockingbirdAsyncExpectationGroup? {
    return DispatchQueue.getSpecific(key: MockingbirdExpectation.asyncGroupKey)
  }
}

internal func verify(_ verificationScope: MockingbirdVerificationScope,
                     using callMatcher: MockingbirdCallMatcher,
                     for sourceLocation: MockingbirdSourceLocation) {
  let queue = DispatchQueue(label: "co.bird.mockingbird.verification-scope")
  let expectation = MockingbirdExpectation(callMatcher: callMatcher,
                                           sourceLocation: sourceLocation,
                                           asyncGroup: DispatchQueue.currentAsyncGroup)
  queue.setSpecific(key: MockingbirdExpectation.verificationScopeKey, value: expectation)
  _ = queue.sync { verificationScope.run() }
}

internal func createTestExpectation(with scope: () -> Void,
                                    description: String?) -> XCTestExpectation {
  let asyncGroup = MockingbirdAsyncExpectationGroup()
  let queue = DispatchQueue(label: "co.bird.mockingbird.async-verification-scope")
  queue.setSpecific(key: MockingbirdExpectation.asyncGroupKey, value: asyncGroup)
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
internal func expect(
  _ mockingContext: MockingbirdMockingContext,
  handled invocation: MockingbirdInvocation,
  using expectation: MockingbirdExpectation) {
  if let asyncGroup = expectation.asyncGroup {
    let asyncExpectation = MockingbirdAsyncExpectation(mockingContext: mockingContext,
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
  let failure = MockingbirdTestFailure.incorrectInvocationCount(invocation: invocation,
                                                                description: description)
  XCTFail(String(describing: failure),
          file: expectation.sourceLocation.file,
          line: expectation.sourceLocation.line)
}
