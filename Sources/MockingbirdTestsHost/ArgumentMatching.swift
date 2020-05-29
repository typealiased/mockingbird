//
//  ArgumentMatching.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

protocol BaseProtocol: Equatable {}

struct StructType: BaseProtocol {
  let value: Int
  init(value: Int = 42) {
    self.value = value
  }
}

class ClassType: BaseProtocol {
  static func == (lhs: ClassType, rhs: ClassType) -> Bool { return true }
  let identifier: String = "foo-bar"
  let value: Int = 42
}

enum EnumType {
  case success, failure
}

protocol ArgumentMatchingProtocol {
  func method(structType: StructType) -> Bool
  func method(classType: ClassType) -> Bool
  func method(enumType: EnumType) -> Bool
  func method(stringType: String) -> Bool
  func method(boolType: Bool) -> Bool
  func method<P: BaseProtocol>(protocolType: P) -> Bool
  func method(metaType: ClassType.Type) -> Bool
  func method(anyType: Any) -> Bool
  func method(anyObjectType: AnyObject) -> Bool
  
  func method(optionalStructType: StructType?) -> Bool
  func method(optionalClassType: ClassType?) -> Bool
  func method(optionalEnumType: EnumType?) -> Bool
  func method(optionalStringType: String?) -> Bool
  func method(optionalBoolType: Bool?) -> Bool
  func method<P: BaseProtocol>(optionalProtocolType: P?) -> Bool
  func method(optionalMetaType: ClassType.Type?) -> Bool
  func method(optionalAnyType: Any?) -> Bool
  func method(optionalAnyObjectType: AnyObject?) -> Bool
  
  func method<T: FloatingPoint>(floatingPoint: T) -> Bool
}
