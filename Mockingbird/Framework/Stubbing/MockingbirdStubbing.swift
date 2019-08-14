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

struct MockingbirdStub {
  static let dispatchQueueKey = DispatchSpecificKey<MockingbirdStub>()
  let implementation: (MockingbirdInvocation) -> Any?
  let returnType: Any?
}

extension DispatchQueue {
  class var currentStub: MockingbirdStub? {
    return DispatchQueue.getSpecific(key: MockingbirdStub.dispatchQueueKey)
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
  let queue = DispatchQueue(label: "co.bird.mockingbird.stubbing-scope")
  let stub = MockingbirdStub(implementation: implementation, returnType: T.self)
  queue.setSpecific(key: MockingbirdStub.dispatchQueueKey, value: stub)
  _ = queue.sync { stubbingScope.run() }
}
