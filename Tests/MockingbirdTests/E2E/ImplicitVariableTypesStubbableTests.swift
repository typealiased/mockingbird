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
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setBoolType(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>

  func getDictionaryArrayType()
    -> Mockable<PropertyGetterDeclaration, () -> [String: [Bool]], [String: [Bool]]>
  func setDictionaryArrayType(_ newValue: @autoclosure () -> [String: [Bool]])
    -> Mockable<PropertySetterDeclaration, ([String: [Bool]]) -> Void, Void>

  func getDictionaryDictionaryType()
    -> Mockable<PropertyGetterDeclaration, () -> [String: [String: Bool]], [String: [String: Bool]]>
  func setDictionaryDictionaryType(_ newValue: @autoclosure () -> [String: [String: Bool]])
    -> Mockable<PropertySetterDeclaration, ([String: [String: Bool]]) -> Void, Void>

  func getDictionaryType()
    -> Mockable<PropertyGetterDeclaration, () -> [String: Bool], [String: Bool]>
  func setDictionaryType(_ newValue: @autoclosure () -> [String: Bool])
    -> Mockable<PropertySetterDeclaration, ([String: Bool]) -> Void, Void>

  func getDoubleType()
    -> Mockable<PropertyGetterDeclaration, () -> Double, Double>
  func setDoubleType(_ newValue: @autoclosure () -> Double)
    -> Mockable<PropertySetterDeclaration, (Double) -> Void, Void>

  func getExplicitInitializedType()
    -> Mockable<PropertyGetterDeclaration, () -> String, String>
  func setExplicitInitializedType(_ newValue: @autoclosure () -> String)
    -> Mockable<PropertySetterDeclaration, (String) -> Void, Void>

  func getImplicitGenericInitializedType()
    -> Mockable<PropertyGetterDeclaration, () -> Array<(String, Int)>, Array<(String, Int)>>
  func setImplicitGenericInitializedType(_ newValue: @autoclosure () -> Array<(String, Int)>)
    -> Mockable<PropertySetterDeclaration, (Array<(String, Int)>) -> Void, Void>

  func getImplicitInitializedType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setImplicitInitializedType(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>

  func getIntType()
    -> Mockable<PropertyGetterDeclaration, () -> Int, Int>
  func setIntType(_ newValue: @autoclosure () -> Int)
    -> Mockable<PropertySetterDeclaration, (Int) -> Void, Void>

  func getQualifiedEnumType()
    -> Mockable<PropertyGetterDeclaration, () -> EnumType, EnumType>
  func setQualifiedEnumType(_ newValue: @autoclosure () -> EnumType)
    -> Mockable<PropertySetterDeclaration, (MockingbirdTestsHost.EnumType) -> Void, Void>

  func getQualifiedImplicitInitializedType()
    -> Mockable<PropertyGetterDeclaration, () -> Swift.Bool, Swift.Bool>
  func setQualifiedImplicitInitializedType(_ newValue: @autoclosure () -> Swift.Bool)
    -> Mockable<PropertySetterDeclaration, (Swift.Bool) -> Void, Void>

  func getStringArrayType()
    -> Mockable<PropertyGetterDeclaration, () -> [String], [String]>
  func setStringArrayType(_ newValue: @autoclosure () -> [String])
    -> Mockable<PropertySetterDeclaration, ([String]) -> Void, Void>

  func getStringType()
    -> Mockable<PropertyGetterDeclaration, () -> String, String>
  func setStringType(_ newValue: @autoclosure () -> String)
    -> Mockable<PropertySetterDeclaration, (String) -> Void, Void>

  func getTupleType()
    -> Mockable<PropertyGetterDeclaration, () -> (Bool, Bool), (Bool, Bool)>
  func setTupleType(_ newValue: @autoclosure () -> (Bool, Bool))
    -> Mockable<PropertySetterDeclaration, ((Bool, Bool)) -> Void, Void>
}
extension ImplicitVariableTypesMock: StubbableImplicitVariableTypes {}
