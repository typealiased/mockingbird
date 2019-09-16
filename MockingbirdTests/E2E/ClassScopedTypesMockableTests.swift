//
//  ClassScopedTypesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableTopLevelType: Mock {
  func topLevelMethod(param1: TopLevelType.SecondLevelType,
                      param2: TopLevelType.SecondLevelType.ThirdLevelType) -> Bool
}
extension TopLevelTypeMock: MockableTopLevelType {}

private protocol MockableSecondLevelType: Mock {
  func secondLevelMethod(param1: TopLevelType,
                         param2: TopLevelType.SecondLevelType.ThirdLevelType) -> Bool
}
extension TopLevelTypeMock.SecondLevelTypeMock: MockableSecondLevelType {}

private protocol MockableThirdLevelType: Mock {
  func thirdLevelMethod(param1: TopLevelType,
                        param2: TopLevelType.SecondLevelType) -> Bool
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelTypeMock: MockableThirdLevelType {}

private protocol MockableThirdLevelInheritingTopLevelType: MockableTopLevelType {
  func thirdLevelInheritingMethod() -> TopLevelType
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingTopLevelTypeMock:
MockableThirdLevelInheritingTopLevelType {}

private protocol MockableThirdLevelInheritingThirdLevelType: MockableThirdLevelType {
  func thirdLevelInheritingMethod() -> TopLevelType.SecondLevelType.ThirdLevelType
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingThirdLevelTypeMock:
MockableThirdLevelInheritingThirdLevelType {}

private protocol MockableThirdLevelInheritingPartiallyQualifiedThirdLevelType: MockableThirdLevelType {
  func thirdLevelInheritingMethod() -> TopLevelType.SecondLevelType.ThirdLevelType
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingPartiallyQualifiedThirdLevelTypeMock:
MockableThirdLevelInheritingPartiallyQualifiedThirdLevelType {}

private protocol MockableThirdLevelInheritingFullyQualifiedThirdLevelType: MockableThirdLevelType {
  func thirdLevelInheritingMethod() -> TopLevelType.SecondLevelType.ThirdLevelType
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingFullyQualifiedThirdLevelTypeMock:
MockableThirdLevelInheritingFullyQualifiedThirdLevelType {}
