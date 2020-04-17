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

private enum Constants {
  static let resultKey = "result"
  static let semaphoreKey = "semaphore"
}

private class ResolutionResult {
  var value: Any?
}

private class ResolutionContext<T>: Thread {
  private let typeFacade: () -> T
  private let result: ResolutionResult
  private let semaphore: DispatchSemaphore
  
  init(typeFacade: @escaping () -> T, result: ResolutionResult, semaphore: DispatchSemaphore) {
    self.typeFacade = typeFacade
    self.result = result
    self.semaphore = semaphore
  }
  
  override func main() {
    // Set the thread's context dictionary.
    let context = Thread.current.threadDictionary
    context[Constants.resultKey] = self.result
    context[Constants.semaphoreKey] = self.semaphore
    
    // Resolve type facade by executing closure.
    result.value = typeFacade()
    semaphore.signal()
  }
}

/// Wraps a value into any type `T` when resolved inside of a `ResolutionContext<T>`.
func createTypeFacade<T>(_ value: Any?) -> T {
  let context = Thread.current.threadDictionary
  guard
    let result = context[Constants.resultKey] as? ResolutionResult,
    let semaphore = context[Constants.semaphoreKey] as? DispatchSemaphore
    else { preconditionFailure("Invalid resolution thread context state") }
  
  result.value = value
  semaphore.signal()
  Thread.exit() // Stop the current thread's execution.
  fatalError() // This will never run.
}

/// Resolve `parameter` when `T` is _not_ known to be `Equatable`.
func resolve<T>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let result = ResolutionResult()
  let semaphore = DispatchSemaphore(value: 0)
  let context = ResolutionContext(typeFacade: parameter, result: result, semaphore: semaphore)
  context.start()
  semaphore.wait()
  if let matcher = result.value as? ArgumentMatcher { return matcher }
  if let typedValue = result.value as? T { return ArgumentMatcher(typedValue) }
  return ArgumentMatcher(result.value)
}

/// Resolve `parameter` when `T` is known to be `Equatable`.
func resolve<T: Equatable>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let result = ResolutionResult()
  let semaphore = DispatchSemaphore(value: 0)
  let context = ResolutionContext(typeFacade: parameter, result: result, semaphore: semaphore)
  context.start()
  semaphore.wait()
  if let matcher = result.value as? ArgumentMatcher { return matcher }
  if let typedValue = result.value as? T { return ArgumentMatcher(typedValue) }
  return ArgumentMatcher(result.value)
}

/// Resolve `parameter` when the closure returns an `ArgumentMatcher`.
func resolve(_ parameter: @escaping () -> ArgumentMatcher) -> ArgumentMatcher {
  return parameter()
}
