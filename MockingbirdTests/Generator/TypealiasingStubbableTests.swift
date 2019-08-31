//
//  TypealiasingStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/31/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableTypealiasedProtocol {
  func request(callback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Stubbable<
    TypealiasedProtocol,
    TypealiasedProtocolMock,
    (TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult,
    TypealiasedProtocol.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Stubbable<
    TypealiasedProtocol,
    TypealiasedProtocolMock,
    (@escaping TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult,
    TypealiasedProtocol.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Stubbable<
    TypealiasedProtocol,
    TypealiasedProtocolMock,
    (TypealiasedProtocol.IndirectCallback) -> Foundation.NSObject,
    Foundation.NSObject>
}
extension TypealiasedProtocolMock: StubbableTypealiasedProtocol {}

private protocol StubbableTypealiasedClass {
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Stubbable<
    TypealiasedClass,
    TypealiasedClassMock,
    (TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult,
    TypealiasedClass.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Stubbable<
    TypealiasedClass,
    TypealiasedClassMock,
    (@escaping TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult,
    TypealiasedClass.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Stubbable<
    TypealiasedClass,
    TypealiasedClassMock,
    (TypealiasedClass.IndirectCallback) -> Foundation.NSObject,
    Foundation.NSObject>
}
extension TypealiasedClassMock: StubbableTypealiasedClass {}

private protocol StubbableModuleScopedTypealiasedProtocol {
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject)
    -> Stubbable<
    ModuleScopedTypealiasedProtocol,
    ModuleScopedTypealiasedProtocolMock,
    (MockingbirdTestsHost.NSObject) -> MockingbirdTestsHost.NSObject,
    MockingbirdTestsHost.NSObject>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject)
    -> Stubbable<
    ModuleScopedTypealiasedProtocol,
    ModuleScopedTypealiasedProtocolMock,
    (Foundation.NSObject) -> Foundation.NSObject,
    Foundation.NSObject>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T)
    -> Stubbable<
    ModuleScopedTypealiasedProtocol,
    ModuleScopedTypealiasedProtocolMock,
    (T) -> T,
    T> where
    T.Element == Foundation.NSObjectProtocol,
    T.Subelement == MockingbirdTestsHost.NSObject
  
  // MARK: Optional overloads
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject?)
    -> Stubbable<
    ModuleScopedTypealiasedProtocol,
    ModuleScopedTypealiasedProtocolMock,
    (MockingbirdTestsHost.NSObject?) -> MockingbirdTestsHost.NSObject?,
    MockingbirdTestsHost.NSObject?>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject?)
    -> Stubbable<
    ModuleScopedTypealiasedProtocol,
    ModuleScopedTypealiasedProtocolMock,
    (Foundation.NSObject?) -> Foundation.NSObject?,
    Foundation.NSObject?>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T?)
    -> Stubbable<
    ModuleScopedTypealiasedProtocol,
    ModuleScopedTypealiasedProtocolMock,
    (T?) -> T?,
    T?> where
    T.Element == Foundation.NSObjectProtocol?,
    T.Subelement == MockingbirdTestsHost.NSObject?
}
extension ModuleScopedTypealiasedProtocolMock: StubbableModuleScopedTypealiasedProtocol {}
