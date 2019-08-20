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
  func getChildPrivateSetterInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func getChildInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func childTrivialInstanceMethod() -> Stubbable<() -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  static func getChildPrivateSetterStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func getChildStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func childTrivialStaticMethod() -> Stubbable<() -> Void, Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func getParentInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod() -> Stubbable<() -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  static func getParentPrivateSetterStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func getParentStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func parentTrivialStaticMethod() -> Stubbable<() -> Void, Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func getGrandparentInstanceVariable() -> Stubbable<() -> Bool, Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Stubbable<() -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
  
  static func getGrandparentPrivateSetterStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func getGrandparentStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func grandparentTrivialStaticMethod() -> Stubbable<() -> Void, Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<(Bool, Int) -> Bool, Bool>
}
extension ChildProtocolMock: StubbableChildProtocol {}
