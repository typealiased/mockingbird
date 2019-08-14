//
//  MockingbirdTypeFacade.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/3/19.
//

import Foundation

private enum Constants {
  static let resolutionThreadName = "co.bird.mockingbird.stub.resolve-type"
  static let resolutionValueKey = "value"
}

// This is a nasty hack to get strongly-typed stubbing/verification parameters. The goal is to have
// `MockingbirdMatcher` "conform" to any reference or value type so that it's possible to pass both
// an actual concrete instance of a type OR a matcher. The method provides stronger compile-time
// guarantees and better autocomplete compared to simply conforming parameter types to a common
// protocol such as `Matchable`.
//
// Essentially the resolver takes in an autoclosure with either:
//   (1) a concrete instance of a type
//   (2) a call to `createTypeFacade<T>`
//
// The autoclosure is run on a separate thread so that if the autoclosure is (1) then the value is
// trivially returned and used. But if the autoclosure is (2) then a value (usually a matcher) is
// stored in the shared thread dictionary and the thread is terminated before the method returns.
// (An UnsafeMutablePointer<T> is provided to make the compiler happy, but is left initialized so
// will result in memory corruption if returned).
//
// It goes without saying that this should NEVER be done in production.
func createTypeFacade<T>(_ value: Any?) -> T {
  if Thread.current.name == Constants.resolutionThreadName {
    Thread.current.threadDictionary[Constants.resolutionValueKey] = value
    Thread.exit() // Could also throw an error here, but would require prefixing `try` to args..
  }
  let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
  return pointer.pointee
}

private class Resolver<T> {
  var value: T? = nil
  var fallbackValue: Any? = nil
  let semaphore = DispatchSemaphore(value: 0)
  
  private let parameter: () -> T
  private lazy var internalThread: Thread = {
    let thread = Thread(target: self, selector: #selector(run), object: nil)
    thread.name = Constants.resolutionThreadName
    return thread
  }()
  
  init(_ parameter: @escaping () -> T) {
    self.parameter = parameter
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleThreadExit(notification:)),
                                           name: .NSThreadWillExit,
                                           object: nil)
  }
  
  func resolve() {
    internalThread.start()
  }
  
  @objc private func handleThreadExit(notification: NSNotification) {
    guard let thread = notification.object as? Thread, thread == internalThread else { return }
    fallbackValue = thread.threadDictionary[Constants.resolutionValueKey]
    semaphore.signal()
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func run() {
    self.value = self.parameter()
    self.semaphore.signal()
  }
}

func resolve<T>(_ parameter: @escaping () -> T) -> Any? {
  let resolver = Resolver(parameter)
  resolver.resolve()
  resolver.semaphore.wait()
  return resolver.value ?? resolver.fallbackValue
}
