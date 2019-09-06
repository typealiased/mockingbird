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
  static let threadValueKey = "value"
  static let threadDidSetValueKey = "didset-value"
  static let threadScopeKey = DispatchSpecificKey<String>()
}

struct AnyObjectFake {}

extension DispatchQueue {
  class var threadScope: String? {
    return DispatchQueue.getSpecific(key: TypeFacade.threadScopeKey)
  }
}

func createTypeFacade<T>(_ value: Any?) -> T {
  // We can't use the casted TypeFacade directly, so we store the desired wrapped value on the heap.
  if let threadScope = DispatchQueue.threadScope {
    Thread.current.threadDictionary["\(threadScope)-\(TypeFacade.threadDidSetValueKey)"] = true
    Thread.current.threadDictionary["\(threadScope)-\(TypeFacade.threadValueKey)"] = value
  }
  
  // Trivial case where `T` is a non-nominal type such as `Any` or `AnyObject`.
  if let concreteType = AnyObjectFake() as? T { return concreteType }
  return Unmanaged.passUnretained(TypeFacade.shared)
    .toOpaque()
    .bindMemory(to: T.self, capacity: 1)
    .pointee
}

func resolve<T>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let scope = UUID().uuidString
  let scopedDidSetValueKey = "\(scope)-\(TypeFacade.threadDidSetValueKey)"
  let scopedValueKey = "\(scope)-\(TypeFacade.threadValueKey)"
  
  let queue = DispatchQueue(label: "co.bird.mockingbird.typefacade")
  queue.setSpecific(key: TypeFacade.threadScopeKey, value: scope)
  
  var resolvedMatcher: ArgumentMatcher!
  queue.sync {
    let realValue = parameter() // It's only safe to store this on the stack.
    guard Thread.current.threadDictionary[scopedDidSetValueKey] as? Bool == true else {
      if let matcher = realValue as? ArgumentMatcher {
        resolvedMatcher = matcher // `realValue` is already an `ArgumentMatcher`.
      } else {
        resolvedMatcher = ArgumentMatcher(realValue)
      }
      return
    }
    // Use the wrapped value returned by resolving type facade.
    resolvedMatcher = Thread.current.threadDictionary[scopedValueKey] as? ArgumentMatcher
  }
  return resolvedMatcher
}

// When `T` is known to be equatable at compile time.
func resolve<T: Equatable>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let scope = UUID().uuidString
  let scopedDidSetValueKey = "\(scope)-\(TypeFacade.threadDidSetValueKey)"
  let scopedValueKey = "\(scope)-\(TypeFacade.threadValueKey)"
  
  let queue = DispatchQueue(label: "co.bird.mockingbird.typefacade")
  queue.setSpecific(key: TypeFacade.threadScopeKey, value: scope)
  
  var resolvedMatcher: ArgumentMatcher!
  queue.sync {
    let realValue = parameter() // It's only safe to store this on the stack.
    guard Thread.current.threadDictionary[scopedDidSetValueKey] as? Bool == true else {
      if let matcher = realValue as? ArgumentMatcher {
        resolvedMatcher = matcher // `realValue` is already an `ArgumentMatcher`.
      } else {
        resolvedMatcher = ArgumentMatcher(realValue)
      }
      return
    }
    // Use the wrapped value returned by resolving type facade.
    resolvedMatcher = Thread.current.threadDictionary[scopedValueKey] as? ArgumentMatcher
  }
  return resolvedMatcher
}

// When the compiler knows the closure returns an ArgumentMatcher.
func resolve(_ parameter: @escaping () -> ArgumentMatcher) -> ArgumentMatcher {
  return parameter()
}
