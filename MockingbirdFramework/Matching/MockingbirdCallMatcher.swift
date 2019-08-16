//
//  MockingbirdCallMatcher.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Checks whether some number of calls matches an expected number of calls.
public struct MockingbirdCallMatcher {
  let matcher: (UInt) -> Bool

  /// Creates a printable description of the expected call count.
  let descriptionCreator: (MockingbirdInvocation, UInt, Bool) -> String

  public init(_ matcher: @escaping (UInt) -> Bool,
              describedBy descriptionCreator: @escaping (MockingbirdInvocation, UInt, Bool) -> String) {
    self.matcher = matcher
    self.descriptionCreator = descriptionCreator
  }

  func matches(_ actualCalls: UInt) -> Bool { return matcher(actualCalls) }

  func describe(invocation: MockingbirdInvocation, count: UInt, negated: Bool = false) -> String {
    return descriptionCreator(invocation, count, negated)
  }
}
