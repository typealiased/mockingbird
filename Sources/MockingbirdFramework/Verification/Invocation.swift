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
  let returnType: ObjectIdentifier
  let timestamp = Date()
  let identifier = UUID()

  init(selectorName: String, arguments: [ArgumentMatcher], returnType: ObjectIdentifier) {
    self.selectorName = selectorName
    self.arguments = arguments
    self.returnType = returnType
  }
  
  /// Selector name without tickmark escaping.
  var unwrappedSelectorName: String {
    return selectorName.replacingOccurrences(of: "`", with: "")
  }
  
  /// Mockable declaration identifier, e.g. `someMethod`, `getSomeProperty`.
  var declarationIdentifier: String {
    let unwrappedSelectorName = self.unwrappedSelectorName
    guard !isMethod else {
      let endIndex = unwrappedSelectorName.firstIndex(of: "(") ?? unwrappedSelectorName.endIndex
      return String(unwrappedSelectorName[..<endIndex])
    }
    
    let propertyName = unwrappedSelectorName
      .components(separatedBy: ".")
      .dropLast()
      .joined(separator: ".")
    return (isGetter ? Constants.getterPrefix : Constants.setterPrefix) +
      propertyName.prefix(1).uppercased() + propertyName.dropFirst()
  }

  var description: String {
    guard !arguments.isEmpty else { return "'\(unwrappedSelectorName)'" }
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "'\(unwrappedSelectorName)' with arguments [\(matchers)]"
  }
  
  enum Constants {
    static let getterSuffix = ".get"
    static let setterSuffix = ".set"
    
    static let getterPrefix = "get"
    static let setterPrefix = "set"
  }
  
  var isMethod: Bool {
    return selectorName.contains("->")
  }
  
  var isGetter: Bool {
    return !isMethod && selectorName.hasSuffix(Constants.getterSuffix)
  }
  
  var isSetter: Bool {
    return !isMethod && selectorName.hasPrefix(Constants.setterSuffix)
  }
  
  func toSetter() -> Invocation? {
    guard isGetter else { return nil }
    let setterSelectorName = String(selectorName.dropLast(4) + Constants.setterSuffix)
    let matcher = ArgumentMatcher(description: "any()", priority: .high) { return true }
    return Invocation(selectorName: setterSelectorName,
                      arguments: [matcher],
                      returnType: ObjectIdentifier(Void.self))
  }
}

extension Invocation: Equatable {
  static func == (lhs: Invocation, rhs: Invocation) -> Bool {
    guard lhs.arguments.count == rhs.arguments.count else { return false }
    guard lhs.returnType == rhs.returnType else { return false }
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

/// Types that cannot be stored and referenced later.
protocol NonEscapingType {}

/// Placeholder for non-escaping closure parameter types.
///
/// Non-escaping closures cannot be stored in an `Invocation` so an instance of a
/// `NonEscapingClosure` is stored instead.
///
///     protocol Bird {
///       func send(_ message: String, callback: (Result) -> Void)
///     }
///
///     bird.send("Hello", callback: { print($0) })
///
///     // Must use a wildcard argument matcher like `any`
///     verify(bird.send("Hello", callback: any())).wasCalled()
///
/// Mark closure parameter types as `@escaping` to capture closures during verification.
///
///     protocol Bird {
///       func send(_ message: String, callback: @escaping (Result) -> Void)
///     }
///
///     bird.send("Hello", callback: { print($0) })
///
///     let argumentCaptor = ArgumentCaptor<(Result) -> Void>()
///     verify(bird.send("Hello", callback: argumentCaptor.matcher)).wasCalled()
///     argumentCaptor.value?(.success)  // Prints Result.success
public class NonEscapingClosure<ClosureType>: NonEscapingType {}
