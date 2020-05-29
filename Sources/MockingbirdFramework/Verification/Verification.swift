//
//  MockingbirdVerification.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// References a line of code in a file.
public struct SourceLocation {
  let file: StaticString
  let line: UInt
  init(_ file: StaticString, _ line: UInt) {
    self.file = file
    self.line = line
  }
}

/// Intermediate verification object.
public struct Verification<I, R> {
  let mockingContext: MockingContext
  let invocation: Invocation
  let sourceLocation: SourceLocation

  init<T>(with mockable: Mockable<T, I, R>, at sourceLocation: SourceLocation) {
    self.mockingContext = mockable.mock.mockingContext
    self.invocation = mockable.invocation
    self.sourceLocation = sourceLocation
  }

  /// Verify that the mock received the invocation some number of times using a count matcher.
  ///
  /// - Parameter countMathcer: A count matcher defining the number of invocations to verify.
  public func wasCalled(_ countMatcher: CountMatcher) {
    verify(using: countMatcher, for: sourceLocation)
  }
  
  /// Verify that the mock received the invocation an exact number of times.
  ///
  /// - Parameter times: The exact number of invocations expected.
  public func wasCalled(_ times: UInt = once) {
    verify(using: exactly(times), for: sourceLocation)
  }

  /// Verify that the mock never received the invocation.
  public func wasNeverCalled() {
    verify(using: exactly(never), for: sourceLocation)
  }
  
  /// Disambiguate methods overloaded by return type.
  ///
  /// - Parameter type: The return type of the method.
  public func returning(_ type: R.Type = R.self) -> Verification<I, R> {
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

/// A deferred expectation that can be fulfilled when an invocation arrives later.
struct CapturedExpectation {
  let mockingContext: MockingContext
  let invocation: Invocation
  let expectation: Expectation
}

/// Stores all expectations invoked by verification methods within a scoped context.
class ExpectationGroup {
  private(set) weak var parent: ExpectationGroup?
  private let verificationBlock: (ExpectationGroup) throws -> Void
  
  init(_ verificationBlock: @escaping (ExpectationGroup) throws -> Void) {
    self.parent = DispatchQueue.currentExpectationGroup
    self.verificationBlock = verificationBlock
  }
  
  struct Failure: Error {
    let error: TestFailure
    let sourceLocation: SourceLocation
  }

  func verify(context: ExpectationGroup? = nil) throws {
    if let parent = parent, context == nil {
      parent.addSubgroup(self)
    } else {
      try verificationBlock(self)
    }
  }
  
  private(set) var expectations = [CapturedExpectation]()
  func addExpectation(mockingContext: MockingContext,
                      invocation: Invocation,
                      expectation: Expectation) {
    expectations.append(CapturedExpectation(mockingContext: mockingContext,
                                            invocation: invocation,
                                            expectation: expectation))
  }
  
  private(set) var subgroups = [ExpectationGroup]()
  func addSubgroup(_ subgroup: ExpectationGroup) {
    subgroups.append(subgroup)
  }
}

extension DispatchQueue {
  class var currentExpectationGroup: ExpectationGroup? {
    return DispatchQueue.getSpecific(key: Expectation.expectationGroupKey)
  }
}

/// Packages a call matcher and its call site. Used by verification methods in attributed scopes.
struct Expectation {
  static let expectationGroupKey = DispatchSpecificKey<ExpectationGroup>()
  
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
  
  let actualCallCount = UInt(allMatchingInvocations.count)
  guard !expectation.countMatcher.matches(actualCallCount) else { return allInvocations }
  throw TestFailure.incorrectInvocationCount(invocationCount: actualCallCount,
                                             invocation: invocation,
                                             countMatcher: expectation.countMatcher,
                                             allInvocations: allInvocations)
}
