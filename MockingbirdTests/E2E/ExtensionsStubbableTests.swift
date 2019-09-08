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
  func trivialBaseMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func getBaseVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func trivialExtendedMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func parameterizedExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Mockable<MethodDeclaration, (Bool) -> Void, Void>
  func parameterizedReturningExtendedMethod(param1: @escaping @autoclosure () -> Bool)
    -> Mockable<MethodDeclaration, (Bool) -> Bool, Bool>
  func getExtendedVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
  
  func anotherTrivialExtendedMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func getAnotherExtendedVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
}
extension ExtendableProtocolMock: StubbableExtendableProtocol {}

private protocol StubbableNonExtendableClass {
  func trivialBaseMethod() -> Mockable<MethodDeclaration, () -> Void, Void>
  func getBaseVariable() -> Mockable<VariableDeclaration, () -> Bool, Bool>
}
extension NonExtendableClassMock: StubbableNonExtendableClass {}

// MARK: - Non-stubbable declarations

extension ExtendableProtocolMock {
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  func setExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  func setAnotherExtendedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
}

extension NonExtendableClassMock {
  func setBaseVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
}
