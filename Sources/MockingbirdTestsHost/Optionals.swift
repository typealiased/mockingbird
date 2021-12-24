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
  func methodWithOptionalBridgedReturn() -> NSString?
  
  func methodWithMultiOptionalParameter(param: Bool???)
  func methodWithMultiOptionalVariadicParameter(param: Bool???...)
  func methodWithMultiOptionalReturn() -> Bool???
  func methodWithMultiOptionalBridgedReturn() -> NSString???
  
  func methodWithUnwrappedParameter(param: Bool!)
  func methodWithUnwrappedReturn() -> Bool!
  
  func methodWithUnwrappedCompoundParameter(param: (Bool?, Int)!)
  func methodWithUnwrappedCompoundReturn() -> (Bool?, Int)!
  
  func methodWithMultiUnwrappedOptionalParameter(param: Bool???!)
  func methodWithMultiUnwrappedOptionalReturn() -> Bool???!
  
  func methodWithMultiUnwrappedOptionalCompoundParameter(param: (Bool?, Int)???!)
  func methodWithMultiUnwrappedOptionalCompoundReturn() -> (Bool?, Int)???!
  
  var optionalVariable: Bool? { get set }
  var optionalBridgedVariable: NSString? { get set }
  var unwrappedOptionalVariable: Bool! { get set }
  var nestedOptionalVariable: Bool?? { get set }
  var nestedUnwrappedOptionalVariable: Bool???! { get set }
}
