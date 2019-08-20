//
//  Stubbing.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Dispatch
import Foundation
import XCTest

infix operator ~>

public struct Stubbable<T> {}

/// Intermediate stubbing object.
public struct Stub<T>: RunnableScope {
  let uuid = UUID()
  private let runnable: () -> Any?
  init(_ runnable: @escaping () -> Any?) { self.runnable = runnable }
  func run() -> Any? { return runnable() }
}

public struct StubImplementation<T> {
  let handler: (Invocation) -> T
  let callback: AnyObject
}

struct StubbingRequest {
  typealias StubbingCallback = (StubbingContext.Stub, StubbingContext) -> Void
  
  static let dispatchQueueKey = DispatchSpecificKey<StubbingRequest>()
  static let dispatchQueueCallbackKey = DispatchSpecificKey<StubbingCallback>()
  
  let implementation: (Invocation) -> Any?
  let returnType: Any?
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
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T>(stubbingScope: Stub<T>, implementation: @escaping @autoclosure () -> T) {
  stubbingScope ~> { _ in implementation() }
}

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T>(stubbingScope: Stub<T>, implementation: @escaping () -> T) {
  stubbingScope ~> { _ in implementation() }
}

/// Stub invocations to a mock taking into account the invocation (and its parameters).
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T>(stubbingScope: Stub<T>, implementation: @escaping (Invocation) -> T) {
  addStub(scope: stubbingScope, implementation: implementation)
}

/// Internal method for stubbing invocations with side effects.
public func ~> <T>(stubbingScope: Stub<T>, implementation: StubImplementation<T>) {
  guard let callback = implementation.callback as? StubbingRequest.StubbingCallback else { return }
  addStub(scope: stubbingScope, implementation: implementation.handler, callback: callback)
}

internal func addStub<T>(scope: Stub<T>,
                         implementation: @escaping (Invocation) -> T,
                         callback: StubbingRequest.StubbingCallback? = nil) {
  let queue = DispatchQueue(label: "co.bird.mockingbird.stubbing-scope")
  let stub = StubbingRequest(implementation: implementation, returnType: T.self)
  queue.setSpecific(key: StubbingRequest.dispatchQueueKey, value: stub)
  if let callback = callback {
    queue.setSpecific(key: StubbingRequest.dispatchQueueCallbackKey, value: callback)
  }
  _ = queue.sync { scope.run() }
}
