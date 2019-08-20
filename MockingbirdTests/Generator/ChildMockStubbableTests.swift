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
  func getChildComputedInstanceVariable() -> Stubbable<Bool>
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func childTrivialInstanceMethod() -> Stubbable<Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  static func getChildClassVariable() -> Stubbable<Bool>
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  static func childTrivialClassMethod() -> Stubbable<Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> Stubbable<Bool>
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func parentTrivialInstanceMethod() -> Stubbable<Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  static func getParentClassVariable() -> Stubbable<Bool>
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  static func parentTrivialClassMethod() -> Stubbable<Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> Stubbable<Bool>
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func grandparentTrivialInstanceMethod() -> Stubbable<Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  static func getGrandparentClassVariable() -> Stubbable<Bool>
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  static func grandparentTrivialClassMethod() -> Stubbable<Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
}
extension ChildMock: StubbableChild {}
