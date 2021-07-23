//
//  TypeFacade.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/3/19.
//

import Foundation

/// This is a hack to get strongly-typed stubbing/verification parameters. The goal is to have
/// `ArgumentMatcher` "conform" to any reference or value type so that it's possible to pass both
/// an actual concrete instance of a type OR a matcher. This provides better compile-time
/// guarantees and autocompletion compared to conforming all parameter types to a common protocol.
///
/// It goes without saying that this should probably never be done in production.

private class ResolutionContext: Thread {
  private let typeFacade: () -> Any?
  let result: Result
  let semaphore: DispatchSemaphore
  
  private enum Constants {
    static let resultKey = "co.bird.mockingbird.resolution-context.result"
    static let semaphoreKey = "co.bird.mockingbird.resolution-context.semaphore"
  }
  
  class Result {
    var value: Any?
  }
  
  static var result: Result? {
    return Thread.current.threadDictionary[Constants.resultKey] as? Result
  }
  static var semaphore: DispatchSemaphore? {
    return Thread.current.threadDictionary[Constants.semaphoreKey] as? DispatchSemaphore
  }
  
  init<T>(typeFacade: @escaping () -> T) {
    self.typeFacade = typeFacade
    self.result = Result()
    self.semaphore = DispatchSemaphore(value: 0)
  }
  
  override func main() {
    threadDictionary[Constants.resultKey] = self.result
    threadDictionary[Constants.semaphoreKey] = self.semaphore
    result.value = typeFacade()
    semaphore.signal()
  }
}

func fakePrimitiveValue<T>(_ value: Any?) -> T {
  if let value = ValueProvider.standardProvider.provideValue(for: T.self) {
    return value
  }
  
  // Fall back to returning a buffer of ample size. This can break for bridged primitive types.
  return UnsafeMutableRawPointer
    .allocate(byteCount: 512, alignment: MemoryLayout<Int8>.alignment)
    .bindMemory(to: T.self, capacity: 1)
    .pointee
}

/// Wraps a value into any type `T` when resolved inside of a `ResolutionContext<T>`.
func createTypeFacade<T>(_ value: Any?) -> T {
  guard let result = ResolutionContext.result, let semaphore = ResolutionContext.semaphore else {
    guard let recorder = InvocationRecorder.sharedRecorder else {
      preconditionFailure("Invalid resolution thread context state")
    }
    // This is actually an invocation recording context, but the type is not mockable in Obj-C.
    guard let argumentIndex = recorder.argumentIndex else {
      /// Explicit argument indexes are required in certain cases. See the `arg(_:at:)` docs for
      /// more information and usage.
      preconditionFailure("An argument index is required, e.g. 'firstArg(any())'")
    }
    recorder.recordFacadeValue(value, at: argumentIndex)
    return fakePrimitiveValue(value)
  }
  
  result.value = value
  semaphore.signal()
  Thread.exit()
  fatalError("This should never run")
}

// TODO: Clean up and docs
func createTypeFacade<T: NSObjectProtocol>(_ value: Any?) -> T {
  guard let result = ResolutionContext.result, let semaphore = ResolutionContext.semaphore else {
    guard InvocationRecorder.sharedRecorder != nil else {
      preconditionFailure("Invalid resolution thread context state")
    }
    // This is actually an invocation recording context.
    return MKBTypeFacade(mock: mkb_mock(T.self), object: value as Any).fixupType()
  }
  
  result.value = value
  semaphore.signal()
  Thread.exit()
  fatalError("This should never run")
}

/// Resolve `parameter` when `T` is _not_ known to be `Equatable`.
func resolve<T>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let context = ResolutionContext(typeFacade: parameter)
  context.start()
  context.semaphore.wait()
  if let matcher = context.result.value as? ArgumentMatcher { return matcher }
  if let typedValue = context.result.value as? T { return ArgumentMatcher(typedValue) }
  return ArgumentMatcher(context.result.value)
}

/// Resolve `parameter` when `T` is known to be `Equatable`.
func resolve<T: Equatable>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let context = ResolutionContext(typeFacade: parameter)
  context.start()
  context.semaphore.wait()
  if let matcher = context.result.value as? ArgumentMatcher { return matcher }
  if let typedValue = context.result.value as? T { return ArgumentMatcher(typedValue) }
  return ArgumentMatcher(context.result.value)
}

/// Resolve `parameter` when the closure returns an `ArgumentMatcher`.
func resolve(_ parameter: @escaping () -> ArgumentMatcher) -> ArgumentMatcher {
  return parameter()
}
