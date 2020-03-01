//
//  ExternalModuleTypesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import MockingbirdModuleTestsHost
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableLocalPublicExternalProtocol: PublicExternalProtocol {}
extension LocalPublicExternalProtocolMock: MockableLocalPublicExternalProtocol {}

private protocol MockableSubclassingExternalClassWithInheritedIntializer: ExternalClassWithInitializer {
  var internalVariable: Bool { get }
  func internalMethod()
}
extension SubclassingExternalClassWithInheritedIntializerMock: MockableSubclassingExternalClassWithInheritedIntializer {}

private protocol MockableSubclassingExternalSubclassWithInheritedInitializer: ExternalSubclassWithInitializer {
  var internalVariable: Bool { get }
  func internalMethod()
}
extension SubclassingExternalSubclassWithInheritedInitializerMock: MockableSubclassingExternalSubclassWithInheritedInitializer {}

private protocol MockableSubclassingExternalClassWithDesignatedIntializer: ExternalClassWithInitializer {
  var internalVariable: Bool { get }
  func internalMethod()
  init(param1: Bool)
}
extension SubclassingExternalClassWithDesignatedIntializerMock: MockableSubclassingExternalClassWithDesignatedIntializer {}

private protocol MockableSubclassingExternalSubclassWithDesignatedInitializer: ExternalSubclassWithInitializer {
  var internalVariable: Bool { get }
  func internalMethod()
  init(param1: Bool)
}
extension SubclassingExternalSubclassWithDesignatedInitializerMock: MockableSubclassingExternalSubclassWithDesignatedInitializer {}

private protocol MockableConformingExternalClassConstrainedProtocol:
ConformingExternalClassConstrainedProtocol {}
extension ConformingExternalClassConstrainedProtocolMock:
MockableConformingExternalClassConstrainedProtocol {}

private protocol MockableConformingInitializableOpenClassConstrainedProtocol:
ConformingInitializableOpenClassConstrainedProtocol {
  var openVariable: Bool { get set }
}
extension ConformingInitializableOpenClassConstrainedProtocolMock:
MockableConformingInitializableOpenClassConstrainedProtocol {}

private protocol MockableConformingUninitializableOpenClassConstrainedProtocol:
ConformingUninitializableOpenClassConstrainedProtocol {
  var openVariable: Bool { get set }
}
extension ConformingUninitializableOpenClassConstrainedProtocolMock:
MockableConformingUninitializableOpenClassConstrainedProtocol {}

private protocol MockableImplicitlyImportedExternalObjectiveCType:
ExternalObjectiveCProtocol {}
extension ImplicitlyImportedExternalObjectiveCTypeMock:
MockableImplicitlyImportedExternalObjectiveCType {}

// MARK: - Non-mockable declarations

class SubclassingExternalClass: ExternalClass {}
