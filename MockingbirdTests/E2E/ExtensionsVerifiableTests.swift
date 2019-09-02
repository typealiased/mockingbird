//
//  ExtensionsVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableExtendableProtocol {
  func trivialBaseMethod() -> Mockable<Void>
  func getBaseVariable() -> Mockable<Bool>
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool) -> Mockable<Void>
  
  func trivialExtendedMethod() -> Mockable<Void>
  func parameterizedExtendedMethod(param1: @escaping @autoclosure () -> Bool) -> Mockable<Void>
  func parameterizedReturningExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Mockable<Bool>
  func getExtendedVariable() -> Mockable<Bool>
  func setExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool) -> Mockable<Void>
  
  func anotherTrivialExtendedMethod() -> Mockable< Void>
  func getAnotherExtendedVariable() -> Mockable<Bool>
  func setAnotherExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool) -> Mockable<Void>
}
extension ExtendableProtocolMock: VerifiableExtendableProtocol {}

private protocol VerifiableNonExtendableClass {
  func trivialBaseMethod() -> Mockable<Void>
  func getBaseVariable() -> Mockable<Bool>
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool) -> Mockable<Void>
}
extension NonExtendableClassMock: VerifiableNonExtendableClass {}
