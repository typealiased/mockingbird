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
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  func getChildInstanceVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func childTrivialInstanceMethod()
    -> Mockable<FunctionDeclaration, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getChildPrivateSetterStaticVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  static func getChildStaticVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  static func childTrivialStaticMethod()
    -> Mockable<FunctionDeclaration, () -> Void, Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  func getParentInstanceVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod()
    -> Mockable<FunctionDeclaration, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getParentPrivateSetterStaticVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  static func getParentStaticVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  static func parentTrivialStaticMethod()
    -> Mockable<FunctionDeclaration, () -> Void, Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  func getGrandparentInstanceVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentPrivateSetterStaticVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  
  static func getGrandparentStaticVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  static func grandparentTrivialStaticMethod()
    -> Mockable<FunctionDeclaration, () -> Void, Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, (Bool, Int) -> Bool, Bool>
}
extension ChildProtocolMock: StubbableChildProtocol {}

extension ChildProtocolMock {
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
}
