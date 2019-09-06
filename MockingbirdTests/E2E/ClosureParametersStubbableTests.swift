//
//  ClosureParametersStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableClosureParametersProtocol {
  func trivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<(() -> Void) -> Bool, Bool>
  func trivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<(() -> Bool) -> Bool, Bool>
  func parameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Stubbable<((Bool) -> Void) -> Bool, Bool>
  func parameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Stubbable<((Bool) -> Bool) -> Bool, Bool>
  
  func escapingTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<(@escaping () -> Void) -> Bool, Bool>
  func escapingTrivialReturningVoidClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<(@escaping () -> Bool) -> Bool, Bool>
  func escapingParameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Stubbable<(@escaping (Bool) -> Void) -> Bool, Bool>
  func escapingParameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Stubbable<(@escaping (Bool) -> Bool) -> Bool, Bool>
  
  func autoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<(@autoclosure () -> Void) -> Bool, Bool>
  func autoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<(@autoclosure () -> Bool) -> Bool, Bool>
  
  func escapingAutoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<(@escaping @autoclosure () -> Void) -> Bool, Bool>
  func escapingAutoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<(@escaping @autoclosure () -> Bool) -> Bool, Bool>
}
extension ClosureParametersProtocolMock: StubbableClosureParametersProtocol {}
