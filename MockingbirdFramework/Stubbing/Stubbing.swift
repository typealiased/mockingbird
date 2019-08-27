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

/// P = Invocation function type, R = Return type
public struct Stubbable<T, R> {}

/// Intermediate stubbing object.
public struct Stub<T, R>: RunnableScope {
  let uuid = UUID()
  private let runnable: () -> Any?
  init(_ runnable: @escaping () -> Any?) { self.runnable = runnable }
  func run() -> Any? { return runnable() }
}

public struct StubImplementation<T, R> {
  let handler: T
  let callback: AnyObject
}

/// A wrapper around a type-erased stub implementation.
struct StubbingRequest {
  /// Callback block sent when a stub implementation is applied to a mock object.
  typealias StubbingCallback = (StubbingContext.Stub, StubbingContext) -> Void
  
  static let dispatchQueueKey = DispatchSpecificKey<StubbingRequest>()
  static let dispatchQueueCallbackKey = DispatchSpecificKey<StubbingCallback>()
  
  /// A type-erased `StubImplementation<T, R>`.
  let implementation: Any?
}

extension DispatchQueue {
  class var currentStub: StubbingRequest? {
    return DispatchQueue.getSpecific(key: StubbingRequest.dispatchQueueKey)
  }
  
  class var currentStubbingCallback: StubbingRequest.StubbingCallback? {
    return DispatchQueue.getSpecific(key: StubbingRequest.dispatchQueueCallbackKey)
  }
}

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An autoclosed internal stubbing scope.
///   - implementation: The non-throwing implementation stub.
public func ~> <T, R>(stubbingScope: Stub<T, R>,
                      implementation: @escaping @autoclosure () -> R) {
  addStub(scope: stubbingScope, implementation: implementation)
}

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The non-throwing implementation stub.
public func ~> <T, R>(stubbingScope: Stub<T, R>,
                      implementation: @escaping () -> R) {
  addStub(scope: stubbingScope, implementation: implementation)
}

/// Stub invocations to a mock taking into account the invocation (and its parameters).
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T, R>(stubbingScope: Stub<T, R>, implementation: T) {
  addStub(scope: stubbingScope, implementation: implementation)
}

/// Internal method for stubbing invocations with side effects.
public func ~> <T, R>(stubbingScope: Stub<T, R>,
                      implementation: StubImplementation<T, R>) {
  guard let callback = implementation.callback as? StubbingRequest.StubbingCallback else { return }
  addStub(scope: stubbingScope, implementation: implementation.handler, callback: callback)
}

/// Internal helper to create an attributed `DispatchQueue` for stubbing.
func addStub<T, R>(scope: Stub<T, R>,
                   implementation: Any?,
                   callback: StubbingRequest.StubbingCallback? = nil) {
  let queue = DispatchQueue(label: "co.bird.mockingbird.stubbing-scope")
  let stub = StubbingRequest(implementation: implementation)
  queue.setSpecific(key: StubbingRequest.dispatchQueueKey, value: stub)
  if let callback = callback {
    queue.setSpecific(key: StubbingRequest.dispatchQueueCallbackKey, value: callback)
  }
  _ = queue.sync { scope.run() }
}
