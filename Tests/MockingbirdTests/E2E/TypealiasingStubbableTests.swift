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
  func request(callback: @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(escapingCallback: @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<FunctionDeclaration, (@escaping TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(callback: @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocol.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
  
  func method(object: @autoclosure () -> TypealiasedProtocolMock.NSObject)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocolMock.NSObject) -> Void, Void>
  func method(array: @autoclosure () -> TypealiasedProtocolMock.MyArray<String>)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocolMock.MyArray<String>) -> Void, Void>
  func method(dictionary: @autoclosure () -> TypealiasedProtocolMock.MyDictionary<String, Bool>)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocolMock.MyDictionary<String, Bool>) -> Void, Void>
}
extension TypealiasedProtocolMock: StubbableTypealiasedProtocol {}

private protocol StubbableTypealiasedClass {
  func request(callback: @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(escapingCallback: @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<FunctionDeclaration, (@escaping TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(callback: @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedClass.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
  
  func method(object: @autoclosure () -> TypealiasedClassMock.NSObject)
    -> Mockable<FunctionDeclaration, (TypealiasedClassMock.NSObject) -> Void, Void>
  func method(array: @autoclosure () -> TypealiasedClassMock.MyArray<String>)
    -> Mockable<FunctionDeclaration, (TypealiasedClassMock.MyArray<String>) -> Void, Void>
  func method(dictionary: @autoclosure () -> TypealiasedClassMock.MyDictionary<String, Bool>)
    -> Mockable<FunctionDeclaration, (TypealiasedClassMock.MyDictionary<String, Bool>) -> Void, Void>
}
extension TypealiasedClassMock: StubbableTypealiasedClass {}

private protocol StubbableModuleScopedTypealiasedProtocol {
  func request(object: @autoclosure () -> MockingbirdTestsHost.NSObject)
    -> Mockable<FunctionDeclaration, (MockingbirdTestsHost.NSObject) -> MockingbirdTestsHost.NSObject, MockingbirdTestsHost.NSObject>
  func request(object: @autoclosure () -> Foundation.NSObject)
    -> Mockable<FunctionDeclaration, (Foundation.NSObject) -> Foundation.NSObject, Foundation.NSObject>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> T, T> where
    T.Element == Foundation.NSObjectProtocol,
    T.Subelement == MockingbirdTestsHost.NSObject
  
  // MARK: Optional overloads
  func request(object: @autoclosure () -> MockingbirdTestsHost.NSObject?)
    -> Mockable<FunctionDeclaration, (MockingbirdTestsHost.NSObject?) -> MockingbirdTestsHost.NSObject?, MockingbirdTestsHost.NSObject?>
  func request(object: @autoclosure () -> Foundation.NSObject?)
    -> Mockable<FunctionDeclaration, (Foundation.NSObject?) -> Foundation.NSObject?, Foundation.NSObject?>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @autoclosure () -> T?)
    -> Mockable<FunctionDeclaration, (T?) -> T?, T?> where
    T.Element == Foundation.NSObjectProtocol?,
    T.Subelement == MockingbirdTestsHost.NSObject?
}
extension ModuleScopedTypealiasedProtocolMock: StubbableModuleScopedTypealiasedProtocol {}
