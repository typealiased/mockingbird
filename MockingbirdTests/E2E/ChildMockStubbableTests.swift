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
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func childTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getChildClassVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  static func childTrivialClassMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getParentClassVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  static func parentTrivialClassMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentClassVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  static func grandparentTrivialClassMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
}
extension ChildMock: StubbableChild {}
