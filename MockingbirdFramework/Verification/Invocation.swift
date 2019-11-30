//
//  MockingbirdInvocation.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Mocks create invocations when receiving calls to methods or member methods.
struct Invocation: Equatable, CustomStringConvertible {
  let selectorName: String
  let arguments: [ArgumentMatcher]
  let timestamp = Date()

  init(selectorName: String, arguments: [ArgumentMatcher]) {
    self.selectorName = selectorName
    self.arguments = arguments
  }

  var description: String {
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "`\(selectorName)` matching (\(matchers))"
  }

  static func == (lhs: Invocation, rhs: Invocation) -> Bool {
    guard lhs.arguments.count == rhs.arguments.count else { return false }
    for (index, argument) in lhs.arguments.enumerated() {
      if argument != rhs.arguments[index] { return false }
    }
    return true
  }
  
  enum Constants {
    static let getterSuffix = ".get"
    static let setterSuffix = ".set"
  }
  
  var isGetter: Bool {
    return selectorName.hasSuffix(Constants.getterSuffix)
  }
  
  var isSetter: Bool {
    return selectorName.hasPrefix(Constants.setterSuffix)
  }
  
  func toSetter() -> Invocation? {
    guard isGetter else { return nil }
    let setterSelectorName = String(selectorName.dropLast(4) + Constants.setterSuffix)
    let matcher = ArgumentMatcher(description: "any()", priority: .high) { return true }
    return Invocation(selectorName: setterSelectorName, arguments: [matcher])
  }
}

/// Method parameters that are non-escaping closure types cannot be stored in an `Invocation`. An
/// instance of a `NonEscapingClosure<T>` is stored instead, where `T` is the closure type.
protocol NonEscapingClosureProtocol {}
public class NonEscapingClosure<T>: NonEscapingClosureProtocol {}
