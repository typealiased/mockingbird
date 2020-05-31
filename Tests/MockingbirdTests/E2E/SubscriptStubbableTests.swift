//
//  SubscriptStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/25/20.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableSubscriptedProtocol {
  func getSubscript(_ index: @escaping @autoclosure () -> Int)
    -> Mockable<SubscriptGetterDeclaration, (Int) -> String, String>
  func setSubscript(_ index: @escaping @autoclosure () -> Int,
                    newValue: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptSetterDeclaration, (Int, String) -> Void, Void>
  
  func getSubscript(_ index: @escaping @autoclosure () -> Int)
    -> Mockable<SubscriptGetterDeclaration, (Int) -> Bool, Bool>
  func setSubscript(_ index: @escaping @autoclosure () -> Int,
                    newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<SubscriptSetterDeclaration, (Int, Bool) -> Void, Void>
  
  func getSubscript(_ index: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptGetterDeclaration, (String) -> String, String>
  func setSubscript(_ index: @escaping @autoclosure () -> String,
                    newValue: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptSetterDeclaration, (String, String) -> Void, Void>
  
  func getSubscript(_ index: @escaping @autoclosure () -> Int)
    -> Mockable<SubscriptGetterDeclaration, (Int) -> Int, Int>
  func setSubscript(_ index: @escaping @autoclosure () -> Int,
                    newValue: @escaping @autoclosure () -> Int)
    -> Mockable<SubscriptSetterDeclaration, (Int, Int) -> Void, Void>
  
  func getSubscript(_ row: @escaping @autoclosure () -> Int,
                    _ column: @escaping @autoclosure () -> Int)
    -> Mockable<SubscriptGetterDeclaration, (Int, Int) -> String, String>
  func setSubscript(_ row: @escaping @autoclosure () -> Int,
                    _ column: @escaping @autoclosure () -> Int,
                    newValue: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptSetterDeclaration, (Int, Int, String) -> Void, Void>
  
  func getSubscript(_ indexes: @escaping @autoclosure () -> [String])
    -> Mockable<SubscriptGetterDeclaration, ([String]) -> String, String>
  func setSubscript(_ indexes: @escaping @autoclosure () -> [String],
                    newValue: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptSetterDeclaration, ([String], String) -> Void, Void>
  func getSubscript(_ indexes: String...)
    -> Mockable<SubscriptGetterDeclaration, ([String]) -> String, String>
  func setSubscript(_ indexes: String..., newValue: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptSetterDeclaration, ([String], String) -> Void, Void>
  
  func getSubscript<IndexType: Equatable, ReturnType: Hashable>(
    _ index: @escaping @autoclosure () -> IndexType
  ) -> Mockable<SubscriptGetterDeclaration, (IndexType) -> ReturnType, ReturnType>
  func setSubscript<IndexType: Equatable, ReturnType: Hashable>(
    _ index: @escaping @autoclosure () -> IndexType,
    newValue: @escaping @autoclosure () -> ReturnType
  ) -> Mockable<SubscriptSetterDeclaration, (IndexType, ReturnType) -> Void, Void>
}
extension SubscriptedProtocolMock: StubbableSubscriptedProtocol {}
extension SubscriptedClassMock: StubbableSubscriptedProtocol {}

private protocol StubbableDynamicMemberLookupClass {
  func getSubscript(dynamicMember member: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptGetterDeclaration, (String) -> Int, Int>
  func setSubscript(dynamicMember member: @escaping @autoclosure () -> String,
                    newValue: @escaping @autoclosure () -> Int)
    -> Mockable<SubscriptSetterDeclaration, (String, Int) -> Void, Void>
}
extension DynamicMemberLookupClassMock: StubbableDynamicMemberLookupClass {}

private protocol StubbableGenericDynamicMemberLookupClass {
  func getSubscript<T>(dynamicMember member: @escaping @autoclosure () -> String)
    -> Mockable<SubscriptGetterDeclaration, (String) -> T, T>
  func setSubscript<T>(dynamicMember member: @escaping @autoclosure () -> String,
                       newValue: @escaping @autoclosure () -> T)
    -> Mockable<SubscriptSetterDeclaration, (String, T) -> Void, Void>
}
extension GenericDynamicMemberLookupClassMock: StubbableGenericDynamicMemberLookupClass {}
