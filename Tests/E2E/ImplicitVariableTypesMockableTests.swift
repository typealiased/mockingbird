//
//  ImplicitVariableTypesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 5/4/20.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableImplicitVariableTypes {
  var boolType: Bool { get set }
  var tupleType: (Bool, Bool) { get set }
  var stringType: String { get set }
  var intType: Int { get set }
  var doubleType: Double { get set }
  var stringArrayType: [String] { get set }
  var dictionaryType: [String: Bool] { get set }
  var dictionaryArrayType: [String: [Bool]] { get set }
  var dictionaryDictionaryType: [String: [String: Bool]] { get set }
  var qualifiedEnumType: EnumType { get set }
  var explicitInitializedType: String { get set }
  var implicitInitializedType: Bool { get set }
  var implicitGenericInitializedType: Array<(String, Int)> { get set }
  var qualifiedImplicitInitializedType: Swift.Bool { get set }
}
extension ImplicitVariableTypesMock: MockableImplicitVariableTypes {}
