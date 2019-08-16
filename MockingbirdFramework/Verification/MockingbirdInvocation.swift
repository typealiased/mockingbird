//
//  MockingbirdInvocation.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Mocks create invocations when receiving calls to methods or member methods.
public struct MockingbirdInvocation: Equatable, CustomStringConvertible {
  let selectorName: String
  let arguments: [MockingbirdMatcher]
  let timestamp = Date()

  public init(selectorName: String, arguments: [MockingbirdMatcher]) {
    self.selectorName = selectorName
    self.arguments = arguments
  }

  public var description: String {
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "`\(selectorName)` matching (\(matchers))"
  }

  public static func == (lhs: MockingbirdInvocation, rhs: MockingbirdInvocation) -> Bool {
    guard lhs.arguments.count == rhs.arguments.count else { return false }
    for (index, argument) in lhs.arguments.enumerated() {
      if argument != rhs.arguments[index] { return false }
    }
    return true
  }
}
