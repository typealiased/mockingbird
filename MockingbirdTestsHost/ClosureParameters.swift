//
//  ClosureParameters.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation

protocol ClosureParametersProtocol {
  func trivialClosure(block: () -> Void) -> Bool
  func trivialReturningClosure(block: () -> Bool) -> Bool
  func parameterizedClosure(block: (Bool) -> Void) -> Bool
  func parameterizedReturningClosure(block: (Bool) -> Bool) -> Bool
  
  func escapingTrivialClosure(block: @escaping () -> Void) -> Bool
  func escapingTrivialReturningVoidClosure(block: @escaping () -> Bool) -> Bool
  func escapingParameterizedClosure(block: @escaping (Bool) -> Void) -> Bool
  func escapingParameterizedReturningClosure(block: @escaping (Bool) -> Bool) -> Bool
  
  func autoclosureTrivialClosure(block: @autoclosure () -> Void) -> Bool
  func autoclosureTrivialReturningClosure(block: @autoclosure () -> Bool) -> Bool
  
  func escapingAutoclosureTrivialClosure(block: @escaping @autoclosure () -> Void) -> Bool
  func escapingAutoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> Bool) -> Bool
}
