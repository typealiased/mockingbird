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
  func trivialBaseMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func getBaseVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
}
extension ExtendableProtocolMock: StubbableExtendableProtocol {}

private protocol StubbableInheritsExtendableProtocol: StubbableExtendableProtocol {
  func trivialChildMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func getChildVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
}
extension InheritsExtendableProtocolMock: StubbableInheritsExtendableProtocol {}

private protocol StubbableNonExtendableClass {
  func trivialBaseMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func getBaseVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
}
extension NonExtendableClassMock: StubbableNonExtendableClass {}

// MARK: - Non-stubbable declarations

extension ExtendableProtocolMock {
  func trivialExtendedMethod() -> Mockable<FunctionDeclaration, () -> Void, Void> { fatalError() }
  func parameterizedExtendedMethod(param1: @autoclosure () -> Bool)
  -> Mockable<FunctionDeclaration, (Bool) -> Void, Void> { fatalError() }
  func parameterizedReturningExtendedMethod(param1: @autoclosure () -> Bool)
  -> Mockable<FunctionDeclaration, (Bool) -> Bool, Bool> { fatalError() }
  
  func getExtendedVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  func setExtendedVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
  
  func anotherTrivialExtendedMethod() -> Mockable<FunctionDeclaration, () -> Void, Void> { fatalError() }

  func getAnotherExtendedVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  func setAnotherExtendedVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
}

extension NonExtendableClassMock {
  func trivialExtendedMethod() -> Mockable<FunctionDeclaration, () -> Void, Void> { fatalError() }
  func parameterizedExtendedMethod(param1: @autoclosure () -> Bool)
  -> Mockable<FunctionDeclaration, (Bool) -> Void, Void> { fatalError() }
  func parameterizedReturningExtendedMethod(param1: @autoclosure () -> Bool)
  -> Mockable<FunctionDeclaration, (Bool) -> Bool, Bool> { fatalError() }

  func getExtendedVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  func setExtendedVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }

  func encode(to encoder: @autoclosure () -> Encoder) -> Mockable<FunctionDeclaration, (Encoder) throws -> Void, Void> { fatalError() }
}
