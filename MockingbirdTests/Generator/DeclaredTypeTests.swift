//
//  DeclaredTypeTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/2/19.
//

import XCTest
@testable import MockingbirdGenerator

class DeclaredTypeTests: XCTestCase {
  
  // MARK: - Tuples
  
  func testDeclaredType_parsesUnlabeledTuple() {
    let actual = DeclaredType(from: "(Int, Bool)")
    XCTAssertEqual("\(actual)", "(Int, Bool)")
  }
  
  func testDeclaredType_parsesLabeledTuple() {
    let actual = DeclaredType(from: "(a: Int, b: Bool)")
    XCTAssertEqual("\(actual)", "(a: Int, b: Bool)")
  }
  
  func testDeclaredType_parsesPartiallyLabeledTuple() {
    let actual = DeclaredType(from: "(a: Int, Bool, String)")
    XCTAssertEqual("\(actual)", "(a: Int, Bool, String)")
  }
  
  func testDeclaredType_parsesNestedUnlabeledTuples() {
    let actual = DeclaredType(from: "((Int), (Bool))")
    XCTAssertEqual("\(actual)", "((Int), (Bool))")
  }
  
  func testDeclaredType_parsesNestedLabeledTuples() {
    let actual = DeclaredType(from: "(a: (a: Int), b: (b: Bool))")
    XCTAssertEqual("\(actual)", "(a: (a: Int), b: (b: Bool))")
  }
  
  func testDeclaredType_parsesNestedPartiallyLabeledTuples() {
    let actual = DeclaredType(from: "(a: (a: Int, Bool, String), b: (b: Bool, Bool, String))")
    XCTAssertEqual("\(actual)", "(a: (a: Int, Bool, String), b: (b: Bool, Bool, String))")
  }
  
  func testDeclaredType_parsesEmptyTuples() {
    let actual = DeclaredType(from: "()")
    XCTAssertEqual("\(actual)", "()")
  }
  
  func testDeclaredType_parsesNestedEmptyUnlabledTuples() {
    let actual = DeclaredType(from: "((), ())")
    XCTAssertEqual("\(actual)", "((), ())")
  }
  
  func testDeclaredType_parsesNestedEmptyLabledTuples() {
    let actual = DeclaredType(from: "(a: (), b: ())")
    XCTAssertEqual("\(actual)", "(a: (), b: ())")
  }
  
  // MARK: - Functions
  
