//
//  ClosureParametersVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableClosureParametersProtocol {
  func trivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<Bool>
  func trivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<Bool>
  func parameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Mockable<Bool>
  func parameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Mockable<Bool>
  
  func escapingTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<Bool>
  func escapingTrivialReturningVoidClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<Bool>
  func escapingParameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Mockable<Bool>
  func escapingParameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Mockable<Bool>
  
  func autoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<Bool>
  func autoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<Bool>
  
  func escapingAutoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<Bool>
  func escapingAutoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<Bool>
}
extension ClosureParametersProtocolMock: VerifiableClosureParametersProtocol {}
