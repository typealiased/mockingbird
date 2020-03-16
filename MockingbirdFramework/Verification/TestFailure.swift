//
//  TestFailure.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// Internal errors thrown due to a failed test assertion or precondition.
enum TestFailure: Error, CustomStringConvertible {
  case incorrectInvocationCount(
    invocationCount: UInt,
    invocation: Invocation,
    countMatcher: CountMatcher,
    allInvocations: [Invocation] // All captured invocations matching the selector.
  )
  case unexpectedInvocations(
    baseInvocation: Invocation,
    unexpectedInvocations: [Invocation],
    priorToBase: Bool // Whether the unexpected invocations happened before the base invocation.
  )
  case unsatisfiableExpectations(
    capturedExpectations: [CapturedExpectation],
    allInvocations: [Invocation]
  )
  case missingStubbedImplementation(invocation: Invocation)

  var description: String {
    switch self {
    case let .incorrectInvocationCount(invocationCount,
                                       invocation,
                                       countMatcher,
                                       allInvocations):
      let countMatcherDescription = countMatcher.describe(invocation: invocation)
      return """
      Got \(invocationCount) invocations of \(invocation) but expected \(countMatcherDescription)
      
      All invocations of '\(invocation.unwrappedSelectorName)':
      \(allInvocations.indentedDescription)
      """
    case let .unexpectedInvocations(baseInvocation, unexpectedInvocations, priorToBase):
      return """
      Got unexpected invocations \(priorToBase ? "before" : "after") \(baseInvocation)
      
      Invocations:
      \(unexpectedInvocations.indentedDescription)
      """
    case let .unsatisfiableExpectations(capturedExpectations, allInvocations):
      return """
      Unable to simultaneously satisfy expectations
      
      Expectations:
      \(capturedExpectations.indentedDescription)
      
      All invocations:
      \(allInvocations.indentedDescription)
      """
    case let .missingStubbedImplementation(invocation):
      return """
      Missing stubbed implementation for \(invocation))
      """
    }
  }
}

private extension Array where Element == Invocation {
  var indentedDescription: String {
    guard !isEmpty else { return "   No invocations recorded" }
    return self.enumerated()
      .map({ "   (\($0.offset+1)) \($0.element)" })
      .joined(separator: "\n")
  }
}

private extension Array where Element == CapturedExpectation {
  var indentedDescription: String {
    guard !isEmpty else { return "   No expectations" }
    return self.enumerated()
      .map({
        let capturedExpectation = $0.element
        let countMatcherDescription = capturedExpectation.expectation.countMatcher
          .describe(invocation: capturedExpectation.invocation)
        return "   (\($0.offset+1)) \(capturedExpectation.invocation) called \(countMatcherDescription) times"
      })
      .joined(separator: "\n")
  }
}
