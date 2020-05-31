//
//  InitializersMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableInitializerOverridingSubclass: Mock {
  init()
  init(param: String?)
}
extension InitializerOverridingSubclassMock: MockableInitializerOverridingSubclass {}

private protocol MockableInitializerSubclass: Mock {
  init(param99: Bool)
  init(param: String?)
}
extension InitializerSubclassMock: MockableInitializerSubclass {}

// MARK: - Initializer proxy

private protocol InitializableInitializerOverridingSubclass {
  static func initialize(__file: StaticString, __line: UInt) -> InitializerOverridingSubclassMock
  static func initialize(`param`: String?, __file: StaticString, __line: UInt) -> InitializerOverridingSubclassMock
}
extension InitializerOverridingSubclassMock.InitializerProxy:
InitializableInitializerOverridingSubclass {}

private protocol InitializableInitializerSubclass {
  static func initialize(`param99`: Bool, __file: StaticString, __line: UInt) -> InitializerSubclassMock
  static func initialize(`param`: String?, __file: StaticString, __line: UInt) -> InitializerSubclassMock
}
extension InitializerSubclassMock.InitializerProxy: InitializableInitializerSubclass {}
