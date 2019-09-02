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
  func getChildComputedInstanceVariable() -> Stubbable<Child, ChildMock, () -> Bool, Bool>
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Child, ChildMock, (Bool) -> Void, Void>
  
  func childTrivialInstanceMethod() -> Stubbable<Child, ChildMock, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Child, ChildMock, (Bool, Int) -> Bool, Bool>
  
  static func getChildClassVariable() -> Stubbable<ChildMock.Type, ChildMock.Type, () -> Bool, Bool>
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildMock.Type, ChildMock.Type, (Bool) -> Void, Void>
  static func childTrivialClassMethod() -> Stubbable<ChildMock.Type, ChildMock.Type, () -> Void, Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildMock.Type, ChildMock.Type, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable()
    -> Stubbable<Child, ChildMock, () -> Bool, Bool>
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Child, ChildMock, (Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod()
    -> Stubbable<Child, ChildMock, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Child, ChildMock, (Bool, Int) -> Bool, Bool>
  
  static func getParentClassVariable()
    -> Stubbable<ChildMock.Type, ChildMock.Type, () -> Bool, Bool>
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildMock.Type, ChildMock.Type, (Bool) -> Void, Void>
  static func parentTrivialClassMethod()
    -> Stubbable<ChildMock.Type, ChildMock.Type, () -> Void, Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildMock.Type, ChildMock.Type, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> Stubbable<Child, ChildMock, () -> Bool, Bool>
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Child, ChildMock, (Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Stubbable<Child, ChildMock, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Child, ChildMock, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentClassVariable()
    -> Stubbable<ChildMock.Type, ChildMock.Type, () -> Bool, Bool>
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildMock.Type, ChildMock.Type, (Bool) -> Void, Void>
  static func grandparentTrivialClassMethod()
    -> Stubbable<ChildMock.Type, ChildMock.Type, () -> Void, Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildMock.Type, ChildMock.Type, (Bool, Int) -> Bool, Bool>
}
extension ChildMock: StubbableChild {}
