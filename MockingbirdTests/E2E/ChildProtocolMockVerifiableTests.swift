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
  func getChildPrivateSetterInstanceVariable() -> Mockable<Bool>
  func setChildPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func getChildInstanceVariable() -> Mockable<Bool>
  func setChildInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func childTrivialInstanceMethod() -> Mockable<Void>
  func childParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                        _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  static func getChildPrivateSetterStaticVariable() -> Mockable<Bool>
  static func setChildPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func getChildStaticVariable() -> Mockable<Bool>
  static func setChildStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func childTrivialStaticMethod() -> Mockable<Void>
  static func childParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                             _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  // MARK: Parent
  func getParentPrivateSetterInstanceVariable() -> Mockable<Bool>
  func setParentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func getParentInstanceVariable() -> Mockable<Bool>
  func setParentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func parentTrivialInstanceMethod() -> Mockable<Void>
  func parentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                         _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  static func getParentPrivateSetterStaticVariable() -> Mockable<Bool>
  static func setParentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func getParentStaticVariable() -> Mockable<Bool>
  static func setParentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func parentTrivialStaticMethod() -> Mockable<Void>
  static func parentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  // MARK: Grandparent
  func getGrandparentPrivateSetterInstanceVariable() -> Mockable<Bool>
  func setGrandparentPrivateSetterInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func getGrandparentInstanceVariable() -> Mockable<Bool>
  func setGrandparentInstanceVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  func grandparentTrivialInstanceMethod() -> Mockable<Void>
  func grandparentParameterizedInstanceMethod(param1: @escaping @autoclosure () -> Bool,
                                              _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
  
  static func getGrandparentPrivateSetterStaticVariable() -> Mockable<Bool>
  static func setGrandparentPrivateSetterStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func getGrandparentStaticVariable() -> Mockable<Bool>
  static func setGrandparentStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func grandparentTrivialStaticMethod() -> Mockable<Void>
  static func grandparentParameterizedStaticMethod(param1: @escaping @autoclosure () -> Bool,
                                                   _ param2: @escaping @autoclosure () -> Int)
    -> Mockable<Bool>
}
extension ChildProtocolMock: VerifiableChildProtocol {}
