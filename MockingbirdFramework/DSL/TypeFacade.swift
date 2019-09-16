//
//  TypeFacade.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/3/19.
//

import Foundation

/// This is a hack to get strongly-typed stubbing/verification parameters. The goal is to have
/// `ArgumentMatcher` "conform" to any reference or value type so that it's possible to pass both
/// an actual concrete instance of a type OR a matcher. The method provides stronger compile-time
/// guarantees and better autocomplete compared to simply conforming parameter types to a common
/// protocol such as `Matchable`.
///
/// It goes without saying that this should probably never be done in production.
class TypeFacade {
  static let shared = TypeFacade()
  
  class StoredValue {
    var value: Any? {
      didSet { isSet = true }
    }
    private(set) var isSet = false
  }
  static let storedValueKey = DispatchSpecificKey<StoredValue>()
}

struct AnyObjectFake {}

extension DispatchQueue {
  class var storedValue: TypeFacade.StoredValue? {
    return DispatchQueue.getSpecific(key: TypeFacade.storedValueKey)
  }
}

/// Wraps a value into any type `T`.
func createTypeFacade<T>(_ value: Any?) -> T {
  // We can't return `value` directly, so we return it using the KV store on `DispatchQueue`.
  if let storedValue = DispatchQueue.storedValue { storedValue.value = value }
  
  // Trivial case where `T` is a non-nominal type such as `Any` or `AnyObject`.
  if let concreteType = AnyObjectFake() as? T { return concreteType }
  return Unmanaged.passUnretained(TypeFacade.shared)
    .toOpaque()
    .bindMemory(to: T.self, capacity: 1)
    .pointee
}

/// Resolve `parameter` when `T` is _not_ known to be `Equatable`.
func resolve<T>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let storedValue = TypeFacade.StoredValue()
  let queue = DispatchQueue(label: "co.bird.mockingbird.typefacade")
  queue.setSpecific(key: TypeFacade.storedValueKey, value: storedValue)
  var resolvedMatcher: ArgumentMatcher!
  queue.sync {
    let realValue = parameter() // It's only safe to store this on the stack.
    guard storedValue.isSet else { // The closure contained a concrete `T` instance.
      if let matcher = realValue as? ArgumentMatcher {
        resolvedMatcher = matcher // `realValue` is already an `ArgumentMatcher`.
      } else {
        resolvedMatcher = ArgumentMatcher(realValue)
      }
      return
    }
    // Use the wrapped value returned by resolving the type facade closure.
    resolvedMatcher = storedValue.value as? ArgumentMatcher
  }
  return resolvedMatcher
}

/// Resolve `parameter` when `T` is known to be `Equatable`.
func resolve<T: Equatable>(_ parameter: @escaping () -> T) -> ArgumentMatcher {
  let storedValue = TypeFacade.StoredValue()
  let queue = DispatchQueue(label: "co.bird.mockingbird.typefacade")
  queue.setSpecific(key: TypeFacade.storedValueKey, value: storedValue)
  var resolvedMatcher: ArgumentMatcher!
  queue.sync {
    let realValue = parameter() // It's only safe to store this on the stack.
    guard storedValue.isSet else { // The closure contained a concrete `T` instance.
      if let matcher = realValue as? ArgumentMatcher {
        resolvedMatcher = matcher // `realValue` is already an `ArgumentMatcher`.
      } else {
        resolvedMatcher = ArgumentMatcher(realValue)
      }
      return
    }
    // Use the wrapped value returned by resolving the type facade closure.
    resolvedMatcher = storedValue.value as? ArgumentMatcher
  }
  return resolvedMatcher
}

/// Resolve `parameter` when the closure returns an `ArgumentMatcher`.
func resolve(_ parameter: @escaping () -> ArgumentMatcher) -> ArgumentMatcher {
  return parameter()
}
