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
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (() -> Void) -> Bool, Bool>
  func trivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (() -> Bool) -> Bool, Bool>
  func parameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, ((Bool) -> Void) -> Bool, Bool>
  func parameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, ((Bool) -> Bool) -> Bool, Bool>
  
  func escapingTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@escaping () -> Void) -> Bool, Bool>
  func escapingTrivialReturningVoidClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@escaping () -> Bool) -> Bool, Bool>
  func escapingParameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@escaping (Bool) -> Void) -> Bool, Bool>
  func escapingParameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@escaping (Bool) -> Bool) -> Bool, Bool>
  
  func autoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@autoclosure () -> Void) -> Bool, Bool>
  func autoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@autoclosure () -> Bool) -> Bool, Bool>
  
  func escapingAutoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@escaping @autoclosure () -> Void) -> Bool, Bool>
  func escapingAutoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Stubbable<ClosureParametersProtocol, ClosureParametersProtocolMock, (@escaping @autoclosure () -> Bool) -> Bool, Bool>
}
extension ClosureParametersProtocolMock: StubbableClosureParametersProtocol {}
