//
//  ChildMockStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird

// MARK: - Stubbable declarations

private protocol StubbableChild {
  // MARK: Child
  func getChildComputedInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func childTrivialInstanceMethod() -> Stubbable<() -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  static func getChildClassVariable() -> Stubbable<() -> Bool, Bool>
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  static func childTrivialClassMethod() -> Stubbable<() -> Void, Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod() -> Stubbable<() -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  static func getParentClassVariable() -> Stubbable<() -> Bool, Bool>
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  static func parentTrivialClassMethod() -> Stubbable<() -> Void, Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Stubbable<() -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  static func getGrandparentClassVariable() -> Stubbable<() -> Bool, Bool>
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  static func grandparentTrivialClassMethod() -> Stubbable<() -> Void, Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
}
extension ChildMock: StubbableChild {}
