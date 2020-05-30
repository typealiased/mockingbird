//
//  ImplicitVariableTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 5/4/20.
//

import Foundation

func NotAType() -> Bool { return true }

enum EnumWithCapitalizedCases {
  case Success
  case Failure
}

class ImplicitVariableTypes {
  // MARK: Inferrable
  var boolType = true
  var tupleType = (true, true)
  var stringType = "foo"
  var intType = 42
  var doubleType = 42.0
  var stringArrayType = ["foo", "bar"]
  var dictionaryType = ["foo": true, "bar": false]
  var dictionaryArrayType = ["foo": [true, true], "bar": [false, false]]
  var dictionaryDictionaryType = ["foo": ["hello": true], "bar": ["world": false]]
  var qualifiedEnumType = EnumType.success
  var explicitInitializedType = String.init("a")
  var implicitInitializedType = Bool(booleanLiteral: true)
  var implicitGenericInitializedType = Array<(String, Int)>(arrayLiteral: ("foo", 1))
  var qualifiedImplicitInitializedType = Swift.Bool(booleanLiteral: true)
  
  // MARK: Not inferrable
  var complexFunctionalType = "foo".map({ $0.uppercased() })
  var qualifiedCapitalizedEnumType = EnumWithCapitalizedCases.Success
  lazy var lazyComplexFunctionalType = self.stringType.map({ $0.uppercased() })
  // var actuallyAFunction = NotAType() // TODO: This is an edge case we don't handle yet.
}
