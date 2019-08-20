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
  func getChildPrivateSetterInstanceVariable() -> Stubbable<Bool>
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func getChildInstanceVariable() -> Stubbable<Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func childTrivialInstanceMethod() -> Stubbable<Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  static func getChildPrivateSetterStaticVariable() -> Stubbable<Bool>
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  static func getChildStaticVariable() -> Stubbable<Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  static func childTrivialStaticMethod() -> Stubbable<Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable() -> Stubbable<Bool>
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func getParentInstanceVariable() -> Stubbable<Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func parentTrivialInstanceMethod() -> Stubbable<Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  static func getParentPrivateSetterStaticVariable() -> Stubbable<Bool>
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  static func getParentStaticVariable() -> Stubbable<Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  static func parentTrivialStaticMethod() -> Stubbable<Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable() -> Stubbable<Bool>
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func getGrandparentInstanceVariable() -> Stubbable<Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  func grandparentTrivialInstanceMethod() -> Stubbable<Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
  
  static func getGrandparentPrivateSetterStaticVariable() -> Stubbable<Bool>
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  static func getGrandparentStaticVariable() -> Stubbable<Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<Void>
  
  static func grandparentTrivialStaticMethod() -> Stubbable<Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<Bool>
}
extension ChildProtocolMock: StubbableChildProtocol {}
