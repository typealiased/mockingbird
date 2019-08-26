//
//  OverloadedMethods.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/25/19.
//

import Foundation

protocol OverloadedMethodsProtocol {
  func overloadedParameters(param1: Bool, param2: Bool) -> Bool
  func overloadedParameters(param1: Int, param2: Int) -> Bool
  
  func overloadedReturnType() -> Bool
  func overloadedReturnType() -> Int
}

class OverloadedMethodsClass {
  func overloadedParameters(param1: Bool, param2: Bool) -> Bool { return true }
  func overloadedParameters(param1: Int, param2: Int) -> Bool { return true }
  
  func overloadedReturnType() -> Bool { return true }
  func overloadedReturnType() -> Int { return 1 }
}
