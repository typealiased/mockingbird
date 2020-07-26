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

// Kept seperate from `MockableTypealiasedProtocol` due to ambiguous type alias scoping.
private protocol MockableTypealiasedClass: Mock {
  typealias Callback = (Bool, Int) -> Void
  typealias IndirectCallback = Callback
  typealias RequestResult = Bool
  typealias IndirectRequestResult = RequestResult
  typealias NSObject = IndirectRequestResult // Shadowing `Foundation.NSObject`
  typealias MyArray<T> = Array<T>
  typealias MyDictionary<K: Hashable, V> = Dictionary<K, V>
  
  func request(callback: IndirectCallback) -> IndirectRequestResult
  func request(escapingCallback: @escaping IndirectCallback) -> IndirectRequestResult
  func request(callback: IndirectCallback) -> Foundation.NSObject
  
  func method(object: NSObject)
  func method(array: MyArray<String>)
  func method(dictionary: MyDictionary<String, Bool>)
}
extension TypealiasedClassMock: MockableTypealiasedClass {}

private protocol MockableModuleScopedTypealiasedProtocol: ModuleScopedTypealiasedProtocol, Mock {}
extension ModuleScopedTypealiasedProtocolMock: MockableModuleScopedTypealiasedProtocol {}

private protocol MockableInheritingModuleScopedAssociatedTypeProtocol: MockingbirdTestsHost.ModuleScopedAssociatedTypeProtocol, Mock {}
extension InheritingModuleScopedAssociatedTypeProtocolMock: MockableInheritingModuleScopedAssociatedTypeProtocol {}
