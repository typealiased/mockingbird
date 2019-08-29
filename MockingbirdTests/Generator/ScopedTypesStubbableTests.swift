//
//  ScopedTypesStubbableTests.swift
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
    -> Stubbable<TopLevelType, TopLevelTypeMock, (TopLevelType.SecondLevelType, TopLevelType.SecondLevelType.ThirdLevelType) -> Bool, Bool>
}
extension TopLevelTypeMock: StubbableTopLevelType {}

private protocol StubbableSecondLevelType {
  func secondLevelMethod(param1: @escaping @autoclosure () -> TopLevelType,
                         param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType.ThirdLevelType)
    -> Stubbable<TopLevelType.SecondLevelType, TopLevelTypeMock.SecondLevelTypeMock, (TopLevelType, TopLevelType.SecondLevelType.ThirdLevelType) -> Bool, Bool>
}
extension TopLevelTypeMock.SecondLevelTypeMock: StubbableSecondLevelType {}

private protocol StubbableThirdLevelType {
  func thirdLevelMethod(param1: @escaping @autoclosure () -> TopLevelType,
                        param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType)
    -> Stubbable<TopLevelType.SecondLevelType.ThirdLevelType, TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelTypeMock, (TopLevelType, TopLevelType.SecondLevelType) -> Bool, Bool>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelTypeMock: StubbableThirdLevelType {}

private protocol StubbableThirdLevelInheritingTopLevelType: StubbableTopLevelType {
  func thirdLevelInheritingMethod()
    -> Stubbable<TopLevelType.SecondLevelType.ThirdLevelInheritingTopLevelType, TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingTopLevelTypeMock, () -> Bool, Bool>
}
// DRAGON: Swift doesn't understand contained types as generic parameters..
//extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingTopLevelTypeMock:
//StubbableThirdLevelInheritingTopLevelType {}

private protocol StubbableThirdLevelInheritingThirdLevelType: StubbableThirdLevelType {
  func thirdLevelInheritingMethod()
    -> Stubbable<TopLevelType.SecondLevelType.ThirdLevelInheritingThirdLevelType, TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingThirdLevelTypeMock, () -> Bool, Bool>
}
// DRAGON: Swift doesn't understand contained types as generic parameters..
//extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingThirdLevelTypeMock:
//StubbableThirdLevelInheritingThirdLevelType {}
