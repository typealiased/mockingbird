//
//  ImplicitVariableTypesStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 5/4/20.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

private protocol StubbableImplicitVariableTypes {
  func getBoolType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setBoolType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>

  func getDictionaryArrayType()
    -> Mockable<VariableDeclaration, ()
    -> [String: [Bool]], [String: [Bool]]>
  func setDictionaryArrayType(_ newValue: @escaping @autoclosure () -> [String: [Bool]])
    -> Mockable<VariableDeclaration, ([String: [Bool]]) -> Void, Void>

  func getDictionaryDictionaryType()
    -> Mockable<VariableDeclaration, () -> [String: [String: Bool]], [String: [String: Bool]]>
  func setDictionaryDictionaryType(_ newValue: @escaping @autoclosure () -> [String: [String: Bool]])
    -> Mockable<VariableDeclaration, ([String: [String: Bool]]) -> Void, Void>

  func getDictionaryType()
    -> Mockable<VariableDeclaration, () -> [String: Bool], [String: Bool]>
  func setDictionaryType(_ newValue: @escaping @autoclosure () -> [String: Bool])
    -> Mockable<VariableDeclaration, ([String: Bool]) -> Void, Void>

  func getDoubleType()
    -> Mockable<VariableDeclaration, () -> Double, Double>
  func setDoubleType(_ newValue: @escaping @autoclosure () -> Double)
    -> Mockable<VariableDeclaration, (Double) -> Void, Void>

  func getExplicitInitializedType()
    -> Mockable<VariableDeclaration, () -> String, String>
  func setExplicitInitializedType(_ newValue: @escaping @autoclosure () -> String)
    -> Mockable<VariableDeclaration, (String) -> Void, Void>

  func getImplicitGenericInitializedType()
    -> Mockable<VariableDeclaration, () -> Array<(String, Int)>, Array<(String, Int)>>
  func setImplicitGenericInitializedType(_ newValue: @escaping @autoclosure () -> Array<(String, Int)>)
    -> Mockable<VariableDeclaration, (Array<(String, Int)>) -> Void, Void>

  func getImplicitInitializedType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setImplicitInitializedType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>

  func getIntType()
    -> Mockable<VariableDeclaration, () -> Int, Int>
  func setIntType(_ newValue: @escaping @autoclosure () -> Int)
    -> Mockable<VariableDeclaration, (Int) -> Void, Void>

  func getQualifiedEnumType()
    -> Mockable<VariableDeclaration, () -> MockingbirdTestsHost.EnumType, MockingbirdTestsHost.EnumType>
  func setQualifiedEnumType(_ newValue: @escaping @autoclosure () -> MockingbirdTestsHost.EnumType)
    -> Mockable<VariableDeclaration, (MockingbirdTestsHost.EnumType) -> Void, Void>

  func getQualifiedImplicitInitializedType()
    -> Mockable<VariableDeclaration, () -> Swift.Bool, Swift.Bool>

  func setQualifiedImplicitInitializedType(_ newValue: @escaping @autoclosure () -> Swift.Bool)
    -> Mockable<VariableDeclaration, (Swift.Bool) -> Void, Void>

  func getStringArrayType()
    -> Mockable<VariableDeclaration, () -> [String], [String]>
  func setStringArrayType(_ newValue: @escaping @autoclosure () -> [String])
    -> Mockable<VariableDeclaration, ([String]) -> Void, Void>

  func getStringType()
    -> Mockable<VariableDeclaration, () -> String, String>
  func setStringType(_ newValue: @escaping @autoclosure () -> String)
    -> Mockable<VariableDeclaration, (String) -> Void, Void>

  func getTupleType()
    -> Mockable<VariableDeclaration, () -> (Bool, Bool), (Bool, Bool)>
  func setTupleType(_ newValue: @escaping @autoclosure () -> (Bool, Bool))
    -> Mockable<VariableDeclaration, ((Bool, Bool)) -> Void, Void>
}
extension ImplicitVariableTypesMock: StubbableImplicitVariableTypes {}
