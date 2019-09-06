//
//  ExtensionsStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableExtendableProtocol {
  func trivialBaseMethod() -> Stubbable<() -> Void, Void>
  func getBaseVariable() -> Stubbable<() -> Bool, Bool>
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func trivialExtendedMethod() -> Stubbable<() -> Void, Void>
  func parameterizedExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  func parameterizedReturningExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Bool, Bool>
  func getExtendedVariable() -> Stubbable<() -> Bool, Bool>
  func setExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  func anotherTrivialExtendedMethod() -> Stubbable<() -> Void, Void>
  func getAnotherExtendedVariable() -> Stubbable<() -> Bool, Bool>
  func setAnotherExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
}
extension ExtendableProtocolMock: StubbableExtendableProtocol {}

private protocol StubbableNonExtendableClass {
  func trivialBaseMethod() -> Stubbable<() -> Void, Void>
  func getBaseVariable() -> Stubbable<() -> Bool, Bool>
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
}
extension NonExtendableClassMock: StubbableNonExtendableClass {}
