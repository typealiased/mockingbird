//
//  StubbingContext+ObjCReturnValue.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/20/21.
//

import Foundation

extension StubbingContext {
  /// Used to indicate that no implementation exists for a given invocation.
  @objc public static let noImplementation = NSObject()
  
  /// Apply arguments to a Swift implementation forwarded by the Objective-C runtime.
  /// - Parameter invocation: An Objective-C invocation to handle.
  /// - Returns: The value returned from evaluating the Swift implementation.
  @objc public func returnValue(for invocation: ObjCInvocation) -> Any? {
    let implementation = implementation(for: invocation as Invocation)
    if let concreteImplementation = implementation as? () -> Any? {
      return concreteImplementation()
    } else if let concreteImplementation = implementation
                as? (Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base,
                                    invocation.arguments.get(10)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base,
                                    invocation.arguments.get(10)?.base,
                                    invocation.arguments.get(11)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base,
                                    invocation.arguments.get(10)?.base,
                                    invocation.arguments.get(11)?.base,
                                    invocation.arguments.get(12)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base,
                                    invocation.arguments.get(10)?.base,
                                    invocation.arguments.get(11)?.base,
                                    invocation.arguments.get(12)?.base,
                                    invocation.arguments.get(13)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base,
                                    invocation.arguments.get(10)?.base,
                                    invocation.arguments.get(11)?.base,
                                    invocation.arguments.get(12)?.base,
                                    invocation.arguments.get(13)?.base,
                                    invocation.arguments.get(14)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any? {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base,
                                    invocation.arguments.get(10)?.base,
                                    invocation.arguments.get(11)?.base,
                                    invocation.arguments.get(12)?.base,
                                    invocation.arguments.get(13)?.base,
                                    invocation.arguments.get(14)?.base,
                                    invocation.arguments.get(15)?.base)
    }
    
    return Self.noImplementation
  }

}
