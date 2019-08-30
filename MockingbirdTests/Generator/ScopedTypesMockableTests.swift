//
//  ScopedTypesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableTopLevelType {
  func topLevelMethod(param1: TopLevelType.SecondLevelType,
                      param2: TopLevelType.SecondLevelType.ThirdLevelType) -> Bool
}
extension TopLevelTypeMock: MockableTopLevelType {}

private protocol MockableSecondLevelType {
  func secondLevelMethod(param1: TopLevelType,
                         param2: TopLevelType.SecondLevelType.ThirdLevelType) -> Bool
}
extension TopLevelTypeMock.SecondLevelTypeMock: MockableSecondLevelType {}

private protocol MockableThirdLevelType {
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
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingPartiallyQualifiedThirdLevelType:
MockableThirdLevelInheritingPartiallyQualifiedThirdLevelType {}

private protocol MockableThirdLevelInheritingFullyQualifiedThirdLevelType: MockableThirdLevelType {
  func thirdLevelInheritingMethod() -> TopLevelType.SecondLevelType.ThirdLevelType
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingFullyQualifiedThirdLevelType:
MockableThirdLevelInheritingFullyQualifiedThirdLevelType {}
