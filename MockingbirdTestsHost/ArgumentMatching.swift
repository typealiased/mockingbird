//
//  ArgumentMatching.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

struct StructType: Equatable {
  let identifier: String = "foo-bar"
  let value: Int
  init(value: Int = 42) {
    self.value = value
  }
}

class ClassType {
  let identifier: String = "foo-bar"
  let value: Int = 42
}

enum EnumType {
  case success, failure
}

protocol ArgumentMatchingProtocol {
  func method(structType: StructType,
              classType: ClassType,
              enumType: EnumType,
              stringType: String,
              boolType: Bool,
              metaType: ClassType.Type,
              anyType: Any,
              anyObjectType: AnyObject) -> Bool
  
  func method(optionalStructType: StructType?,
              optionalClassType: ClassType?,
              optionalEnumType: EnumType?,
              optionalStringType: String?,
              optionalBoolType: Bool?,
              optionalMetaType: ClassType.Type?,
              optionalAnyType: Any?,
              optionalAnyObjectType: AnyObject?) -> Bool
}
