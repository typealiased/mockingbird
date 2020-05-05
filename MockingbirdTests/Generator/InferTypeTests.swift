//
//  InferTypeTests.swift
//  MockingbirdTests
//
//  Created by Ryan Meisters on 4/23/20.
//

import XCTest

@testable import MockingbirdGenerator

class InferTypeTests: XCTestCase {
  func testBooleanLiteralType() {
    XCTAssertEqual(inferType(from: "true"), "Bool")
    XCTAssertEqual(inferType(from: "false"), "Bool")
  }
  
  func testIntegerLiteralType() {
    XCTAssertEqual(inferType(from: "42"), "Int")
    XCTAssertEqual(inferType(from: "0"), "Int")
    XCTAssertEqual(inferType(from: "-42"), "Int")
  }
  
  func testDoubleLiteralType() {
    XCTAssertEqual(inferType(from: "42.0"), "Double")
    XCTAssertEqual(inferType(from: "0.0"), "Double")
    XCTAssertEqual(inferType(from: "000.00"), "Double")
    XCTAssertEqual(inferType(from: "-42.0"), "Double")
  }
  
  func testStringLiteralType() {
    XCTAssertEqual(inferType(from: #""foo bar""#), "String")
    XCTAssertEqual(inferType(from: "#\"foo bar\"#"), "String")
    XCTAssertEqual(inferType(from: "##\"foo bar\"##"), "String")
  }
  
  func testImplicitInitializedType() {
    let input = "Bool(booleanLiteral: true)"
    XCTAssertEqual(inferType(from: input), "Bool")
  }
  
  func testExplicitInitializedType() {
    let input = "Bool.init(booleanLiteral: true)"
    XCTAssertEqual(inferType(from: input), "Bool")
  }
  
  func testImplicitQualifiedInitializedType() {
    let input = "Swift.Bool(booleanLiteral: true)"
    XCTAssertEqual(inferType(from: input), "Swift.Bool")
  }
  
  func testExplicitQualifiedInitializedType() {
    let input = "Swift.Bool.init(booleanLiteral: true)"
    XCTAssertEqual(inferType(from: input), "Swift.Bool")
  }

  func testImplicitInitializedGenericType() {
    let input = #"Array<(String, Int)>(arrayLiteral: ("foo", 1))"#
    XCTAssertEqual(inferType(from: input), "Array<(String, Int)>")
  }
  
  func testExplicitInitializedGenericType() {
    let input = #"Array<(String, Int)>.init(arrayLiteral: ("foo", 1))"#
    XCTAssertEqual(inferType(from: input), "Array<(String, Int)>")
  }
  
  func testImplicitQualifiedInitializedGenericType() {
    let input = #"Foundation.Array<(String, Int)>(arrayLiteral: ("foo", 1))"#
    XCTAssertEqual(inferType(from: input), "Foundation.Array<(String, Int)>")
  }
  
  func testExplicitQualifiedInitializedGenericType() {
    let input = #"Foundation.Array<(String, Int)>.init(arrayLiteral: ("foo", 1))"#
    XCTAssertEqual(inferType(from: input), "Foundation.Array<(String, Int)>")
  }
  
  func testMappedInitializedType() {
    let input = "Bool(booleanLiteral: true).map({ $0 })"
    XCTAssertNil(inferType(from: input))
  }
  
  func testCalledInitializedType() {
    let input = "Bool(booleanLiteral: true).SomeFunction()"
    XCTAssertNil(inferType(from: input))
  }
  
  func testUniformTupleType() {
    let input = "(true, false)"
    XCTAssertEqual(inferType(from: input), "(Bool, Bool)")
  }
  
  func testMixedTupleType() {
    let input = "(true, 1)"
    XCTAssertEqual(inferType(from: input), "(Bool, Int)")
  }
  
  func testNamedTupleType() {
    let input = "(foo: true, bar: 1)"
    XCTAssertEqual(inferType(from: input), "(foo: Bool, bar: Int)")
  }
  
  func testExplicitUnnamedTupleType() {
    let input = "(_: true, _: 1)"
    XCTAssertEqual(inferType(from: input), "(Bool, Int)")
  }
  
  func testMixedNamedTupleType() {
    let input = #"(foo: true, _: "bar", 1)"#
    XCTAssertEqual(inferType(from: input), "(foo: Bool, String, Int)")
  }
  
  func testEmptyCollectionType() {
    let input = "[]"
    XCTAssertNil(inferType(from: input))
  }
  
  func testSingleElementArrayType() {
    let input = "[1]"
    XCTAssertEqual(inferType(from: input), "[Int]")
  }
  
  func testUniformArrayType() {
    let input = "[1, 2]"
    XCTAssertEqual(inferType(from: input), "[Int]")
  }
  
  func testMixedArrayType() {
    let input = #"[1, true]"#
    XCTAssertNil(inferType(from: input))
  }
  
  func testSingleElementNestedArrayType() {
    let input = #"[["foo", "bar"]]"#
    XCTAssertEqual(inferType(from: input), "[[String]]")
  }
  
  func testUniformNestedArrayType() {
    let input = #"[["foo", "bar"], ["hello"]]"#
    XCTAssertEqual(inferType(from: input), "[[String]]")
  }
  
  func testSingleItemDictionaryType() {
    let input = #"["foo": true]"#
    XCTAssertEqual(inferType(from: input), "[String: Bool]")
  }
  
  func testMultipleItemDictionaryType() {
    let input = #"["foo": true, "bar": false]"#
    XCTAssertEqual(inferType(from: input), "[String: Bool]")
  }
  
  func testSingleItemNestedDictionaryType() {
    let input = #"["foo": ["foo": true]]"#
    XCTAssertEqual(inferType(from: input), "[String: [String: Bool]]")
  }
  
  func testMultipleItemNestedDictionaryType() {
    let input = #"["foo": ["foo": true], "bar": ["bar": false]]"#
    XCTAssertEqual(inferType(from: input), "[String: [String: Bool]]")
  }
  
  func testMappedString() {
    let input = #""foo".map { $0 }"#
    XCTAssertNil(inferType(from: input))
  }
  
  func testMappedStringWithParentheses() {
    let input = #""foo".map({ $0 })"#
    XCTAssertNil(inferType(from: input))
  }
  
  func testMappedVariable() {
    let input = #"self.foo.map { $0 }"#
    XCTAssertNil(inferType(from: input))
  }
  
  func testMappedVariableWithParentheses() {
    let input = #"self.foo.map({ $0 })"#
    XCTAssertNil(inferType(from: input))
  }
  
  func testMappedCapitalizedVariableWithParentheses() {
    let input = #"Foo.map({ $0 })"#
    XCTAssertNil(inferType(from: input))
  }
}
