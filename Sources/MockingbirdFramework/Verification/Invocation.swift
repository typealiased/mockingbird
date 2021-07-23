//
//  MockingbirdInvocation.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Holds function contexts with the same signature as the original invocation.
@objc(MKBCallingContext) public class CallingContext: NSObject {
  /// The super function implementation.
  let `super`: Any?
  /// Convert a proxy target to its function implementation and the new (mutated) target.
  let proxy: ((_ target: Any) -> (function: Any, target: Any))?
  
  init(super: Any?, proxy: ((_ target: Any) -> (function: Any, target: Any))?) {
    self.super = `super`
    self.proxy = proxy
  }
  
  @objc public init(super: Any?, proxy: ((Any) -> Any)?) {
    self.super = `super`
    
    // Obj-C doesn't need to worry about passing value types as proxy targets.
    if let proxy = proxy {
      self.proxy = { (target: Any) -> (Any, Any) in (proxy(target), target) }
    } else {
      self.proxy = nil
    }
  }
  
  class func createProxy<T>(_ target: Any, type: T.Type, block: (inout T) -> Any) -> (Any, Any) {
    var mutableTarget = target as! T
    return ({ (target: inout T) -> Any in
      block(&target)
    }(&mutableTarget), mutableTarget)
  }
}

/// Mocks create invocations when receiving calls to methods or member methods.
protocol Invocation: CustomStringConvertible {
  var selectorName: String { get }
  var arguments: [ArgumentMatcher] { get }
  var returnType: ObjectIdentifier { get }
  var context: CallingContext { get }
  var uid: UInt { get }
  
  /// Selector name without tickmark escaping.
  var unwrappedSelectorName: String { get }
  /// Mockable declaration identifier, e.g. `someMethod`, `getSomeProperty`.
  var declarationIdentifier: String { get }
  
  var isMethod: Bool { get }
  var isGetter: Bool { get }
  var isSetter: Bool { get }
  
  /// If the current invocation referrs to a property getter, convert it to the equivalent setter.
  /// - Warning: This method is not available for invocations on mocked Objective-C types.
  func toSetter() -> Self?
}

extension Invocation {
  // Avoids making `Invocation` a generic protocol.
  func isEqual(to rhs: Invocation) -> Bool {
    guard arguments.count == rhs.arguments.count else { return false }
    guard returnType == rhs.returnType else { return false }
    for (index, argument) in arguments.enumerated() {
      if argument != rhs.arguments[index] { return false }
    }
    return true
  }
}

struct SwiftInvocation: Invocation {
  let selectorName: String
  let arguments: [ArgumentMatcher]
  let returnType: ObjectIdentifier
  let context: CallingContext
  let uid = MonotonicIncreasingIndex.getIndex()

  init(selectorName: String,
       arguments: [ArgumentMatcher],
       returnType: ObjectIdentifier,
       context: CallingContext) {
    self.selectorName = selectorName
    self.arguments = arguments
    self.returnType = returnType
    self.context = context
  }
  
  var unwrappedSelectorName: String {
    return selectorName.replacingOccurrences(of: "`", with: "")
  }
  
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
  
  func toSetter() -> Self? {
    guard isGetter else { return nil }
    let setterSelectorName = String(selectorName.dropLast(4) + Constants.setterSuffix)
    let matcher = ArgumentMatcher(description: "any()", priority: .high) { return true }
    return Self(selectorName: setterSelectorName,
                arguments: [matcher],
                returnType: ObjectIdentifier(Void.self),
                context: context)
  }
}

@objc(MKBObjCInvocation) public class ObjCInvocation: NSObject, Invocation {
  let selectorName: String
  let arguments: [ArgumentMatcher]
  let returnType: ObjectIdentifier
  let context: CallingContext
  let uid = MonotonicIncreasingIndex.getIndex()
  
  @objc public required init(selectorName: String,
                             arguments: [ArgumentMatcher],
                             context: CallingContext) {
    self.selectorName = selectorName
    self.arguments = arguments
    self.returnType = ObjectIdentifier(Any.self) // Return type doesn't matter for Obj-C.
    self.context = context
  }
  
  var unwrappedSelectorName: String { return selectorName }
  var declarationIdentifier: String {
    return String(selectorName.split(separator: ":").first ?? "")
  }
  
  override public var description: String {
    guard !arguments.isEmpty else { return "'\(unwrappedSelectorName)'" }
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "'\(unwrappedSelectorName)' with arguments [\(matchers)]"
  }
  
  let isMethod = true // Treat all invocations as a method type (an objc_msgSend to some selector).
  let isGetter = false // Not supported.
  let isSetter = false // Not supported.
  
  func toSetter() -> Self? {
    return nil
  }
}
