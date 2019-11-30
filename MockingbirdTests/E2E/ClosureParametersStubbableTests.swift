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
    -> Mockable<MethodDeclaration, (() -> Void) -> Bool, Bool>
  func trivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<MethodDeclaration, (() -> Bool) -> Bool, Bool>
  func parameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Mockable<MethodDeclaration, ((Bool) -> Void) -> Bool, Bool>
  func parameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Mockable<MethodDeclaration, ((Bool) -> Bool) -> Bool, Bool>
  
  func escapingTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<MethodDeclaration, (@escaping () -> Void) -> Bool, Bool>
  func escapingTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<MethodDeclaration, (@escaping () -> Bool) -> Bool, Bool>
  func escapingParameterizedClosure(block: @escaping @autoclosure () -> (Bool) -> Void)
    -> Mockable<MethodDeclaration, (@escaping (Bool) -> Void) -> Bool, Bool>
  func escapingParameterizedReturningClosure(block: @escaping @autoclosure () -> (Bool) -> Bool)
    -> Mockable<MethodDeclaration, (@escaping (Bool) -> Bool) -> Bool, Bool>
  
  func implicitEscapingTrivialClosure(block: @escaping @autoclosure () -> (() -> Void)?)
    -> Mockable<MethodDeclaration, ((() -> Void)?) -> Bool, Bool>
  func implicitEscapingTrivialReturningClosure(block: @escaping @autoclosure () -> (() -> Bool)?)
    -> Mockable<MethodDeclaration, ((() -> Bool)?) -> Bool, Bool>
  func implicitEscapingParameterizedClosure(block: @escaping @autoclosure () -> ((Bool) -> Void)?)
    -> Mockable<MethodDeclaration, (((Bool) -> Void)?) -> Bool, Bool>
  func implicitEscapingParameterizedReturningClosure(block: @escaping @autoclosure () -> ((Bool) -> Bool)?)
    -> Mockable<MethodDeclaration, (((Bool) -> Bool)?) -> Bool, Bool>
  
  func autoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<MethodDeclaration, (@autoclosure () -> Void) -> Bool, Bool>
  func autoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<MethodDeclaration, (@autoclosure () -> Bool) -> Bool, Bool>
  
  func escapingAutoclosureTrivialClosure(block: @escaping @autoclosure () -> () -> Void)
    -> Mockable<MethodDeclaration, (@escaping @autoclosure () -> Void) -> Bool, Bool>
  func escapingAutoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> () -> Bool)
    -> Mockable<MethodDeclaration, (@escaping @autoclosure () -> Bool) -> Bool, Bool>
}
extension ClosureParametersProtocolMock: StubbableClosureParametersProtocol {}
