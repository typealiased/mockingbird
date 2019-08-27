//
//  StaticsVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableStaticsContainerProtocol {
  static func getStaticVariable() -> Mockable<Bool>
  static func setStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  static func getStaticReadOnlyVariable() -> Mockable<Bool>
  static func setStaticReadOnlyVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
  
  static func staticMethod() -> Mockable<Bool>
}
extension StaticsContainerProtocolMock: VerifiableStaticsContainerProtocol {}

private protocol VerifiableStaticsContainerClass {
  static func getClassComputedVariable() -> Mockable<Bool>
  static func setClassComputedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<Void>
}
extension StaticsContainerClassMock: VerifiableStaticsContainerClass {}
