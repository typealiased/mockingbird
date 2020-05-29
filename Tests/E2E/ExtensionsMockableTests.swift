//
//  ExtensionsMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableExtendableProtocol: Mock {
  func trivialBaseMethod()
  var baseVariable: Bool { get }
  
  func trivialExtendedMethod()
  func parameterizedExtendedMethod(param1: Bool)
  func parameterizedReturningExtendedMethod(param1: Bool) -> Bool
  var extendedVariable: Bool { get }
  
  func anotherTrivialExtendedMethod()
  var anotherExtendedVariable: Bool { get }
}
extension ExtendableProtocolMock: MockableExtendableProtocol {}

private protocol MockableInheritsExtendableProtocol: MockableExtendableProtocol {
  func trivialChildMethod()
  var childVariable: Bool { get }
}
extension InheritsExtendableProtocolMock: MockableInheritsExtendableProtocol {}

private protocol MockableNonExtendableClass: Mock {
  func trivialBaseMethod()
  var baseVariable: Bool { get }
}
extension NonExtendableClassMock: MockableNonExtendableClass {}

// MARK: - Non-mockable declarations

private extension NonExtendableClassMock {
  func trivialExtendedMethod() {}
  func parameterizedExtendedMethod(param1: Bool) {}
  func parameterizedReturningExtendedMethod(param1: Bool) -> Bool { return true }
  var extendedVariable: Bool { return true }
  
  // MARK: Encodable
  func encode(to encoder: Encoder) throws {}
}
