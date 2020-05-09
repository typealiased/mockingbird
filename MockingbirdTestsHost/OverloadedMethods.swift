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
  func overloadedParameters<T>(param1: T, param2: T) -> T
  
  func overloadedReturnType() -> Bool
  func overloadedReturnType() -> Int
  func overloadedGenericReturnType<T>() -> T
}

class OverloadedMethodsClass {
  func overloadedParameters(param1: Bool, param2: Bool) -> Bool { return true }
  func overloadedParameters(param1: Int, param2: Int) -> Bool { return true }
  func overloadedParameters<T>(param1: T, param2: T) -> T { fatalError() }
  
  func overloadedReturnType() -> Bool { return true }
  func overloadedReturnType() -> Int { return 1 }
  func overloadedGenericReturnType<T>() -> T { fatalError() }
}
