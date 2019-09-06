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
    -> Stubbable<(TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Stubbable<(@escaping TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Stubbable<(TypealiasedProtocol.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
}
extension TypealiasedProtocolMock: StubbableTypealiasedProtocol {}

private protocol StubbableTypealiasedClass {
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Stubbable<(TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Stubbable<(@escaping TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Stubbable<(TypealiasedClass.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
}
extension TypealiasedClassMock: StubbableTypealiasedClass {}

private protocol StubbableModuleScopedTypealiasedProtocol {
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject)
    -> Stubbable<(MockingbirdTestsHost.NSObject) -> MockingbirdTestsHost.NSObject, MockingbirdTestsHost.NSObject>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject)
    -> Stubbable<(Foundation.NSObject) -> Foundation.NSObject, Foundation.NSObject>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T)
    -> Stubbable<(T) -> T, T> where
    T.Element == Foundation.NSObjectProtocol,
    T.Subelement == MockingbirdTestsHost.NSObject
  
  // MARK: Optional overloads
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject?)
    -> Stubbable<(MockingbirdTestsHost.NSObject?) -> MockingbirdTestsHost.NSObject?, MockingbirdTestsHost.NSObject?>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject?)
    -> Stubbable<(Foundation.NSObject?) -> Foundation.NSObject?, Foundation.NSObject?>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T?)
    -> Stubbable<(T?) -> T?, T?> where
    T.Element == Foundation.NSObjectProtocol?,
    T.Subelement == MockingbirdTestsHost.NSObject?
}
extension ModuleScopedTypealiasedProtocolMock: StubbableModuleScopedTypealiasedProtocol {}
