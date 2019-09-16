//
//  TypealiasingMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/31/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableTypealiasedProtocol: TypealiasedProtocol {}
extension TypealiasedProtocolMock: MockableTypealiasedProtocol {}

private protocol MockableTypealiasedClass: Mock {
  typealias Callback = (Bool, Int) -> Void
  typealias IndirectCallback = Callback
  typealias RequestResult = Bool
  typealias IndirectRequestResult = RequestResult
  typealias NSObject = IndirectRequestResult // Shadowing `Foundation.NSObject`
  func request(callback: IndirectCallback) -> IndirectRequestResult
  func request(escapingCallback: @escaping IndirectCallback) -> IndirectRequestResult
  func request(callback: IndirectCallback) -> Foundation.NSObject
}
extension TypealiasedClassMock: MockableTypealiasedClass {}

private protocol MockableModuleScopedTypealiasedProtocol: ModuleScopedTypealiasedProtocol, Mock {}
extension ModuleScopedTypealiasedProtocolMock: MockableModuleScopedTypealiasedProtocol {}

private protocol MockableInheritingModuleScopedAssociatedTypeProtocol: ModuleScopedAssociatedTypeProtocol, Mock {}
extension InheritingModuleScopedAssociatedTypeProtocolMock: MockableInheritingModuleScopedAssociatedTypeProtocol {}
