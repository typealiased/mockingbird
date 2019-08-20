//
//  StubbingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Holds stubbed invocation implementations used by stubs.
public class StubbingContext {
  struct Stub {
    let invocation: Invocation
    let implementation: (Invocation) throws -> Any?
  }
  var stubs = Synchronized<[String: [Stub]]>([:])

  func swizzle(_ invocation: Invocation,
               with implementation: @escaping (Invocation) throws -> Any?) {
    let stub = Stub(invocation: invocation, implementation: implementation)
    stubs.update { $0[invocation.selectorName, default: []].append(stub) }
    
    guard let callback = DispatchQueue.currentStubbingCallback else { return }
    callback(stub, self)
  }

  func implementation(for invocation: Invocation) throws -> (Invocation) throws -> Any? {
    guard let stub = stubs.value[invocation.selectorName]?.last(where: { $0.invocation == invocation }) else {
        throw TestFailure.missingStubbedImplementation(invocation: invocation)
    }
    return stub.implementation
  }

  func clearStubs() {
    stubs.update { $0.removeAll() }
  }
}
