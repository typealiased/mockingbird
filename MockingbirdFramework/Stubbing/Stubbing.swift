//
//  Stubbing.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Dispatch
import Foundation
import XCTest

/// The `~>` infix operator is also defined by Swift `stdlib/public/core/Policy.swift`.
infix operator ~>

/// Intermediate stubbing object.
public struct Stub<I, R> {
  let requests: [(stubbingContext: StubbingContext, invocation: Invocation)]
  
  init<T>(from mockable: [Mockable<T, I, R>]) {
    self.requests = mockable.map({
      (stubbingContext: $0.mock.stubbingContext, invocation: $0.invocation)
    })
  }
}

/// Used for creating wrapped stub implementations that can also add side effects to stubbing, such
/// as stubbing a setter when stubbing a getter.
public struct StubImplementation<I, R> {
  let handler: Any
  let callback: ((StubbingContext.Stub, StubbingContext) -> Void)?
}

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An autoclosed internal stubbing scope.
///   - implementation: The non-throwing implementation stub.
public func ~> <I, R>(stub: Stub<I, R>,
                      implementation: @escaping @autoclosure () -> R) {
  addStub(stub, implementation: implementation)
}

/// Stub invocations to a mock taking into account the invocation (and its parameters).
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <I, R>(stub: Stub<I, R>, implementation: I) {
  addStub(stub, implementation: implementation)
}

/// Internal method for stubbing invocations with side effects.
public func ~> <I, R>(stub: Stub<I, R>, implementation: StubImplementation<I, R>) {
  addStub(stub, implementation: implementation.handler, callback: implementation.callback)
}

/// Internal helper to swizzle type-erased stub implementations onto stubbing contexts.
func addStub<I, R>(_ stub: Stub<I, R>,
                   implementation: Any?,
                   callback: ((StubbingContext.Stub, StubbingContext) -> Void)? = nil) {
  stub.requests.forEach({
    let stub = $0.stubbingContext.swizzle($0.invocation, with: implementation)
    callback?(stub, $0.stubbingContext)
  })
}
