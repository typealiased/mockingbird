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

// NOTE: Unable to test explicit and unavailable initializer variants due to generics.

private protocol InitializableInitializerOverridingSubclass: Initializable {
  func initialize(__file: StaticString, __line: UInt) -> InitializerOverridingSubclassAbstractMockType

//  func initialize<__ReturnType: Mock>(__file: StaticString, __line: UInt) -> __ReturnType
//  func initialize<__ReturnType>(__file: StaticString, __line: UInt) -> __ReturnType

  func initialize(`param`: String?, __file: StaticString, __line: UInt) -> InitializerOverridingSubclassAbstractMockType

//  func initialize<__ReturnType: Mock>(`param`: String?, __file: StaticString, __line: UInt) -> __ReturnType
//  func initialize<__ReturnType>(`param`: String?, __file: StaticString, __line: UInt) -> __ReturnType
}
extension InitializerOverridingSubclassMock.InitializerProxy:
InitializableInitializerOverridingSubclass {}

private protocol InitializableInitializerSubclass: Initializable {
  func initialize(`param99`: Bool, __file: StaticString, __line: UInt) -> InitializerSubclassAbstractMockType

//  func initialize<__ReturnType: Mock>(`param99`: Bool, __file: StaticString, __line: UInt) -> __ReturnType
//  func initialize<__ReturnType>(`param99`: Bool, __file: StaticString, __line: UInt) -> __ReturnType

  func initialize(`param`: String?, __file: StaticString, __line: UInt) -> InitializerSubclassAbstractMockType

//  func initialize<__ReturnType: Mock>(`param`: String?, __file: StaticString, __line: UInt) -> __ReturnType
//  func initialize<__ReturnType>(`param`: String?, __file: StaticString, __line: UInt) -> __ReturnType
}
extension InitializerSubclassMock.InitializerProxy: InitializableInitializerSubclass {}

private protocol DummyInitializableInitializerOverridingSubclass: Initializable {
    func initialize(__file: StaticString, __line: UInt)
      -> InitializerOverridingSubclassMock
    func initialize(param: String?, __file: StaticString, __line: UInt)
      -> InitializerOverridingSubclassMock
}
extension InitializerOverridingSubclassMock.InitializerProxy.Dummy:
DummyInitializableInitializerOverridingSubclass {}

private protocol DummyInitializableInitializerSubclass: Initializable {
  func initialize(param99: Bool, __file: StaticString, __line: UInt)
    -> InitializerSubclassMock
  func initialize(param: String?, __file: StaticString, __line: UInt)
    -> InitializerSubclassMock
}
extension InitializerSubclassMock.InitializerProxy.Dummy: DummyInitializableInitializerSubclass {}
