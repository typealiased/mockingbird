//
//  ExternalModuleClassScopedTypesStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import Mockingbird
import MockingbirdModuleTestsHost
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableSubclassingExternalTopLevelType {
  func getSecondLevelType()
    -> Mockable<VariableDeclaration,
    () -> MockingbirdModuleTestsHost.TopLevelType.SecondLevelType,
    MockingbirdModuleTestsHost.TopLevelType.SecondLevelType>
}
extension SubclassingExternalTopLevelTypeMock: StubbableSubclassingExternalTopLevelType {}

private protocol StubbableImplementingExternalModuleScoping {
  func getTopLevelType()
    -> Mockable<VariableDeclaration,
    () -> MockingbirdModuleTestsHost.TopLevelType,
    MockingbirdModuleTestsHost.TopLevelType>
  func getSecondLevelType()
    -> Mockable<VariableDeclaration,
    () -> MockingbirdModuleTestsHost.TopLevelType.SecondLevelType,
    MockingbirdModuleTestsHost.TopLevelType.SecondLevelType>
  func getThirdLevelType()
    -> Mockable<VariableDeclaration,
    () -> MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType,
    MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType>
}
extension ImplementingExternalModuleScopingMock: StubbableImplementingExternalModuleScoping {}
