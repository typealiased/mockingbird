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
  func trivialClosure(block: @autoclosure () -> () -> Void)
    -> Mockable<FunctionDeclaration, (() -> Void) -> Bool, Bool>
  func trivialReturningClosure(block: @autoclosure () -> () -> Bool)
    -> Mockable<FunctionDeclaration, (() -> Bool) -> Bool, Bool>
  func parameterizedClosure(block: @autoclosure () -> (Bool) -> Void)
    -> Mockable<FunctionDeclaration, ((Bool) -> Void) -> Bool, Bool>
  func parameterizedReturningClosure(block: @autoclosure () -> (Bool) -> Bool)
    -> Mockable<FunctionDeclaration, ((Bool) -> Bool) -> Bool, Bool>
  
  func escapingTrivialClosure(block: @autoclosure () -> () -> Void)
    -> Mockable<FunctionDeclaration, (@escaping () -> Void) -> Bool, Bool>
  func escapingTrivialReturningClosure(block: @autoclosure () -> () -> Bool)
    -> Mockable<FunctionDeclaration, (@escaping () -> Bool) -> Bool, Bool>
  func escapingParameterizedClosure(block: @autoclosure () -> (Bool) -> Void)
    -> Mockable<FunctionDeclaration, (@escaping (Bool) -> Void) -> Bool, Bool>
  func escapingParameterizedReturningClosure(block: @autoclosure () -> (Bool) -> Bool)
    -> Mockable<FunctionDeclaration, (@escaping (Bool) -> Bool) -> Bool, Bool>
  
  func implicitEscapingTrivialClosure(block: @autoclosure () -> (() -> Void)?)
    -> Mockable<FunctionDeclaration, ((() -> Void)?) -> Bool, Bool>
  func implicitEscapingTrivialReturningClosure(block: @autoclosure () -> (() -> Bool)?)
    -> Mockable<FunctionDeclaration, ((() -> Bool)?) -> Bool, Bool>
  func implicitEscapingParameterizedClosure(block: @autoclosure () -> ((Bool) -> Void)?)
    -> Mockable<FunctionDeclaration, (((Bool) -> Void)?) -> Bool, Bool>
  func implicitEscapingParameterizedReturningClosure(block: @autoclosure () -> ((Bool) -> Bool)?)
    -> Mockable<FunctionDeclaration, (((Bool) -> Bool)?) -> Bool, Bool>
  
  func autoclosureTrivialClosure(block: @autoclosure () -> () -> Void)
    -> Mockable<FunctionDeclaration, (@autoclosure () -> Void) -> Bool, Bool>
  func autoclosureTrivialReturningClosure(block: @autoclosure () -> () -> Bool)
    -> Mockable<FunctionDeclaration, (@autoclosure () -> Bool) -> Bool, Bool>
  
  func escapingAutoclosureTrivialClosure(block: @autoclosure () -> () -> Void)
    -> Mockable<FunctionDeclaration, (@escaping @autoclosure () -> Void) -> Bool, Bool>
  func escapingAutoclosureTrivialReturningClosure(block: @autoclosure () -> () -> Bool)
    -> Mockable<FunctionDeclaration, (@escaping @autoclosure () -> Bool) -> Bool, Bool>
}
extension ClosureParametersProtocolMock: StubbableClosureParametersProtocol {}
