//
//  Grandparent.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class Grandparent {
  // MARK: Instance
  private(set) var grandparentStoredPrivateSetterInstanceVariable = true
  fileprivate(set) var grandparentStoredFileprivateSetterInstanceVariable = true
  
  private var grandparentStoredPrivateInstanceVariable = true
  fileprivate var grandparentStoredFileprivateInstanceVariable = true
  var grandparentStoredInstanceVariable = true
  
  private var grandparentComputedPrivateInstanceVariable: Bool { return true }
  fileprivate var grandparentComputedFileprivateInstanceVariable: Bool { return true }
  var grandparentComputedInstanceVariable: Bool { return true }
  
  private func grandparentPrivateTrivialInstanceMethod() {}
  fileprivate func grandparentFileprivateTrivialInstanceMethod() {}
  func grandparentTrivialInstanceMethod() {}
  
  private func grandparentPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate func grandparentFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  func grandparentParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Class
  private class var grandparentPrivateClassVariable: Bool { return true }
  fileprivate class var grandparentFileprivateClassVariable: Bool { return true }
  class var grandparentClassVariable: Bool { return true }
  
  private class func grandparentPrivateTrivialClassMethod() {}
  fileprivate class func grandparentFileprivateTrivialClassMethod() {}
  class func grandparentTrivialClassMethod() {}
  
  private class func grandparentPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate class func grandparentFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  class func grandparentParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Static
  private static var grandparentPrivateComputedStaticVariable: Bool { return true }
  fileprivate static var grandparentFileprivateComputedStaticVariable: Bool { return true }
  static var grandparentComputedStaticVariable: Bool { return true }
  
  private var grandparentPrivateStoredStaticVariable = true
  fileprivate var grandparentFileprivateStoredStaticVariable = true
  static var grandparentStoredStaticVariable = true
  
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
