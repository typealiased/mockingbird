//
//  MockingbirdInvocation.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Mocks create invocations when receiving calls to methods or member methods.
struct Invocation: CustomStringConvertible {
  let selectorName: String
  let arguments: [ArgumentMatcher]
  let timestamp = Date()
  let identifier = UUID()

  init(selectorName: String, arguments: [ArgumentMatcher]) {
    self.selectorName = selectorName
    self.arguments = arguments
  }
  
  /// Selector name without tickmark escaping.
  var unwrappedSelectorName: String {
    return selectorName.replacingOccurrences(of: "`", with: "")
  }

  var description: String {
    guard !arguments.isEmpty else { return "'\(unwrappedSelectorName)'" }
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "'\(unwrappedSelectorName)' with arguments [\(matchers)]"
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

extension Invocation: Equatable {
  static func == (lhs: Invocation, rhs: Invocation) -> Bool {
    guard lhs.arguments.count == rhs.arguments.count else { return false }
    for (index, argument) in lhs.arguments.enumerated() {
      if argument != rhs.arguments[index] { return false }
    }
    return true
  }
}

extension Invocation: Comparable {
  static func < (lhs: Invocation, rhs: Invocation) -> Bool {
    return lhs.timestamp < rhs.timestamp
  }
}

/// Method parameters that are non-escaping closure types cannot be stored in an `Invocation`. An
/// instance of a `NonEscapingClosure<T>` is stored instead, where `T` is the closure type.
protocol NonEscapingClosureProtocol {}
public class NonEscapingClosure<T>: NonEscapingClosureProtocol {}
