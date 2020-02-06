//
//  ClosureParameters.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation

struct ClosureWrapper {
  let trivialClosure: () -> Void
  let trivialReturningClosure: () -> Bool
  let parameterizedClosure: (Bool) -> Void
  let parameterizedReturningClosure: (Bool) -> Bool
  
  let nullableTrivialClosure: (() -> Void)? = nil
  let nullableTrivialReturningClosure: (() -> Bool)? = nil
  let nullableParameterizedClosure: ((Bool) -> Void)? = nil
  let nullableParameterizedReturningClosure: ((Bool) -> Bool)? = nil
  
  init() {
    self.trivialClosure = {}
    self.trivialReturningClosure = { fatalError() }
    self.parameterizedClosure = { _ in }
    self.parameterizedReturningClosure = { _ in fatalError() }
  }
}

protocol ClosureParametersProtocol {
  func trivialClosure(block: () -> Void) -> Bool
  func trivialReturningClosure(block: () -> Bool) -> Bool
  func parameterizedClosure(block: (Bool) -> Void) -> Bool
  func parameterizedReturningClosure(block: (Bool) -> Bool) -> Bool
  
  func escapingTrivialClosure(block: @escaping () -> Void) -> Bool
  func escapingTrivialReturningClosure(block: @escaping () -> Bool) -> Bool
  func escapingParameterizedClosure(block: @escaping (Bool) -> Void) -> Bool
  func escapingParameterizedReturningClosure(block: @escaping (Bool) -> Bool) -> Bool
  
  func implicitEscapingTrivialClosure(block: (() -> Void)?) -> Bool
  func implicitEscapingTrivialReturningClosure(block: (() -> Bool)?) -> Bool
  func implicitEscapingParameterizedClosure(block: ((Bool) -> Void)?) -> Bool
  func implicitEscapingParameterizedReturningClosure(block: ((Bool) -> Bool)?) -> Bool
  
  func wrappedClosureParameter(block: ClosureWrapper) -> Bool
  
  func autoclosureTrivialClosure(block: @autoclosure () -> Void) -> Bool
  func autoclosureTrivialReturningClosure(block: @autoclosure () -> Bool) -> Bool
  
  func escapingAutoclosureTrivialClosure(block: @escaping @autoclosure () -> Void) -> Bool
  func escapingAutoclosureTrivialReturningClosure(block: @escaping @autoclosure () -> Bool) -> Bool
  
  func trivialParenthesizedClosure(block: (() -> Void)) -> Bool
  func trivialReturningParenthesizedClosure(block: (() -> Void)) -> Bool
  func parameterizedParenthesizedClosure(block: ((Bool) -> Void)) -> Bool
  func parameterizedReturningParenthesizedClosure(block: ((Bool) -> Bool)) -> Bool
  func nestedParameterizedReturningParenthesizedClosure(block: ((((Bool) -> Bool)))) -> Bool
  func nestedOptionalTrivialParenthesizedClosure(block: (((() -> Void)?))?) -> Bool
  
  func implicitEscapingMultipleTupleClosure(block: (() -> Void, (Bool) -> Bool)) -> Bool
  func implicitEscapingMultipleLabeledTupleClosure(block: (a: () -> Void, b: (Bool) -> Bool)) -> Bool
}
