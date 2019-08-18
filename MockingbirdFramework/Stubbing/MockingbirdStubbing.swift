//
//  MockingbirdStubbing.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Dispatch
import Foundation
import XCTest

infix operator ~>

public struct MockingbirdScopedStub<T> {}

public struct MockingbirdStubbingScope<T>: MockingbirdRunnableScope {
  let uuid = UUID()
  private let runnable: () -> Any?
  init(_ runnable: @escaping () -> Any?) { self.runnable = runnable }
  func run() -> Any? { return runnable() }
}

public struct MockingbirdStubRequest<T> {
  let implementation: (MockingbirdInvocation) -> T
  let callback: AnyObject
}

struct MockingbirdStub {
  typealias StubbingCallback = (MockingbirdStubbingContext.Stub, MockingbirdStubbingContext) -> Void
  
  static let dispatchQueueKey = DispatchSpecificKey<MockingbirdStub>()
  static let dispatchQueueCallbackKey = DispatchSpecificKey<StubbingCallback>()
  
  let implementation: (MockingbirdInvocation) -> Any?
  let returnType: Any?
}

extension DispatchQueue {
  class var currentStub: MockingbirdStub? {
    return DispatchQueue.getSpecific(key: MockingbirdStub.dispatchQueueKey)
  }
  
  class var currentStubbingCallback: MockingbirdStub.StubbingCallback? {
    return DispatchQueue.getSpecific(key: MockingbirdStub.dispatchQueueCallbackKey)
  }
}

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T>(stubbingScope: MockingbirdStubbingScope<T>,
                   implementation: @escaping @autoclosure () -> T) {
  stubbingScope ~> { _ in implementation() }
}

/// Convenience method for ignoring all parameters while stubbing.
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T>(stubbingScope: MockingbirdStubbingScope<T>,
                   implementation: @escaping () -> T) {
  stubbingScope ~> { _ in implementation() }
}

/// Stub invocations to a mock taking into account the invocation (and its parameters).
///
/// - Parameters:
///   - stubbingScope: An internal stubbing scope.
///   - implementation: The implementation stub.
public func ~> <T>(stubbingScope: MockingbirdStubbingScope<T>,
                   implementation: @escaping (MockingbirdInvocation) -> T) {
  addStub(scope: stubbingScope, implementation: implementation)
}

/// Internal method for stubbing invocations with side effects.
public func ~> <T>(stubbingScope: MockingbirdStubbingScope<T>,
                   request: MockingbirdStubRequest<T>) {
  guard let callback = request.callback as? MockingbirdStub.StubbingCallback else { return }
  addStub(scope: stubbingScope, implementation: request.implementation, callback: callback)
}

internal func addStub<T>(scope: MockingbirdStubbingScope<T>,
                         implementation: @escaping (MockingbirdInvocation) -> T,
                         callback: MockingbirdStub.StubbingCallback? = nil) {
  let queue = DispatchQueue(label: "co.bird.mockingbird.stubbing-scope")
  let stub = MockingbirdStub(implementation: implementation, returnType: T.self)
  queue.setSpecific(key: MockingbirdStub.dispatchQueueKey, value: stub)
  if let callback = callback {
    queue.setSpecific(key: MockingbirdStub.dispatchQueueCallbackKey, value: callback)
  }
  _ = queue.sync { scope.run() }
}
