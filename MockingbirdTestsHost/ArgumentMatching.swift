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
  func method<P: BaseProtocol>(structType: StructType,
              classType: ClassType,
              enumType: EnumType,
              stringType: String,
              boolType: Bool,
              protocolType: P,
              metaType: ClassType.Type,
              anyType: Any,
              anyObjectType: AnyObject) -> Bool
  
  func method<P: BaseProtocol>(optionalStructType: StructType?,
              optionalClassType: ClassType?,
              optionalEnumType: EnumType?,
              optionalStringType: String?,
              optionalBoolType: Bool?,
              optionalProtocolType: P?,
              optionalMetaType: ClassType.Type?,
              optionalAnyType: Any?,
              optionalAnyObjectType: AnyObject?) -> Bool
}
