//
//  MockingbirdTestFailure.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Internal errors thrown due to a failed test assertion or precondition.
enum MockingbirdTestFailure: Error, CustomStringConvertible {
  case incorrectInvocationCount(
    invocation: MockingbirdInvocation,
    description: String
  )
  case missingStubbedImplementation(invocation: MockingbirdInvocation)

  var description: String {
    switch self {
    case let .incorrectInvocationCount(invocation, description):
      return """
      Incorrect total invocations of \(String(describing: invocation))
      \texpected \(description)
      """
    case let .missingStubbedImplementation(invocation):
      return """
      Missing stubbed implementation for \(String(describing: invocation))
      """
    }
  }
}