  func testDeclaredType_parsesFunctionTypes() {
    let actual = DeclaredType(from: "(Int, Bool) -> String")
    XCTAssertEqual("\(actual)", "(Int, Bool) -> String")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesLabeledFunctionTypes() {
    let actual = DeclaredType(from: "(_ a: Int, _ b: Bool) -> String")
    XCTAssertEqual("\(actual)", "(_ a: Int, _ b: Bool) -> String")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesChainedFunctionTypes() {
    let actual = DeclaredType(from: "(Int) -> (Bool) -> Void")
    XCTAssertEqual("\(actual)", "(Int) -> (Bool) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesChainedTupleFunctionTypes() {
    let actual = DeclaredType(from: "(Int) -> ((Bool) -> Void)")
    XCTAssertEqual("\(actual)", "(Int) -> ((Bool) -> Void)")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeInFunctionTypeParameters() {
    let actual = DeclaredType(from: "((Int, Bool) -> String, Int) -> Void")
    XCTAssertEqual("\(actual)", "((Int, Bool) -> String, Int) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeAttributesInFunctionTypeParameters() {
    let actual = DeclaredType(from: "(@autoclosure @escaping (Int, Bool) -> String, Int) -> Void")
    XCTAssertEqual("\(actual)", "(@escaping @autoclosure (Int, Bool) -> String, Int) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeInoutFunctionTypeParameters() {
    let actual = DeclaredType(from: "((inout Int, inout Bool) -> String, inout Int) -> Void")
    XCTAssertEqual("\(actual)", "((inout Int, inout Bool) -> String, inout Int) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeVariadicFunctionTypeParameters() {
    let actual = DeclaredType(from: "((Int..., Bool ...) -> String, Int ...) -> Void")
    XCTAssertEqual("\(actual)", "((Int..., Bool...) -> String, Int...) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeUnlabeledTupleTypeParameters() {
    let actual = DeclaredType(from: "((Int, String), (Int, String)) -> Void")
    XCTAssertEqual("\(actual)", "((Int, String), (Int, String)) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeLabeledTupleTypeParameters() {
    let actual = DeclaredType(from: "((a: Int, b: String), (a: Int, b: String)) -> Void")
    XCTAssertEqual("\(actual)", "((a: Int, b: String), (a: Int, b: String)) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypePartiallyLabeledTupleTypeParameters() {
    let actual = DeclaredType(from: "((a: Int, Bool, String), (a: Int, Bool, String)) -> Void")
    XCTAssertEqual("\(actual)", "((a: Int, Bool, String), (a: Int, Bool, String)) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeEmptyTupleTypeParameters() {
    let actual = DeclaredType(from: "((), ()) -> Void")
    XCTAssertEqual("\(actual)", "((), ()) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  // MARK: - Generics
  
  func testDeclaredType_parsesGenericType() {
    let actual = DeclaredType(from: "Array<String>")
    XCTAssertEqual("\(actual)", "Array<String>")
  }
  
  func testDeclaredType_parsesGenericFunctionTypeParameters() {
    let actual = DeclaredType(from: "(SignalProducer<String, Bool>) -> Void")
    XCTAssertEqual("\(actual)", "(SignalProducer<String, Bool>) -> Void")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionReturnType() {
    let actual = DeclaredType(from: "() -> (SignalProducer<String, Bool>)")
    XCTAssertEqual("\(actual)", "() -> (SignalProducer<String, Bool>)")
    XCTAssert(actual.isFunction)
  }
  
  // MARK: Optionals
  
  func testDeclaredType_parsesOptionalType() {
    let actual = DeclaredType(from: "String?")
    XCTAssertEqual("\(actual)", "String?")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesGenericOptionalType() {
    let actual = DeclaredType(from: "Array<String>?")
    XCTAssertEqual("\(actual)", "Array<String>?")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesGenericMultiWrappedOptionalType() {
    let actual = DeclaredType(from: "Array<String>???")
    XCTAssertEqual("\(actual)", "Array<String>???")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalTuple() {
    let actual = DeclaredType(from: "(String?, Int?)?")
    XCTAssertEqual("\(actual)", "(String?, Int?)?")
    XCTAssertTrue(actual.isTuple)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalArray() {
    let actual = DeclaredType(from: "[String?]?")
    XCTAssertEqual("\(actual)", "[String?]?")
    XCTAssertTrue(actual.isCollection)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalDictionary() {
    let actual = DeclaredType(from: "[String: Int?]?")
    XCTAssertEqual("\(actual)", "[String: Int?]?")
    XCTAssertTrue(actual.isCollection)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalFunctionTuple() {
    let actual = DeclaredType(from: "((Int) -> Void)?")
    XCTAssertEqual("\(actual)", "((Int) -> Void)?")
    XCTAssertTrue(actual.isTuple)
    XCTAssertTrue(actual.isOptional)
  }
  
  // MARK: - Qualified types
  
  func testDeclaredType_parsesFullyQualifiedType() {
    let actual = DeclaredType(from: "Foundation.Array.Element")
    XCTAssertEqual("\(actual)", "Foundation.Array.Element")
  }
  
  func testDeclaredType_parsesGenericQualifiedType() {
    let actual = DeclaredType(from: "Foundation.Array<String>.Element")
    XCTAssertEqual("\(actual)", "Foundation.Array<String>.Element")
  }
  
  func testDeclaredType_parsesFullyQualifiedTupleType() {
    let actual = DeclaredType(from: "(Foundation.Array.Element, Foundation.NSObject)")
    XCTAssertEqual("\(actual)", "(Foundation.Array.Element, Foundation.NSObject)")
  }
  
  func testDeclaredType_parsesFullyQualifiedFunctionParameterType() {
    let actual = DeclaredType(from: "(Foundation.Array.Element, Foundation.NSObject) -> Void")
    XCTAssertEqual("\(actual)", "(Foundation.Array.Element, Foundation.NSObject) -> Void")
    XCTAssertTrue(actual.isFunction)
  }
  
  func testDeclaredType_parsesFullyQualifiedFunctionReturnType() {
    let actual = DeclaredType(from: "() -> Foundation.NSObject")
    XCTAssertEqual("\(actual)", "() -> Foundation.NSObject")
    XCTAssertTrue(actual.isFunction)
  }
}
