//
//  StubbingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// Holds stubbed invocation implementations used by stubs.
public class StubbingContext {
  struct Stub {
    let invocation: Invocation
    let implementation: Any?
  }
  var stubs = Synchronized<[String: [Stub]]>([:])
  let defaultValueProvider = ValueProvider()
  var sourceLocation: SourceLocation?
  
  func swizzle(_ invocation: Invocation, with implementation: Any?) -> Stub {
    let stub = Stub(invocation: invocation, implementation: implementation)
    stubs.update { $0[invocation.selectorName, default: []].append(stub) }
    return stub
  }
  
  func failTest(for invocation: Invocation) -> String {
    TestKiller().failTest(.missingStubbedImplementation(invocation: invocation), at: sourceLocation)
    fatalError("Missing stubbed implementation for \(invocation), but unable to force XCTest case to fail")
  }

  func implementation(for invocation: Invocation) -> Any? {
    return stubs.value[invocation.selectorName]?
      .last(where: { $0.invocation == invocation })?
      .implementation
  }

  func clearStubs() {
    stubs.update { $0.removeAll() }
  }
}
