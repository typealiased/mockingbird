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
    -> Mockable<MethodDeclaration, (TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<MethodDeclaration, (@escaping TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<MethodDeclaration, (TypealiasedProtocol.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
}
extension TypealiasedProtocolMock: StubbableTypealiasedProtocol {}

private protocol StubbableTypealiasedClass {
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<MethodDeclaration, (TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<MethodDeclaration, (@escaping TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<MethodDeclaration, (TypealiasedClass.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
}
extension TypealiasedClassMock: StubbableTypealiasedClass {}

private protocol StubbableModuleScopedTypealiasedProtocol {
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject)
    -> Mockable<MethodDeclaration, (MockingbirdTestsHost.NSObject) -> MockingbirdTestsHost.NSObject, MockingbirdTestsHost.NSObject>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject)
    -> Mockable<MethodDeclaration, (Foundation.NSObject) -> Foundation.NSObject, Foundation.NSObject>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T)
    -> Mockable<MethodDeclaration, (T) -> T, T> where
    T.Element == Foundation.NSObjectProtocol,
    T.Subelement == MockingbirdTestsHost.NSObject
  
  // MARK: Optional overloads
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject?)
    -> Mockable<MethodDeclaration, (MockingbirdTestsHost.NSObject?) -> MockingbirdTestsHost.NSObject?, MockingbirdTestsHost.NSObject?>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject?)
    -> Mockable<MethodDeclaration, (Foundation.NSObject?) -> Foundation.NSObject?, Foundation.NSObject?>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T?)
    -> Mockable<MethodDeclaration, (T?) -> T?, T?> where
    T.Element == Foundation.NSObjectProtocol?,
    T.Subelement == MockingbirdTestsHost.NSObject?
}
extension ModuleScopedTypealiasedProtocolMock: StubbableModuleScopedTypealiasedProtocol {}
