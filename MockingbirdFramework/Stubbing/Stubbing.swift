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

/// Used for chained stubbing which doesn't work with `~>` because of the default precedence group.
infix operator ~: AdditionPrecedence

/// A object used as a stubbing request for a particular mock.
public struct Stubbable<I, R> {
  let stubbingContext: StubbingContext
  let invocation: Invocation
}

/// An object used for chained / intermediary stubbing.
/// T = Mocked type, M = Concrete mock type, I = Invocation function type, R = Return type
public struct ChainStubbable<T, M, I, R> {
  // When created from a normal method this is the mocked type.
  // When created from a static context this is the mock type.
  // When created from an associated type protocol this is the `Mock` metatype.
  let object: T
  let stubbingContext: StubbingContext
  let invocation: Invocation
}

/// Intermediate stubbing object.
public struct Stub<I, R> {
  let requests: [(stubbingContext: StubbingContext, invocation: Invocation)]
  
  init(from stubbable: [Stubbable<I, R>]) {
    self.requests = stubbable.map({
      (stubbingContext: $0.stubbingContext, invocation: $0.invocation)
    })
  }
  
  init<T, M>(from stubbable: ChainStubbable<T, M, I, R>) {
    self.requests = [(stubbingContext: stubbable.stubbingContext, invocation: stubbable.invocation)]
  }
}

/// Used to add side effects to stubbing, such as stubbing a setter when stubbing a getter.
public struct StubImplementation<I, R> {
  let handler: I
  let callback: (StubbingContext.Stub, StubbingContext) -> Void
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

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The non-throwing implementation stub.
public func ~> <I, R>(stub: Stub<I, R>,
                      implementation: @escaping () -> R) {
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

/// Internal method for chaining stubs.
public func ~ <T1, M1: Mock, I1, R1, M2: Mock, I2, R2>(lhs: ChainStubbable<T1, M1, I1, R1>,
                                                       rhs: ChainStubbable<R1, M2, I2, R2>)
  -> ChainStubbable<R1, M2, I2, R2> {
    let implementation: () -> R1 = { rhs.object }
    _ = lhs.stubbingContext.swizzle(lhs.invocation, with: implementation)
    return rhs
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
