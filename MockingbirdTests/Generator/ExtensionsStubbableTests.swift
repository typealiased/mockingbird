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
  func trivialBaseMethod()
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, () -> Void, Void>
  func getBaseVariable()
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, () -> Bool, Bool>
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, (Bool) -> Void, Void>
  
  func trivialExtendedMethod()
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, () -> Void, Void>
  func parameterizedExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, (Bool) -> Void, Void>
  func parameterizedReturningExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, (Bool) -> Bool, Bool>
  func getExtendedVariable()
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, () -> Bool, Bool>
  func setExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, (Bool) -> Void, Void>
  
  func anotherTrivialExtendedMethod()
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, () -> Void, Void>
  func getAnotherExtendedVariable()
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, () -> Bool, Bool>
  func setAnotherExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<ExtendableProtocol, ExtendableProtocolMock, (Bool) -> Void, Void>
}
extension ExtendableProtocolMock: StubbableExtendableProtocol {}

private protocol StubbableNonExtendableClass {
  func trivialBaseMethod()
    -> Stubbable<NonExtendableClass, NonExtendableClassMock, () -> Void, Void>
  func getBaseVariable()
    -> Stubbable<NonExtendableClass, NonExtendableClassMock, () -> Bool, Bool>
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<NonExtendableClass, NonExtendableClassMock, (Bool) -> Void, Void>
}
extension NonExtendableClassMock: StubbableNonExtendableClass {}
