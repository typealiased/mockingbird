//
//  ChildMockMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

// MARK: - Mockable declarations

protocol MockableChild {
  // MARK: Child
  var childComputedInstanceVariable: Bool { get }
  
  func childTrivialInstanceMethod()
  func childParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  static var childClassVariable: Bool { get }
  static func childTrivialClassMethod()
  static func childParameterizedClassMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Parent
  var parentComputedInstanceVariable: Bool { get }
  
  func parentTrivialInstanceMethod()
  func parentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  static var parentClassVariable: Bool { get }
  static func parentTrivialClassMethod()
  static func parentParameterizedClassMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Grandparent
  var grandparentComputedInstanceVariable: Bool { get }
  
  func grandparentTrivialInstanceMethod()
  func grandparentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  static var grandparentClassVariable: Bool { get }
  static func grandparentTrivialClassMethod()
  static func grandparentParameterizedClassMethod(param1: Bool, _ param2: Int) -> Bool
}
extension ChildMock: MockableChild {}

// MARK: Non-mockable declarations

extension ChildMock {
  // MARK: Child
  var childStoredPrivateSetterInstanceVariable: Bool { return true }
  var childStoredFileprivateSetterInstanceVariable: Bool { return true }
  
  private var childPrivateInstanceVariable: Bool { return true }
  fileprivate var childFileprivateInstanceVariable: Bool { return true }
  var childStoredInstanceVariable: Bool { return true }
  
  private var childComputedPrivateInstanceVariable: Bool { return true }
  fileprivate var childComputedFileprivateInstanceVariable: Bool { return true }
  
  private func childPrivateTrivialInstanceMethod() {}
  fileprivate func childFileprivateTrivialInstanceMethod() {}
  
  private func childPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate func childFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  private class var childPrivateClassVariable: Bool { return true }
  fileprivate class var childFileprivateClassVariable: Bool { return true }
  
  private class func childPrivateTrivialClassMethod() {}
  fileprivate class func childFileprivateTrivialClassMethod() {}
  
  private class func childPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate class func childFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  private static var childPrivateComputedStaticVariable: Bool { return true }
  fileprivate static var childFileprivateComputedStaticVariable: Bool { return true }
  
  private var childPrivateStoredStaticVariable: Bool { return true }
  fileprivate var childFileprivateStoredStaticVariable: Bool { return true }
  
  private static func childPrivateTrivialStaticMethod() {}
  fileprivate static func childFileprivateTrivialStaticMethod() {}
  static func childTrivialStaticMethod() {}
  
  private static func childPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate static func childFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func childParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Parent
  var parentStoredPrivateSetterInstanceVariable: Bool { return true }
  var parentStoredFileprivateSetterInstanceVariable: Bool { return true }
  
  private var parentPrivateInstanceVariable: Bool { return true }
  fileprivate var parentFileprivateInstanceVariable: Bool { return true }
  var parentStoredInstanceVariable: Bool { return true }
  
  private var parentComputedPrivateInstanceVariable: Bool { return true }
  fileprivate var parentComputedFileprivateInstanceVariable: Bool { return true }
  
  private func parentPrivateTrivialInstanceMethod() {}
  fileprivate func parentFileprivateTrivialInstanceMethod() {}
  
  private func parentPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate func parentFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  private class var parentPrivateClassVariable: Bool { return true }
  fileprivate class var parentFileprivateClassVariable: Bool { return true }
  
  private class func parentPrivateTrivialClassMethod() {}
  fileprivate class func parentFileprivateTrivialClassMethod() {}
  
  private class func parentPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate class func parentFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  private static var parentPrivateComputedStaticVariable: Bool { return true }
  fileprivate static var parentFileprivateComputedStaticVariable: Bool { return true }
  
  private var parentPrivateStoredStaticVariable: Bool { return true }
  fileprivate var parentFileprivateStoredStaticVariable: Bool { return true }
  
  private static func parentPrivateTrivialStaticMethod() {}
  fileprivate static func parentFileprivateTrivialStaticMethod() {}
  static func parentTrivialStaticMethod() {}
  
  private static func parentPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate static func parentFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func parentParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Grandparent
  var grandparentStoredPrivateSetterInstanceVariable: Bool { return true }
  var grandparentStoredFileprivateSetterInstanceVariable: Bool { return true }
  
  private var grandparentPrivateInstanceVariable: Bool { return true }
  fileprivate var grandparentFileprivateInstanceVariable: Bool { return true }
  var grandparentStoredInstanceVariable: Bool { return true }
  
  private var grandparentComputedPrivateInstanceVariable: Bool { return true }
  fileprivate var grandparentComputedFileprivateInstanceVariable: Bool { return true }
  
  private func grandparentPrivateTrivialInstanceMethod() {}
  fileprivate func grandparentFileprivateTrivialInstanceMethod() {}
  
  private func grandparentPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate func grandparentFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  private class var grandparentPrivateClassVariable: Bool { return true }
  fileprivate class var grandparentFileprivateClassVariable: Bool { return true }
  
  private class func grandparentPrivateTrivialClassMethod() {}
  fileprivate class func grandparentFileprivateTrivialClassMethod() {}
  
  private class func grandparentPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate class func grandparentFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  private static var grandparentPrivateComputedStaticVariable: Bool { return true }
  fileprivate static var grandparentFileprivateComputedStaticVariable: Bool { return true }
  
  private var grandparentPrivateStoredStaticVariable: Bool { return true }
  fileprivate var grandparentFileprivateStoredStaticVariable: Bool { return true }
  
  private static func grandparentPrivateTrivialStaticMethod() {}
  fileprivate static func grandparentFileprivateTrivialStaticMethod() {}
  static func grandparentTrivialStaticMethod() {}
  
  private static func grandparentPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate static func grandparentFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func grandparentParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
}

