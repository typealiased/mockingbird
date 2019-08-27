//
//  StaticsMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation
import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableStaticsContainerProtocol {
  static var staticVariable: Bool { get set }
  static var staticReadOnlyVariable: Bool { get }
  
  static func staticMethod() -> Bool
}
extension StaticsContainerProtocolMock: MockableStaticsContainerProtocol {}

private protocol MockableStaticsContainerClass {
  static var classComputedVariable: Bool { get }
}
extension StaticsContainerClassMock: MockableStaticsContainerClass {}

// MARK: - Non-mockable declarations

private extension StaticsContainerClassMock {
  static var staticStoredVariableWithImplicitType = true
  static var staticStoredVariableWithExplicitType: Bool = true
  static var staticComputedVariable: Bool { return true }
}
