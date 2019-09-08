//
//  Optionals.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/7/19.
//

import Foundation

protocol OptionalsProtocol {
  func methodWithOptionalParameter(param: Bool?)
  func methodWithOptionalVariadicParameter(param: Bool?...)
  func methodWithOptionalReturn() -> Bool?
  
  func methodWithMultiOptionalParameter(param: Bool???)
  func methodWithMultiOptionalVariadicParameter(param: Bool???...)
  func methodWithMultiOptionalReturn() -> Bool???
  
  func methodWithUnwrappedParameter(param: Bool!)
  func methodWithUnwrappedReturn() -> Bool!
  
  func methodWithUnwrappedCompoundParameter(param: (Bool?, Int)!)
  func methodWithUnwrappedCompoundReturn() -> (Bool?, Int)!
  
  func methodWithMultiUnwrappedOptionalParameter(param: Bool???!)
  func methodWithMultiUnwrappedOptionalReturn() -> Bool???!
  
  func methodWithMultiUnwrappedOptionalCompoundParameter(param: (Bool?, Int)???!)
  func methodWithMultiUnwrappedOptionalCompoundReturn() -> (Bool?, Int)???!
  
  var optionalVariable: Bool? { get }
  var unwrappedOptionalVariable: Bool! { get }
  var multiUnwrappedOptionalVariable: Bool???! { get }
}
