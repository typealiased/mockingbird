//
//  ChildProtocolMockStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableChildProtocol {
  // MARK: Child
  func getChildPrivateSetterInstanceVariable()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Bool, Bool>
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool) -> Void, Void>
  
  func getChildInstanceVariable()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Bool, Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool) -> Void, Void>
  
  func childTrivialInstanceMethod()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool, Int) -> Bool, Bool>
  
  static func getChildPrivateSetterStaticVariable()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Bool, Bool>
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool) -> Void, Void>
  
  static func getChildStaticVariable()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Bool, Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool) -> Void, Void>
  
  static func childTrivialStaticMethod()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Void, Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Bool, Bool>
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool) -> Void, Void>
  
  func getParentInstanceVariable()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Bool, Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool, Int) -> Bool, Bool>
  
  static func getParentPrivateSetterStaticVariable()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Bool, Bool>
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool) -> Void, Void>
  
  static func getParentStaticVariable()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Bool, Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool) -> Void, Void>
  
  static func parentTrivialStaticMethod()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Void, Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable()
    -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Bool, Bool>
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool) -> Void, Void>
  
  func getGrandparentInstanceVariable() -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Bool, Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Stubbable<ChildProtocol, ChildProtocolMock, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildProtocol, ChildProtocolMock, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentPrivateSetterStaticVariable()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Bool, Bool>
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool) -> Void, Void>
  
  static func getGrandparentStaticVariable()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Bool, Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool) -> Void, Void>
  
  static func grandparentTrivialStaticMethod()
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, () -> Void, Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> Stubbable<ChildProtocolMock.Type, ChildProtocolMock.Type, (Bool, Int) -> Bool, Bool>
}
extension ChildProtocolMock: StubbableChildProtocol {}
