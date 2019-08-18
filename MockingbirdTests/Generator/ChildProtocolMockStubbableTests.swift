//
//  ChildProtocolMockStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird

// MARK: - Stubbable declarations

private protocol StubbableChildProtocol {
  // MARK: Child
  func getChildPrivateSetterInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  func getChildInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  func childTrivialInstanceMethod() -> MockingbirdScopedStub<Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedStub<Bool>
  
  static func getChildPrivateSetterStaticVariable() -> MockingbirdScopedStub<Bool>
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  static func getChildStaticVariable() -> MockingbirdScopedStub<Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  static func childTrivialStaticMethod() -> MockingbirdScopedStub<Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedStub<Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  func getParentInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  func parentTrivialInstanceMethod() -> MockingbirdScopedStub<Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedStub<Bool>
  
  static func getParentPrivateSetterStaticVariable() -> MockingbirdScopedStub<Bool>
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  static func getParentStaticVariable() -> MockingbirdScopedStub<Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  static func parentTrivialStaticMethod() -> MockingbirdScopedStub<Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedStub<Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  func getGrandparentInstanceVariable() -> MockingbirdScopedStub<Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  func grandparentTrivialInstanceMethod() -> MockingbirdScopedStub<Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedStub<Bool>
  
  static func getGrandparentPrivateSetterStaticVariable() -> MockingbirdScopedStub<Bool>
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  static func getGrandparentStaticVariable() -> MockingbirdScopedStub<Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedStub<Void>
  
  static func grandparentTrivialStaticMethod() -> MockingbirdScopedStub<Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedStub<Bool>
}
extension ChildProtocolMock: StubbableChildProtocol {}
