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

protocol VerifiableChild {
  // MARK: Child
  func getChildComputedInstanceVariable() -> MockingbirdScopedMock
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func childTrivialInstanceMethod() -> MockingbirdScopedMock
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getChildClassVariable() -> MockingbirdScopedStub<Bool>
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  static func childTrivialClassMethod() -> MockingbirdScopedStub<Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func parentTrivialInstanceMethod() -> MockingbirdScopedStub<Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getParentClassVariable() -> MockingbirdScopedStub<Bool>
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  static func parentTrivialClassMethod() -> MockingbirdScopedStub<Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func grandparentTrivialInstanceMethod() -> MockingbirdScopedStub<Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getGrandparentClassVariable() -> MockingbirdScopedStub<Bool>
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  static func grandparentTrivialClassMethod() -> MockingbirdScopedStub<Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
}
extension ChildMock: VerifiableChild {}
