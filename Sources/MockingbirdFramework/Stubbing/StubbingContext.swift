//
//  StubbingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// Stores stubbed implementations used by mocks.
@objc(MKBStubbingContext) public class StubbingContext: NSObject {
  struct Stub {
    let invocation: Invocation
    let implementationProvider: () -> Any?
  }
  var stubs = Synchronized<[String: [Stub]]>([:])
  var defaultValueProvider = ValueProvider()
  var sourceLocation: SourceLocation?
  
  func swizzle(_ invocation: Invocation,
               with implementationProvider: @escaping () -> Any?) -> Stub {
    let stub = Stub(invocation: invocation, implementationProvider: implementationProvider)
    stubs.update { $0[invocation.selectorName, default: []].append(stub) }
    return stub
  }
  
  @discardableResult
  func failTest(for invocation: Invocation) -> String {
    let stubbedSelectorNames = stubs.read({ Array($0.keys) }).sorted()
    let stackTrace = StackTrace(from: Thread.callStackSymbols)
    let error = TestFailure.missingStubbedImplementation(invocation: invocation,
                                                         stubbedSelectorNames: stubbedSelectorNames,
                                                         stackTrace: stackTrace)
    if let sourceLocation = sourceLocation {
      MKBFail("\(error)", isFatal: true, file: sourceLocation.file, line: sourceLocation.line)
    } else {
      MKBFail("\(error)", isFatal: true)
    }
    // Usually test execution has stopped by this point, but unfortunately there's no workaround for
    // invocations called on background threads.
    fatalError("Missing stubbed implementation for \(invocation)")
  }
  
  @discardableResult
  @objc public func failTest(for invocation: ObjCInvocation) -> String {
    return failTest(for: invocation as Invocation)
  }

  func implementation(for invocation: Invocation) -> Any? {
    return stubs.read({ $0[invocation.selectorName] })?
      .last(where: { $0.invocation.isEqual(to: invocation) })?
      .implementationProvider()
  }
  
  @objc public static let noImplementation = NSObject()
  
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
    }
    
    return Self.noImplementation
  }

  func clearStubs() {
    stubs.update { $0.removeAll() }
  }
}
