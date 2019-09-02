//
//  ClassScopedTypesStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableTopLevelType {
  func topLevelMethod(param1: @escaping @autoclosure () -> TopLevelType.SecondLevelType,
                      param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType.ThirdLevelType)
    -> Stubbable<
    TopLevelType,
    TopLevelTypeMock,
    (TopLevelType.SecondLevelType, TopLevelType.SecondLevelType.ThirdLevelType) -> Bool,
    Bool>
}
extension TopLevelTypeMock: StubbableTopLevelType {}

private protocol StubbableSecondLevelType {
  func secondLevelMethod(param1: @escaping @autoclosure () -> TopLevelType,
                         param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType.ThirdLevelType)
    -> Stubbable<
    TopLevelType.SecondLevelType,
    TopLevelTypeMock.SecondLevelTypeMock,
    (TopLevelType, TopLevelType.SecondLevelType.ThirdLevelType) -> Bool,
    Bool>
}
extension TopLevelTypeMock.SecondLevelTypeMock: StubbableSecondLevelType {}

private protocol StubbableThirdLevelType {
  func thirdLevelMethod(param1: @escaping @autoclosure () -> TopLevelType,
                        param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType)
    -> Stubbable<
    TopLevelType.SecondLevelType.ThirdLevelType,
    TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelTypeMock,
    (TopLevelType, TopLevelType.SecondLevelType) -> Bool,
    Bool>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelTypeMock: StubbableThirdLevelType {}

private protocol StubbableThirdLevelInheritingTopLevelType: StubbableTopLevelType {
  func thirdLevelInheritingMethod()
    -> Stubbable<
    TopLevelType.SecondLevelType.ThirdLevelInheritingTopLevelType,
    TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingTopLevelTypeMock,
    () -> TopLevelType, TopLevelType>
}
// DRAGON: Swift doesn't understand contained types as generic parameters..
//extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingTopLevelTypeMock:
//StubbableThirdLevelInheritingTopLevelType {}

private protocol StubbableThirdLevelInheritingThirdLevelType: StubbableThirdLevelType {
  func thirdLevelInheritingMethod()
    -> Stubbable<
    TopLevelType.SecondLevelType.ThirdLevelInheritingThirdLevelType,
    TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingThirdLevelTypeMock,
    () -> TopLevelType.SecondLevelType.ThirdLevelType,
    TopLevelType.SecondLevelType.ThirdLevelType>
}
// DRAGON: Swift doesn't understand contained types as generic parameters..
//extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingThirdLevelTypeMock:
//StubbableThirdLevelInheritingThirdLevelType {}

private protocol StubbableThirdLevelInheritingPartiallyQualifiedThirdLevelType: StubbableThirdLevelType {
  func thirdLevelInheritingMethod()
    -> Stubbable<
    TopLevelType.SecondLevelType.ThirdLevelInheritingPartiallyQualifiedThirdLevelType,
    TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingPartiallyQualifiedThirdLevelTypeMock,
    () -> TopLevelType.SecondLevelType.ThirdLevelType,
    TopLevelType.SecondLevelType.ThirdLevelType>
}
// DRAGON: Swift doesn't understand contained types as generic parameters..
//extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingPartiallyQualifiedThirdLevelTypeMock:
//StubbableThirdLevelInheritingPartiallyQualifiedThirdLevelType {}

private protocol StubbableThirdLevelInheritingFullyQualifiedThirdLevelType: StubbableThirdLevelType {
  func thirdLevelInheritingMethod()
    -> Stubbable<
    TopLevelType.SecondLevelType.ThirdLevelInheritingFullyQualifiedThirdLevelType,
    TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingFullyQualifiedThirdLevelTypeMock,
    () -> TopLevelType.SecondLevelType.ThirdLevelType,
    TopLevelType.SecondLevelType.ThirdLevelType>
}
// DRAGON: Swift doesn't understand contained types as generic parameters..
//extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingFullyQualifiedThirdLevelTypeMock:
//StubbableThirdLevelInheritingFullyQualifiedThirdLevelType {}
