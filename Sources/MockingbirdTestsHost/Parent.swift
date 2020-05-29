//
//  Parent.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class Parent: Grandparent {
  // MARK: Instance
  private(set) var parentStoredPrivateSetterInstanceVariable = true
  fileprivate(set) var parentStoredFileprivateSetterInstanceVariable = true
  
  private var parentStoredPrivateInstanceVariable = true
  fileprivate var parentStoredFileprivateInstanceVariable = true
  var parentStoredInstanceVariable = true
  
  private var parentComputedPrivateInstanceVariable: Bool { return true }
  fileprivate var parentComputedFileprivateInstanceVariable: Bool { return true }
  var parentComputedInstanceVariable: Bool { return true }
  
  private func parentPrivateTrivialInstanceMethod() {}
  fileprivate func parentFileprivateTrivialInstanceMethod() {}
  func parentTrivialInstanceMethod() {}
  
  private func parentPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate func parentFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  func parentParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Class
  private class var parentPrivateClassVariable: Bool { return true }
  fileprivate class var parentFileprivateClassVariable: Bool { return true }
  class var parentClassVariable: Bool { return true }
  
  private class func parentPrivateTrivialClassMethod() {}
  fileprivate class func parentFileprivateTrivialClassMethod() {}
  class func parentTrivialClassMethod() {}
  
  private class func parentPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate class func parentFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  class func parentParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Static
  private static var parentPrivateComputedStaticVariable: Bool { return true }
  fileprivate static var parentFileprivateComputedStaticVariable: Bool { return true }
  static var parentComputedStaticVariable: Bool { return true }
  
  private var parentPrivateStoredStaticVariable = true
  fileprivate var parentFileprivateStoredStaticVariable = true
  static var parentStoredStaticVariable = true
  
  private static func parentPrivateTrivialStaticMethod() {}
  fileprivate static func parentFileprivateTrivialStaticMethod() {}
  static func parentTrivialStaticMethod() {}
  
  private static func parentPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate static func parentFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func parentParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
}
