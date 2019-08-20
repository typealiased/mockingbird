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
  func getChildComputedInstanceVariable() -> Mockable<Bool>
  func setChildComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func childTrivialInstanceMethod() -> Mockable<Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  static func getChildClassVariable() -> Mockable<Bool>
  static func setChildClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  static func childTrivialClassMethod() -> Mockable<Void>
  static func childParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                            _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  // MARK: Parent
  func getParentComputedInstanceVariable() -> Mockable<Bool>
  func setParentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func parentTrivialInstanceMethod() -> Mockable<Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  static func getParentClassVariable() -> Mockable<Bool>
  static func setParentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  static func parentTrivialClassMethod() -> Mockable<Void>
  static func parentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  // MARK: Grandparent
  func getGrandparentComputedInstanceVariable() -> Mockable<Bool>
  func setGrandparentComputedInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func grandparentTrivialInstanceMethod() -> Mockable<Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  static func getGrandparentClassVariable() -> Mockable<Bool>
  static func setGrandparentClassVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  static func grandparentTrivialClassMethod() -> Mockable<Void>
  static func grandparentParameterizedClassMethod(param1: @escaping @autoclosure () -> Bool,
                                                  _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
}
extension ChildMock: VerifiableChild {}
