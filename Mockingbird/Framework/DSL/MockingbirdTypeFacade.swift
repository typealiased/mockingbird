//
//  MockingbirdTypeFacade.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/3/19.
//

import Foundation

// This is a hack to get strongly-typed stubbing/verification parameters. The goal is to have
// `MockingbirdMatcher` "conform" to any reference or value type so that it's possible to pass both
// an actual concrete instance of a type OR a matcher. The method provides stronger compile-time
// guarantees and better autocomplete compared to simply conforming parameter types to a common
// protocol such as `Matchable`.
//
// It goes without saying that this should probably never be done in production.
private class TypeFacade {
  static let shared = TypeFacade()
  static let threadValueKey = "co.bird.mockingbird.typefacade.value"
}

struct Matcher {}

func createTypeFacade<T>(_ value: Any?) -> T {
  // We can't use the casted TypeFacade directly, so we store the desired wrapped value on the heap.
  Thread.current.threadDictionary[TypeFacade.threadValueKey] = value
  return Unmanaged.passUnretained(TypeFacade.shared)
    .toOpaque()
    .bindMemory(to: T.self, capacity: 1)
    .pointee
}

func resolve<T>(_ parameter: @escaping () -> T) -> Any? {
  Thread.current.threadDictionary[TypeFacade.threadValueKey] = nil
  let realValue = parameter()
  if let facadeValue = Thread.current.threadDictionary[TypeFacade.threadValueKey] {
      return facadeValue
  }
  return realValue
}
