//
//  FakeableTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 4/11/20.
//

import Foundation

// MARK: - Types

class FakeableClass {
  init(param: String) {}
}

class FakeableGenericClass<T> {}

protocol FakeableProtocol {}

struct FakeableStruct: Equatable {
  let value: Int
}

enum FakeableEnum {
  case foo, bar
}

typealias FakeableTypealias = Bool


// MARK: - Referencer

protocol FakeableTypeReferencer {
  func fakeableClass() -> FakeableClass
  func fakeableGenericClass<T>() -> FakeableGenericClass<T>
  func fakeableProtocol() -> FakeableProtocol
  func fakeableStruct() -> FakeableStruct
  func fakeableEnum() -> FakeableEnum
  func fakeableTypealias() -> FakeableTypealias
  
  // MARK: Primitives
  func fakeableInt() -> Int
  func fakeableUInt() -> UInt
  func fakeableFloat() -> Float
  func fakeableDouble() -> Double
  func fakeableBool() -> Bool
  func fakeableString() -> String
  func fakeableCGFloat() -> CGFloat
  func fakeableCGPoint() -> CGPoint
  func fakeableDate() -> Date
  
  // MARK: Collections
  func fakeableArray() -> Array<String>
  func fakeableSet() -> Set<String>
  func fakeableDictionary() -> Dictionary<String, Int>
  
  // MARK: Tuples
  func fakeable2Tuple() -> (String, Int)
  func fakeable3Tuple() -> (String, Int, Bool)
  func fakeable4Tuple() -> (String, Int, Bool, Double)
  func fakeable5Tuple() -> (String, Int, Bool, Double, Float)
  func fakeable6Tuple() -> (String, Int, Bool, Double, Float, UInt)
}
