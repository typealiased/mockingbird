//
//  ChildMockVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird

// MARK: - Verifiable declarations

private protocol VerifiableChild {
  // MARK: Child
  func getChildComputedInstanceVariable() -> MockingbirdScopedMock
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func childTrivialInstanceMethod() -> MockingbirdScopedMock
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getChildClassVariable() -> MockingbirdScopedMock
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  static func childTrivialClassMethod() -> MockingbirdScopedMock
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> MockingbirdScopedMock
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func parentTrivialInstanceMethod() -> MockingbirdScopedMock
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getParentClassVariable() -> MockingbirdScopedMock
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  static func parentTrivialClassMethod() -> MockingbirdScopedMock
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> MockingbirdScopedMock
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func grandparentTrivialInstanceMethod() -> MockingbirdScopedMock
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getGrandparentClassVariable() -> MockingbirdScopedMock
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  static func grandparentTrivialClassMethod() -> MockingbirdScopedMock
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
}
extension ChildMock: VerifiableChild {}
