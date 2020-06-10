//
//  ChildMockMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird

// MARK: - Mockable declarations

private protocol MockableChild: Mock {
  // MARK: Child
  var childStoredPrivateSetterInstanceVariable: Bool { get }
  var childStoredFileprivateSetterInstanceVariable: Bool { get }
  
  var childComputedInstanceVariable: Bool { get }
  var childStoredInstanceVariable: Bool { get set }
  
  func childTrivialInstanceMethod()
  func childParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  static var childClassVariable: Bool { get }
  static func childTrivialClassMethod()
  static func childParameterizedClassMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Parent
  var parentStoredPrivateSetterInstanceVariable: Bool { get }
  var parentStoredFileprivateSetterInstanceVariable: Bool { get }
  
  var parentComputedInstanceVariable: Bool { get }
  var parentStoredInstanceVariable: Bool { get set }
  
  func parentTrivialInstanceMethod()
  func parentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  static var parentClassVariable: Bool { get }
  static func parentTrivialClassMethod()
  static func parentParameterizedClassMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Grandparent
  var grandparentStoredPrivateSetterInstanceVariable: Bool { get }
  var grandparentStoredFileprivateSetterInstanceVariable: Bool { get }
  
  var grandparentComputedInstanceVariable: Bool { get }
  var grandparentStoredInstanceVariable: Bool { get set }
  
  func grandparentTrivialInstanceMethod()
  func grandparentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  static var grandparentClassVariable: Bool { get }
  static func grandparentTrivialClassMethod()
  static func grandparentParameterizedClassMethod(param1: Bool, _ param2: Int) -> Bool
}
extension ChildMock: MockableChild {}

// MARK: Non-mockable declarations

private extension ChildMock {
  // MARK: Child
  var childPrivateInstanceVariable: Bool { return true }
  var childFileprivateInstanceVariable: Bool { return true }
  
  var childComputedPrivateInstanceVariable: Bool { return true }
  var childComputedFileprivateInstanceVariable: Bool { return true }
  
  func childPrivateTrivialInstanceMethod() {}
  func childFileprivateTrivialInstanceMethod() {}
  
  func childPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  func childFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  class var childPrivateClassVariable: Bool { return true }
  class var childFileprivateClassVariable: Bool { return true }
  
  class func childPrivateTrivialClassMethod() {}
  class func childFileprivateTrivialClassMethod() {}
  
  class func childPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  class func childFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  static var childPrivateComputedStaticVariable: Bool { return true }
  static var childFileprivateComputedStaticVariable: Bool { return true }
  
  var childPrivateStoredStaticVariable: Bool { return true }
  var childFileprivateStoredStaticVariable: Bool { return true }
  
  static func childPrivateTrivialStaticMethod() {}
  static func childFileprivateTrivialStaticMethod() {}
  static func childTrivialStaticMethod() {}
  
  static func childPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func childFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func childParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Parent
  var parentPrivateInstanceVariable: Bool { return true }
  var parentFileprivateInstanceVariable: Bool { return true }
  
  var parentComputedPrivateInstanceVariable: Bool { return true }
  var parentComputedFileprivateInstanceVariable: Bool { return true }
  
  func parentPrivateTrivialInstanceMethod() {}
  func parentFileprivateTrivialInstanceMethod() {}
  
  func parentPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  func parentFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  class var parentPrivateClassVariable: Bool { return true }
  class var parentFileprivateClassVariable: Bool { return true }
  
  class func parentPrivateTrivialClassMethod() {}
  class func parentFileprivateTrivialClassMethod() {}
  
  class func parentPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  class func parentFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  static var parentPrivateComputedStaticVariable: Bool { return true }
  static var parentFileprivateComputedStaticVariable: Bool { return true }
  
  var parentPrivateStoredStaticVariable: Bool { return true }
  var parentFileprivateStoredStaticVariable: Bool { return true }
  
  static func parentPrivateTrivialStaticMethod() {}
  static func parentFileprivateTrivialStaticMethod() {}
  static func parentTrivialStaticMethod() {}
  
  static func parentPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func parentFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func parentParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Grandparent
  var grandparentPrivateInstanceVariable: Bool { return true }
  var grandparentFileprivateInstanceVariable: Bool { return true }
  
  var grandparentComputedPrivateInstanceVariable: Bool { return true }
  var grandparentComputedFileprivateInstanceVariable: Bool { return true }
  
  func grandparentPrivateTrivialInstanceMethod() {}
  func grandparentFileprivateTrivialInstanceMethod() {}
  
  func grandparentPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  func grandparentFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  class var grandparentPrivateClassVariable: Bool { return true }
  class var grandparentFileprivateClassVariable: Bool { return true }
  
  class func grandparentPrivateTrivialClassMethod() {}
  class func grandparentFileprivateTrivialClassMethod() {}
  
  class func grandparentPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  class func grandparentFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  static var grandparentPrivateComputedStaticVariable: Bool { return true }
  static var grandparentFileprivateComputedStaticVariable: Bool { return true }
  
  var grandparentPrivateStoredStaticVariable: Bool { return true }
  var grandparentFileprivateStoredStaticVariable: Bool { return true }
  
  static func grandparentPrivateTrivialStaticMethod() {}
  static func grandparentFileprivateTrivialStaticMethod() {}
  static func grandparentTrivialStaticMethod() {}
  
  static func grandparentPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func grandparentFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func grandparentParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
}
