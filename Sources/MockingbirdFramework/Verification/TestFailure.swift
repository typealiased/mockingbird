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
    invocationCount: Int,
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
  case missingStubbedImplementation(
    invocation: Invocation,
    stubbedSelectorNames: [String],
    stackTrace: StackTrace
  )

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

    case let .missingStubbedImplementation(invocation, stubbedSelectorNames, stackTrace):
      var allStubsDescription: String {
        guard !stubbedSelectorNames.isEmpty else { return "   No concrete stubs" }
        return stubbedSelectorNames.map({ "   - " + $0 }).joined(separator: "\n")
      }
      let invocationType = invocation.isMethod ? "method" : "property"
      return """
      Missing stubbed implementation for \(invocation)
      
      Make sure the \(invocationType) has a concrete stub or a default value provider registered with the return type.
      
      Examples:
         given(someMock.\(invocation.mockableExampleInvocation)).willReturn(someValue)
         given(someMock.\(invocation.mockableExampleInvocation)).will { return someValue }
         someMock.useDefaultValues(from: .standardProvider)
      
      Stack trace:
      \(stackTrace.parseFrames().indentedDescription)
      
      All stubs:
      \(allStubsDescription)
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

private extension Array where Element == StackTrace.Frame {
  var indentedDescription: String {
    guard count > 1 else { return  "   No call stack symbols" }
    
    let framesStartIndex = index(after: self[1...].firstIndex(where: {
      $0.location == "Mockingbird"
    }) ?? startIndex)
    let framesEndIndex = firstIndex(where: {
      $0.location == "XCTest" || $0.location == "libXCTestSwiftSupport.dylib"
    }) ?? endIndex
    
    let relevantFrames = self[framesStartIndex..<framesEndIndex]
    return relevantFrames
      .map({ "[" + $0.location + "] " + $0.symbol }).enumerated()
      .map({ "   (\($0.offset)) \($0.element)" }).joined(separator: "\n")
  }
}

private extension Invocation {
  var mockableExampleInvocation: String {
    return declarationIdentifier + "(" + (arguments.isEmpty ? "" : "…") + ")"
  }
}
