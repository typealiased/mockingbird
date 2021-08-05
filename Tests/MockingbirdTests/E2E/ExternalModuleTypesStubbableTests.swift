//
//  ExternalModuleTypesStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import Mockingbird
import MockingbirdModuleTestsHost
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableLocalPublicExternalProtocol {
  func getVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func method() -> Mockable<FunctionDeclaration, () -> Void, Void>
}
extension LocalPublicExternalProtocolMock: StubbableLocalPublicExternalProtocol {}

private protocol StubbableSubclassingExternalClassWithInheritedIntializer {
  func getInternalVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func internalMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
  func getOpenVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func openMethod() -> Mockable<FunctionDeclaration, () -> Void, Void>
}
extension SubclassingExternalClassWithInheritedIntializerMock:
StubbableSubclassingExternalClassWithInheritedIntializer {}
extension SubclassingExternalSubclassWithInheritedInitializerMock:
StubbableSubclassingExternalClassWithInheritedIntializer {}
extension SubclassingExternalClassWithDesignatedIntializerMock:
StubbableSubclassingExternalClassWithInheritedIntializer {}
extension SubclassingExternalSubclassWithDesignatedInitializerMock:
StubbableSubclassingExternalClassWithInheritedIntializer {}

private protocol StubbableConformingInitializableOpenClassConstrainedProtocol {
  func getOpenVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setOpenVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
}
extension ConformingInitializableOpenClassConstrainedProtocolMock:
StubbableConformingInitializableOpenClassConstrainedProtocol {}

private protocol StubbableConformingUninitializableOpenClassConstrainedProtocol {
  func getOpenVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setOpenVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
}
extension ConformingUninitializableOpenClassConstrainedProtocolMock:
StubbableConformingUninitializableOpenClassConstrainedProtocol {}

private protocol StubbableImplicitlyImportedExternalObjectiveCType {
  func getVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
}
extension ImplicitlyImportedExternalObjectiveCTypeMock:
StubbableImplicitlyImportedExternalObjectiveCType {}


// MARK: - Non-stubbable declarations

extension ConformingInitializableOpenClassConstrainedProtocolMock {
  func getPublicVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  func setPublicVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
}

extension ConformingUninitializableOpenClassConstrainedProtocolMock {
  func getPublicVariable() -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  func setPublicVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
}
