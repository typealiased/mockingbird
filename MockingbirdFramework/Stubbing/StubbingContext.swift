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
  var sourceLocation: SourceLocation?
  
  func swizzle(_ invocation: Invocation, with implementation: Any?) {
    let stub = Stub(invocation: invocation, implementation: implementation)
    stubs.update { $0[invocation.selectorName, default: []].append(stub) }
    
    guard let callback = DispatchQueue.currentStubbingCallback else { return }
    callback(stub, self)
  }

  func implementation(for invocation: Invocation, optional: Bool = false) -> Any? {
    guard let stub = stubs.value[invocation.selectorName]?
      .last(where: { $0.invocation == invocation })
      else {
        if !optional {
          TestKiller().failTest(.missingStubbedImplementation(invocation: invocation),
                                at: sourceLocation)
        }
        return nil
      }
    return stub.implementation
  }

  func clearStubs() {
    stubs.update { $0.removeAll() }
  }
}
