//
//  ChildMockStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableChild {
  // MARK: Child
  func getChildComputedInstanceVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func childTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getChildClassVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func childTrivialClassMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func parentTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getParentClassVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func parentTrivialClassMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func grandparentTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentClassVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func grandparentTrivialClassMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
}
extension ChildMock: StubbableChild {}

// MARK: - Non-stubbable declarations

extension ChildMock {
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
}
