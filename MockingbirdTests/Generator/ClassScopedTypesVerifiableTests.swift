//
//  ClassScopedTypesVerifiableTests.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableTopLevelType {
  func topLevelMethod(param1: @escaping @autoclosure () -> TopLevelType.SecondLevelType,
                      param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType.ThirdLevelType)
    -> Mockable<Bool>
}
extension TopLevelTypeMock: VerifiableTopLevelType {}

private protocol VerifiableSecondLevelType {
  func secondLevelMethod(param1: @escaping @autoclosure () -> TopLevelType,
                         param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType.ThirdLevelType)
    -> Mockable<Bool>
}
extension TopLevelTypeMock.SecondLevelTypeMock: VerifiableSecondLevelType {}

private protocol VerifiableThirdLevelType {
  func thirdLevelMethod(param1: @escaping @autoclosure () -> TopLevelType,
                        param2: @escaping @autoclosure () -> TopLevelType.SecondLevelType)
    -> Mockable<Bool>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelTypeMock: VerifiableThirdLevelType {}

private protocol VerifiableThirdLevelInheritingTopLevelType: VerifiableTopLevelType {
  func thirdLevelInheritingMethod() -> Mockable<TopLevelType>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingTopLevelTypeMock:
VerifiableThirdLevelInheritingTopLevelType {}

private protocol VerifiableThirdLevelInheritingThirdLevelType: VerifiableThirdLevelType {
  func thirdLevelInheritingMethod() -> Mockable<TopLevelType.SecondLevelType.ThirdLevelType>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingThirdLevelTypeMock:
VerifiableThirdLevelInheritingThirdLevelType {}

private protocol VerifiableThirdLevelInheritingPartiallyQualifiedThirdLevelType: VerifiableThirdLevelType {
  func thirdLevelInheritingMethod() -> Mockable<TopLevelType.SecondLevelType.ThirdLevelType>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingPartiallyQualifiedThirdLevelTypeMock:
VerifiableThirdLevelInheritingPartiallyQualifiedThirdLevelType {}

private protocol VerifiableThirdLevelInheritingFullyQualifiedThirdLevelType: VerifiableThirdLevelType {
  func thirdLevelInheritingMethod() -> Mockable<TopLevelType.SecondLevelType.ThirdLevelType>
}
extension TopLevelTypeMock.SecondLevelTypeMock.ThirdLevelInheritingFullyQualifiedThirdLevelTypeMock:
VerifiableThirdLevelInheritingFullyQualifiedThirdLevelType {}
