//
//  ChildProtocolMockVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird

// MARK: - Verifiable declarations

private protocol VerifiableChildProtocol {
  // MARK: Child
  func getChildPrivateSetterInstanceVariable() -> MockingbirdScopedMock
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func getChildInstanceVariable() -> MockingbirdScopedMock
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func childTrivialInstanceMethod() -> MockingbirdScopedMock
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getChildPrivateSetterStaticVariable() -> MockingbirdScopedMock
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  static func getChildStaticVariable() -> MockingbirdScopedMock
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  static func childTrivialStaticMethod() -> MockingbirdScopedMock
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable() -> MockingbirdScopedMock
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func getParentInstanceVariable() -> MockingbirdScopedMock
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func parentTrivialInstanceMethod() -> MockingbirdScopedMock
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getParentPrivateSetterStaticVariable() -> MockingbirdScopedMock
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  static func getParentStaticVariable() -> MockingbirdScopedMock
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  static func parentTrivialStaticMethod() -> MockingbirdScopedMock
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable() -> MockingbirdScopedMock
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func getGrandparentInstanceVariable() -> MockingbirdScopedMock
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  func grandparentTrivialInstanceMethod() -> MockingbirdScopedMock
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
  
  static func getGrandparentPrivateSetterStaticVariable() -> MockingbirdScopedMock
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  static func getGrandparentStaticVariable() -> MockingbirdScopedMock
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> MockingbirdScopedMock
  
  static func grandparentTrivialStaticMethod() -> MockingbirdScopedMock
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> MockingbirdScopedMock
}
extension ChildProtocolMock: VerifiableChildProtocol {}
