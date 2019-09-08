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
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func getChildInstanceVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func childTrivialInstanceMethod()
    -> Mockable<MethodDeclaration, () -> Void, Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getChildPrivateSetterStaticVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  static func getChildStaticVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  static func childTrivialStaticMethod()
    -> Mockable<MethodDeclaration, () -> Void, Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func getParentInstanceVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func parentTrivialInstanceMethod()
    -> Mockable<MethodDeclaration, () -> Void, Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getParentPrivateSetterStaticVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  static func getParentStaticVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  static func parentTrivialStaticMethod()
    -> Mockable<MethodDeclaration, () -> Void, Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func getGrandparentInstanceVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func grandparentTrivialInstanceMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
  
  static func getGrandparentPrivateSetterStaticVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  static func getGrandparentStaticVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  static func grandparentTrivialStaticMethod()
    -> Mockable<MethodDeclaration, () -> Void, Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<MethodDeclaration, (Bool, Int) -> Bool, Bool>
}
extension ChildProtocolMock: StubbableChildProtocol {}

extension ChildProtocolMock {
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
}
