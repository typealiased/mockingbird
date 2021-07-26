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
  func getChildComputedInstanceVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  func childTrivialInstanceMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @autoclosure () -> Bool,
                                        _ param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getChildClassVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  static func childTrivialClassMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  static func childParameterizedClassMethod(param1: @autoclosure () -> Bool,
                                            _ param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  func parentTrivialInstanceMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @autoclosure () -> Bool,
                                         _ param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getParentClassVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  static func parentTrivialClassMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  static func parentParameterizedClassMethod(param1: @autoclosure () -> Bool,
                                             _ param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  func grandparentTrivialInstanceMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @autoclosure () -> Bool,
                                              _ param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentClassVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  static func grandparentTrivialClassMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  static func grandparentParameterizedClassMethod(param1: @autoclosure () -> Bool,
                                                  _ param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
}
extension ChildMock: StubbableChild {}

// MARK: - Non-stubbable declarations

extension ChildMock {
  func setChildComputedInstanceVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  static func setChildClassVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  
  func setParentComputedInstanceVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  static func setParentClassVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  
  func setGrandparentComputedInstanceVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  static func setGrandparentClassVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
}
