//
//  TestFailure.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Internal errors thrown due to a failed test assertion or precondition.
enum TestFailure: Error, CustomStringConvertible {
  case incorrectInvocationCount(
    invocationCount: UInt,
    invocation: Invocation,
    countMatcher: CountMatcher,
    allInvocations: [Invocation] // All captured invocations matching the selector.
  )
  case missingStubbedImplementation(invocation: Invocation)

  var description: String {
    switch self {
    case let .incorrectInvocationCount(invocationCount, invocation, countMatcher, allInvocations):
      let countMatcherDescription = countMatcher.describe(invocation: invocation,
                                                          count: invocationCount)
      let invocationHistory = allInvocations.isEmpty ? "   No invocations recorded" :
        allInvocations.enumerated()
          .map({ "   (\($0.offset+1)) \($0.element)" })
          .joined(separator: "\n")
      return """
      Got \(invocationCount) invocations of \(invocation) but expected \(countMatcherDescription)
      
      All invocations of '\(invocation.unwrappedSelectorName)':
      \(invocationHistory)
      """
    case let .missingStubbedImplementation(invocation):
      return """
      Missing stubbed implementation for \(invocation))
      """
    }
  }
}
