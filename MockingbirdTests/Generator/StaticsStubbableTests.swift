//
//  StaticsStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableStaticsContainerProtocol {
  static func getStaticVariable() -> Stubbable<() -> Bool, Bool>
  static func setStaticVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  static func getStaticReadOnlyVariable() -> Stubbable<() -> Bool, Bool>
  static func setStaticReadOnlyVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
  
  static func staticMethod() -> Stubbable<() -> Bool, Bool>
}
extension StaticsContainerProtocolMock: StubbableStaticsContainerProtocol {}

private protocol StubbableStaticsContainerClass {
  static func getClassComputedVariable() -> Stubbable<() -> Bool, Bool>
  static func setClassComputedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Stubbable<(Bool) -> Void, Void>
}
extension StaticsContainerClassMock: StubbableStaticsContainerClass {}
