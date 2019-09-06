//
//  CountMatcher.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Checks whether some number of calls matches an expected number of calls.
public struct CountMatcher {
  let matcher: (UInt) -> Bool

  /// Creates a printable description of the expected call count.
  let descriptionCreator: (Invocation, UInt, Bool) -> String

  init(_ matcher: @escaping (UInt) -> Bool,
       describedBy descriptionCreator: @escaping (Invocation, UInt, Bool) -> String) {
    self.matcher = matcher
    self.descriptionCreator = descriptionCreator
  }

  func matches(_ count: UInt) -> Bool { return matcher(count) }

  func describe(invocation: Invocation, count: UInt, negated: Bool = false) -> String {
    return descriptionCreator(invocation, count, negated)
  }
}
