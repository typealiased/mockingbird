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
  static let dispatchQueueKey = DispatchSpecificKey<MockingbirdExpectation>()
  let callMatcher: MockingbirdCallMatcher
  let sourceLocation: MockingbirdSourceLocation
}

extension DispatchQueue {
  class var currentExpectation: MockingbirdExpectation? {
    return DispatchQueue.getSpecific(key: MockingbirdExpectation.dispatchQueueKey)
  }
}

internal func verify(_ verificationScope: MockingbirdVerificationScope,
                     using callMatcher: MockingbirdCallMatcher,
                     for sourceLocation: MockingbirdSourceLocation) {
  let queue = DispatchQueue(label: "co.bird.mockingbird.verification-scope")
  let expectation = MockingbirdExpectation(callMatcher: callMatcher, sourceLocation: sourceLocation)
  queue.setSpecific(key: MockingbirdExpectation.dispatchQueueKey, value: expectation)
  _ = queue.sync { verificationScope.run() }
}

/// Used by generated mocks to verify invocations with a call matcher.
internal func expect(
  _ mockingContext: MockingbirdMockingContext,
  handled invocation: MockingbirdInvocation,
  using expectation: MockingbirdExpectation) {
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
