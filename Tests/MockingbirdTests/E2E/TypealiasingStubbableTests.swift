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
    -> Mockable<FunctionDeclaration, (TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<FunctionDeclaration, (@escaping TypealiasedProtocol.IndirectCallback) -> TypealiasedProtocol.IndirectRequestResult, TypealiasedProtocol.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedProtocol.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocol.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
  
  func method(object: @escaping @autoclosure () -> TypealiasedProtocolMock.NSObject)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocolMock.NSObject) -> Void, Void>
  func method(array: @escaping @autoclosure () -> TypealiasedProtocolMock.MyArray<String>)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocolMock.MyArray<String>) -> Void, Void>
  func method(dictionary: @escaping @autoclosure () -> TypealiasedProtocolMock.MyDictionary<String, Bool>)
    -> Mockable<FunctionDeclaration, (TypealiasedProtocolMock.MyDictionary<String, Bool>) -> Void, Void>
}
extension TypealiasedProtocolMock: StubbableTypealiasedProtocol {}

private protocol StubbableTypealiasedClass {
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(escapingCallback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<FunctionDeclaration, (@escaping TypealiasedClass.IndirectCallback) -> TypealiasedClass.IndirectRequestResult, TypealiasedClass.IndirectRequestResult>
  func request(callback: @escaping @autoclosure () -> TypealiasedClass.IndirectCallback)
    -> Mockable<FunctionDeclaration, (TypealiasedClass.IndirectCallback) -> Foundation.NSObject, Foundation.NSObject>
  
  func method(object: @escaping @autoclosure () -> TypealiasedClassMock.NSObject)
    -> Mockable<FunctionDeclaration, (TypealiasedClassMock.NSObject) -> Void, Void>
  func method(array: @escaping @autoclosure () -> TypealiasedClassMock.MyArray<String>)
    -> Mockable<FunctionDeclaration, (TypealiasedClassMock.MyArray<String>) -> Void, Void>
  func method(dictionary: @escaping @autoclosure () -> TypealiasedClassMock.MyDictionary<String, Bool>)
    -> Mockable<FunctionDeclaration, (TypealiasedClassMock.MyDictionary<String, Bool>) -> Void, Void>
}
extension TypealiasedClassMock: StubbableTypealiasedClass {}

private protocol StubbableModuleScopedTypealiasedProtocol {
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject)
    -> Mockable<FunctionDeclaration, (MockingbirdTestsHost.NSObject) -> MockingbirdTestsHost.NSObject, MockingbirdTestsHost.NSObject>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject)
    -> Mockable<FunctionDeclaration, (Foundation.NSObject) -> Foundation.NSObject, Foundation.NSObject>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> T, T> where
    T.Element == Foundation.NSObjectProtocol,
    T.Subelement == MockingbirdTestsHost.NSObject
  
  // MARK: Optional overloads
  func request(object: @escaping @autoclosure () -> MockingbirdTestsHost.NSObject?)
    -> Mockable<FunctionDeclaration, (MockingbirdTestsHost.NSObject?) -> MockingbirdTestsHost.NSObject?, MockingbirdTestsHost.NSObject?>
  func request(object: @escaping @autoclosure () -> Foundation.NSObject?)
    -> Mockable<FunctionDeclaration, (Foundation.NSObject?) -> Foundation.NSObject?, Foundation.NSObject?>
  func genericRequest<T: MockingbirdTestsHost.NSObjectProtocol>
    (object: @escaping @autoclosure () -> T?)
    -> Mockable<FunctionDeclaration, (T?) -> T?, T?> where
    T.Element == Foundation.NSObjectProtocol?,
    T.Subelement == MockingbirdTestsHost.NSObject?
}
extension ModuleScopedTypealiasedProtocolMock: StubbableModuleScopedTypealiasedProtocol {}
