//
//  TypeFacade.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/3/19.
//

import Foundation

// This is a hack to get strongly-typed stubbing/verification parameters. The goal is to have
// `ArgumentMatcher` "conform" to any reference or value type so that it's possible to pass both
// an actual concrete instance of a type OR a matcher. The method provides stronger compile-time
// guarantees and better autocomplete compared to simply conforming parameter types to a common
// protocol such as `Matchable`.
//
// It goes without saying that this should probably never be done in production.
private class TypeFacade {
  static let shared = TypeFacade()
  static let threadValueKey = "co.bird.mockingbird.typefacade.value"
  static let threadDidSetValueKey = "co.bird.mockingbird.typefacade.didset-value"
  static let threadSemaphoreKey = "co.bird.mockingbird.typefacade.semaphore"
  static let sharedSemaphore = DispatchSemaphore(value: 1)
}

struct AnyObjectFake {}

private extension Thread {
  // Creating a shared DispatchSemaphore on the current thread without access to test-and-set.
  var typeFacadeSemaphore: DispatchSemaphore {
    TypeFacade.sharedSemaphore.wait()
    defer { TypeFacade.sharedSemaphore.signal() }
    
    if let semaphore = Thread.current.threadDictionary[TypeFacade.threadSemaphoreKey] as? DispatchSemaphore {
      return semaphore
    }
    let semaphore = DispatchSemaphore(value: 1)
    Thread.current.threadDictionary[TypeFacade.threadSemaphoreKey] = semaphore
    return semaphore
  }
}

func createTypeFacade<T>(_ value: Any?) -> T {
  // We can't use the casted TypeFacade directly, so we store the desired wrapped value on the heap.
  Thread.current.threadDictionary[TypeFacade.threadDidSetValueKey] = true
  Thread.current.threadDictionary[TypeFacade.threadValueKey] = value
  if let concreteType = AnyObjectFake() as? T { return concreteType }
  return Unmanaged.passUnretained(TypeFacade.shared)
    .toOpaque()
    .bindMemory(to: T.self, capacity: 1)
    .pointee
}

func resolve<T>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let semaphore = Thread.current.typeFacadeSemaphore
  semaphore.wait()
  defer { semaphore.signal() }
  
  Thread.current.threadDictionary[TypeFacade.threadDidSetValueKey] = false
  Thread.current.threadDictionary[TypeFacade.threadValueKey] = nil
  let realValue = parameter()
  guard Thread.current.threadDictionary[TypeFacade.threadDidSetValueKey] as? Bool == true else {
    if let matcher = realValue as? ArgumentMatcher { return matcher }
    return ArgumentMatcher(realValue)
  }
  return Thread.current.threadDictionary[TypeFacade.threadValueKey] as! ArgumentMatcher
}

// When `T` is known to be equatable at compile time.
func resolve<T: Equatable>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let semaphore = Thread.current.typeFacadeSemaphore
  semaphore.wait()
  defer { semaphore.signal() }
  
  Thread.current.threadDictionary[TypeFacade.threadDidSetValueKey] = false
  Thread.current.threadDictionary[TypeFacade.threadValueKey] = nil
  let realValue = parameter()
  guard Thread.current.threadDictionary[TypeFacade.threadDidSetValueKey] as? Bool == true else {
    if let matcher = realValue as? ArgumentMatcher { return matcher }
    return ArgumentMatcher(realValue)
  }
  return Thread.current.threadDictionary[TypeFacade.threadValueKey] as! ArgumentMatcher
}

// When the compiler knows the closure returns an ArgumentMatcher.
func resolve(_ parameter: @escaping () -> ArgumentMatcher) -> ArgumentMatcher {
  return parameter()
}
