//
//  MockingbirdInvocation.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

protocol TargetBox {
  var target: Any { get }
  var function: Any { get }
}

/// Keep track of mutations on value (and reference) types when calling invocations.
class ProxyTargetBox<T>: TargetBox {
  var internalTarget: T
  var target: Any { return internalTarget as Any }
  
  var internalFunction: Any!
  var function: Any { return internalFunction! }
  
  init(_ target: T) {
    self.internalTarget = target
  }
  
  // Convenience to set the funtion and return self.
  func setFunction(_ function: Any) -> Self {
    self.internalFunction = function
    return self
  }
}

/// Holds function contexts with the same signature as the original invocation.
@objc(MKBCallingContext) public class CallingContext: NSObject {
  /// The super function implementation.
  let `super`: Any?
  /// Convert a proxy target to its function implementation and the new (mutated) target.
  let proxy: ((_ target: Any) -> TargetBox)?
  
  init(super: Any?, proxy: ((_ target: Any) -> TargetBox)?) {
    self.super = `super`
    self.proxy = proxy
  }
  
  @objc public override init() {
    // TODO
    self.super = nil
    self.proxy = nil
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
       context: CallingContext = CallingContext(super: nil, proxy: nil)) {
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
    
    // Extract the property name.
    return unwrappedSelectorName
      .components(separatedBy: ".")
      .dropLast()
      .joined(separator: ".")
  }

  var description: String {
    guard !arguments.isEmpty else { return "'\(unwrappedSelectorName)'" }
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "'\(unwrappedSelectorName)' with arguments [\(matchers)]"
  }
  
  enum Constants {
    // Keep this in sync with `MockingbirdGenerator.VariableTemplate.getterName`
    static let getterSuffix = ".getter"
    // Keep this in sync with `MockingbirdGenerator.VariableTemplate.setterName`
    static let setterSuffix = ".setter"
    
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
    let setterSelectorName = String(selectorName.dropLast(Constants.setterSuffix.count))
      + Constants.setterSuffix
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
