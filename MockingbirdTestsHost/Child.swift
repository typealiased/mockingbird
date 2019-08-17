//
//  Child.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class Child: Parent {
  // MARK: Instance
  private(set) var childStoredPrivateSetterInstanceVariable = true
  fileprivate(set) var childStoredFileprivateSetterInstanceVariable = true
  
  private var childStoredPrivateInstanceVariable = true
  fileprivate var childStoredFileprivateInstanceVariable = true
  var childStoredInstanceVariable = true
  
  private var childComputedPrivateInstanceVariable: Bool { return true }
  fileprivate var childComputedFileprivateInstanceVariable: Bool { return true }
  var childComputedInstanceVariable: Bool { return true }
  
  private func childPrivateTrivialInstanceMethod() {}
  fileprivate func childFileprivateTrivialInstanceMethod() {}
  func childTrivialInstanceMethod() {}
  
  private func childPrivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate func childFileprivateParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  func childParameterizedInstanceMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Class
  private class var childPrivateClassVariable: Bool { return true }
  fileprivate class var childFileprivateClassVariable: Bool { return true }
  class var childClassVariable: Bool { return true }
  
  private class func childPrivateTrivialClassMethod() {}
  fileprivate class func childFileprivateTrivialClassMethod() {}
  class func childTrivialClassMethod() {}
  
  private class func childPrivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate class func childFileprivateParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  class func childParameterizedClassMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  
  // MARK: Static
  private static var childPrivateComputedStaticVariable: Bool { return true }
  fileprivate static var childFileprivateComputedStaticVariable: Bool { return true }
  static var childComputedStaticVariable: Bool { return true }
  
  private var childPrivateStoredStaticVariable = true
  fileprivate var childFileprivateStoredStaticVariable = true
  static var childStoredStaticVariable = true
  
  private static func childPrivateTrivialStaticMethod() {}
  fileprivate static func childFileprivateTrivialStaticMethod() {}
  static func childTrivialStaticMethod() {}
  
  private static func childPrivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  fileprivate static func childFileprivateParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
  static func childParameterizedStaticMethod(param1: Bool, _ param2: Int)
    -> Bool { return true }
}
