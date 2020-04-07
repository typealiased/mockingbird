//
//  ExternalModuleClassScopedTypesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import Mockingbird
import MockingbirdModuleTestsHost
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableSubclassingExternalTopLevelType: MockingbirdModuleTestsHost.TopLevelType, Mock {
  var secondLevelType: SecondLevelType { get }
  init()
}
extension SubclassingExternalTopLevelTypeMock: MockableSubclassingExternalTopLevelType {}

private protocol MockableImplementingExternalModuleScoping: ExternalModuleScoping, Mock {
  var topLevelType: MockingbirdModuleTestsHost.TopLevelType { get }
  var secondLevelType: MockingbirdModuleTestsHost.TopLevelType.SecondLevelType { get }
  var thirdLevelType: MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType { get }
}
extension ImplementingExternalModuleScopingMock: MockableImplementingExternalModuleScoping {}

// MARK: - Initializer proxy

private protocol InitializableSubclassingExternalTopLevelType: Initializable {
  func initialize(__file: StaticString, __line: UInt)
    -> SubclassingExternalTopLevelTypeAbstractMockType
}
extension SubclassingExternalTopLevelTypeMock.InitializerProxy:
InitializableSubclassingExternalTopLevelType {}

private protocol InitializableImplementingExternalModuleScoping: Initializable {
  func initialize(__file: StaticString, __line: UInt)
    -> ImplementingExternalModuleScopingAbstractMockType
}
extension ImplementingExternalModuleScopingMock.InitializerProxy:
InitializableImplementingExternalModuleScoping {}

private protocol DummyInitializableSubclassingExternalTopLevelType: Initializable {
  func initialize(__file: StaticString, __line: UInt) -> SubclassingExternalTopLevelTypeMock
}
extension SubclassingExternalTopLevelTypeMock.InitializerProxy.Dummy:
DummyInitializableSubclassingExternalTopLevelType {}

private protocol DummyInitializableImplementingExternalModuleScoping: Initializable {
  func initialize(__file: StaticString, __line: UInt)
    -> ImplementingExternalModuleScopingMock
}
extension ImplementingExternalModuleScopingMock.InitializerProxy.Dummy:
DummyInitializableImplementingExternalModuleScoping {}

