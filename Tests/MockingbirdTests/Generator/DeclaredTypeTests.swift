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
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((DeclaredType(Single(Int)), DeclaredType(Single(Bool)))))")
  }
  
  func testDeclaredType_parsesLabeledTuple() {
    let actual = DeclaredType(from: "(a: Int, b: Bool)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((a: DeclaredType(Single(Int)), b: DeclaredType(Single(Bool)))))")
  }
  
  func testDeclaredType_parsesPartiallyLabeledTuple() {
    let actual = DeclaredType(from: "(a: Int, Bool, String)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((a: DeclaredType(Single(Int)), DeclaredType(Single(Bool)), DeclaredType(Single(String)))))")
  }
  
  func testDeclaredType_parsesNestedUnlabeledTuples() {
    let actual = DeclaredType(from: "((Int, Int), (Bool, Bool))")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((DeclaredType(Tuple((DeclaredType(Single(Int)), DeclaredType(Single(Int))))), DeclaredType(Tuple((DeclaredType(Single(Bool)), DeclaredType(Single(Bool))))))))")
  }
  
  func testDeclaredType_parsesNestedLabeledTuples() {
    let actual = DeclaredType(from: "(a: (a: Int, b: Int), b: (a: Bool, b: Bool))")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((a: DeclaredType(Tuple((a: DeclaredType(Single(Int)), b: DeclaredType(Single(Int))))), b: DeclaredType(Tuple((a: DeclaredType(Single(Bool)), b: DeclaredType(Single(Bool))))))))")
  }
  
  func testDeclaredType_parsesNestedPartiallyLabeledTuples() {
    let actual = DeclaredType(from: "(a: (a: Int, Bool, String), b: (b: Bool, Bool, String))")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((a: DeclaredType(Tuple((a: DeclaredType(Single(Int)), DeclaredType(Single(Bool)), DeclaredType(Single(String))))), b: DeclaredType(Tuple((b: DeclaredType(Single(Bool)), DeclaredType(Single(Bool)), DeclaredType(Single(String))))))))")
  }
  
  func testDeclaredType_parsesEmptyTuples() {
    let actual = DeclaredType(from: "()")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple(()))")
  }
  
  func testDeclaredType_parsesNestedEmptyUnlabledTuples() {
    let actual = DeclaredType(from: "((), ())")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((DeclaredType(Tuple(())), DeclaredType(Tuple(())))))")
  }
  
  func testDeclaredType_parsesNestedEmptyLabledTuples() {
    let actual = DeclaredType(from: "(a: (), b: ())")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((a: DeclaredType(Tuple(())), b: DeclaredType(Tuple(())))))")
  }
  
  // MARK: - Parenthesized Expressions
  
  func testDeclaredType_parsesParenthesizedPrimitive() {
    let actual = DeclaredType(from: "(Bool)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Bool))")
  }
  
  func testDeclaredType_parsesNestedParenthesizedPrimitive() {
    let actual = DeclaredType(from: "(((Bool)))")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Bool))")
  }
  
  func testDeclaredType_parsesOptionalParenthesizedPrimitive() {
    let actual = DeclaredType(from: "(Bool)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Bool)?)")
  }
  
  func testDeclaredType_parsesSingleNestedOptionalParenthesizedPrimitive() {
    let actual = DeclaredType(from: "(((Bool)?))")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Bool)?)")
  }
  
  func testDeclaredType_parsesMultipleNestedOptionalParenthesizedPrimitive() {
    let actual = DeclaredType(from: "(((Bool)?))??!")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Bool)???!)")
  }
  
  // MARK: - Functions
  
  func testDeclaredType_parsesTrivialFunctionTypes() {
    let actual = DeclaredType(from: "() -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesSingleParameterFunctionTypes() {
    let actual = DeclaredType(from: "(Int) -> String")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(String)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesMultipleParameterFunctionTypes() {
    let actual = DeclaredType(from: "(Int, Bool) -> String")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int))), Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(String)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesLabeledFunctionTypes() {
    let actual = DeclaredType(from: "(_ a: Int, _ b: Bool) -> String")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(_ a: DeclaredType(Single(Int))), Parameter(_ b: DeclaredType(Single(Bool)))) -> DeclaredType(Single(String)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesChainedFunctionTypes() {
    let actual = DeclaredType(from: "(Int) -> (Bool) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Function((Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(Void))))))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesChainedTupleFunctionTypes() {
    let actual = DeclaredType(from: "(Int) -> ((Bool) -> Void)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Function((Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(Void))))))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeInFunctionTypeParameters() {
    let actual = DeclaredType(from: "((Int, Bool) -> String, Int) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int))), Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(String)))))), Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeAttributes() {
    let actual = DeclaredType(from: "(@autoclosure @escaping (Int, Bool) -> String, Int) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(@escaping @autoclosure DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int))), Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(String)))))), Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeAttributesWithoutWhitespace() {
    let actual = DeclaredType(from: "(@escaping(String)) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(@escaping DeclaredType(Single(String)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeAttributesChainedWithoutWhitespace() {
    let actual = DeclaredType(from: "(@autoclosure@escaping()) -> String")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(@escaping @autoclosure DeclaredType(Tuple(())))) -> DeclaredType(Single(String)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeInoutFunctionTypeParameters() {
    let actual = DeclaredType(from: "((inout Int, inout Bool) -> String, inout Int) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Function((Parameter(inout DeclaredType(Single(Int))), Parameter(inout DeclaredType(Single(Bool)))) -> DeclaredType(Single(String)))))), Parameter(inout DeclaredType(Single(Int)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeVariadicFunctionTypeParameters() {
    let actual = DeclaredType(from: "((Int..., Bool ...) -> String, Int ...) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int))...), Parameter(DeclaredType(Single(Bool))...)) -> DeclaredType(Single(String)))))), Parameter(DeclaredType(Single(Int))...)) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeUnlabeledTupleTypeParameters() {
    let actual = DeclaredType(from: "((Int, String), (Int, String)) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Tuple((DeclaredType(Single(Int)), DeclaredType(Single(String)))))), Parameter(DeclaredType(Tuple((DeclaredType(Single(Int)), DeclaredType(Single(String))))))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeLabeledTupleTypeParameters() {
    let actual = DeclaredType(from: "((a: Int, b: String), (a: Int, b: String)) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Tuple((a: DeclaredType(Single(Int)), b: DeclaredType(Single(String)))))), Parameter(DeclaredType(Tuple((a: DeclaredType(Single(Int)), b: DeclaredType(Single(String))))))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypePartiallyLabeledTupleTypeParameters() {
    let actual = DeclaredType(from: "((a: Int, Bool, String), (a: Int, Bool, String)) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Tuple((a: DeclaredType(Single(Int)), DeclaredType(Single(Bool)), DeclaredType(Single(String)))))), Parameter(DeclaredType(Tuple((a: DeclaredType(Single(Int)), DeclaredType(Single(Bool)), DeclaredType(Single(String))))))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFunctionTypeEmptyTupleTypeParameters() {
    let actual = DeclaredType(from: "((), ()) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Tuple(()))), Parameter(DeclaredType(Tuple(())))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesThrowingFunctionType() {
    let actual = DeclaredType(from: "() throws -> Bool")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() throws -> DeclaredType(Single(Bool)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesChainedThrowingFunctionTypes() {
    let actual = DeclaredType(from: "() throws -> () throws -> Bool")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() throws -> DeclaredType(Single(Function(() throws -> DeclaredType(Single(Bool))))))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesParenthesizedFunction() {
    let actual = DeclaredType(from: "((Bool) -> Bool)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(Bool)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesNestedParenthesizedFunction() {
    let actual = DeclaredType(from: "((((Bool) -> Bool)))")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(Bool)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesOptionalParenthesizedFunction() {
    let actual = DeclaredType(from: "((Bool) -> Bool)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType((Single(Function((Parameter(DeclaredType(Single(Bool)))) -> DeclaredType(Single(Bool)))))?)")
    XCTAssert(actual.isFunction)
  }
  
  // MARK: - Generics
  
  func testDeclaredType_parsesGenericType() {
    let actual = DeclaredType(from: "Array<String>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Array<DeclaredType(Single(String))>))")
  }
  
  func testDeclaredType_parsesGenericFunctionTypeParameters() {
    let actual = DeclaredType(from: "(SignalProducer<String, Bool>) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(SignalProducer<DeclaredType(Single(String)), DeclaredType(Single(Bool))>)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionParameter() {
    let actual = DeclaredType(from: "(GenericType<Bool>) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesMultipleGenericFunctionParameters() {
    let actual = DeclaredType(from: "(GenericType<Bool>, GenericType<Int>) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>))), Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Int))>)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionReturnType() {
    let actual = DeclaredType(from: "() -> GenericType<Bool>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionWrappedReturnType() {
    let actual = DeclaredType(from: "() -> (SignalProducer<String, Bool>)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(SignalProducer<DeclaredType(Single(String)), DeclaredType(Single(Bool))>)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionOptionalReturnType() {
    let actual = DeclaredType(from: "() -> GenericType<Bool>?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>)?))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionWrappedOptionalReturnType() {
    let actual = DeclaredType(from: "() -> (GenericType<Bool>)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>)?))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionParametersAndReturnType() {
    let actual = DeclaredType(from: "(GenericType<Bool>, GenericType<Int>) -> SignalProducer<String, Bool>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>))), Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Int))>)))) -> DeclaredType(Single(SignalProducer<DeclaredType(Single(String)), DeclaredType(Single(Bool))>)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesGenericFunctionParametersAndWrappedReturnType() {
    let actual = DeclaredType(from: "(GenericType<Bool>, GenericType<Int>) -> (SignalProducer<String, Bool>)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Bool))>))), Parameter(DeclaredType(Single(GenericType<DeclaredType(Single(Int))>)))) -> DeclaredType(Single(SignalProducer<DeclaredType(Single(String)), DeclaredType(Single(Bool))>)))))")
    XCTAssert(actual.isFunction)
  }
  
  // MARK: Optionals
  
  func testDeclaredType_parsesOptionalType() {
    let actual = DeclaredType(from: "String?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(String)?)")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesGenericOptionalType() {
    let actual = DeclaredType(from: "Array<String>?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Array<DeclaredType(Single(String))>)?)")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalGenericTypeParameter() {
    let actual = DeclaredType(from: "Array<String?>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Array<DeclaredType(Single(String)?)>))")
    XCTAssertFalse(actual.isOptional)
  }
  
  func testDeclaredType_parsesMultipleOptionalGenericTypeParameters() {
    let actual = DeclaredType(from: "Dictionary<String?, Int?>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Dictionary<DeclaredType(Single(String)?), DeclaredType(Single(Int)?)>))")
    XCTAssertFalse(actual.isOptional)
  }
  
  func testDeclaredType_parsesGenericImplicitlyUnwrappedOptionalType() {
    let actual = DeclaredType(from: "Array<String>!")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Array<DeclaredType(Single(String))>)!)")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesGenericMultiWrappedOptionalType() {
    let actual = DeclaredType(from: "Array<String>???")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Array<DeclaredType(Single(String))>)???)")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesGenericMultiWrappedOptionalTypeWithImplicitlyUnwrappedEnding() {
    let actual = DeclaredType(from: "Array<String>???!")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Array<DeclaredType(Single(String))>)???!)")
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalTuple() {
    let actual = DeclaredType(from: "(String?, Int?)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((DeclaredType(Single(String)?), DeclaredType(Single(Int)?)))?)")
    XCTAssertTrue(actual.isTuple)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalArray() {
    let actual = DeclaredType(from: "[String?]?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single([DeclaredType(Single(String)?)])?)")
    XCTAssertTrue(actual.isCollection)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalDictionary() {
    let actual = DeclaredType(from: "[String: Int?]?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single([DeclaredType(Single(String)): DeclaredType(Single(Int)?)])?)")
    XCTAssertTrue(actual.isCollection)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalFunctionTuple() {
    let actual = DeclaredType(from: "((Int) -> Void)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType((Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Void)))))?)")
    XCTAssertTrue(actual.isFunction)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesFunctionWithOptionalReturnType() {
    let actual = DeclaredType(from: "(Int) -> Bool?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Bool)?))))")
    XCTAssertTrue(actual.isFunction)
    XCTAssertFalse(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalFunctionWithOptionalReturnType() {
    let actual = DeclaredType(from: "((Int) -> Bool?)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType((Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Single(Bool)?))))?)")
    XCTAssertTrue(actual.isFunction)
    XCTAssertTrue(actual.isOptional)
  }
  
  func testDeclaredType_parsesOptionalFunctionWithOptionalTupleReturnType() {
    let actual = DeclaredType(from: "((Int) -> (Bool, Int)?)?")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType((Single(Function((Parameter(DeclaredType(Single(Int)))) -> DeclaredType(Tuple((DeclaredType(Single(Bool)), DeclaredType(Single(Int))))?))))?)")
    XCTAssertTrue(actual.isFunction)
    XCTAssertTrue(actual.isOptional)
  }
  
  // MARK: - Qualified types
  
  func testDeclaredType_parsesFullyQualifiedType() {
    let actual = DeclaredType(from: "Foundation.Array.Element")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Foundation.Array.Element))")
  }
  
  func testDeclaredType_parsesGenericQualifiedType() {
    let actual = DeclaredType(from: "Foundation.Array<String>.Element")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Foundation.Array<DeclaredType(Single(String))>.Element))")
  }
  
  func testDeclaredType_parsesMultipleGenericParametersQualifiedType() {
    let actual = DeclaredType(from: "Foundation.Dictionary<String, Int>.Element")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Foundation.Dictionary<DeclaredType(Single(String)), DeclaredType(Single(Int))>.Element))")
  }
  
  func testDeclaredType_parsesMultipleGenericComponentsQualifiedType() {
    let actual = DeclaredType(from: "Foundation.Dictionary<String, Int>.Array<String>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Foundation.Dictionary<DeclaredType(Single(String)), DeclaredType(Single(Int))>.Array<DeclaredType(Single(String))>))")
  }
  
  func testDeclaredType_parsesFullyQualifiedTupleType() {
    let actual = DeclaredType(from: "(Foundation.Array.Element, Foundation.NSObject)")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Tuple((DeclaredType(Single(Foundation.Array.Element)), DeclaredType(Single(Foundation.NSObject)))))")
  }
  
  func testDeclaredType_parsesFullyQualifiedFunctionParameterType() {
    let actual = DeclaredType(from: "(Foundation.Array.Element, Foundation.NSObject) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Foundation.Array.Element))), Parameter(DeclaredType(Single(Foundation.NSObject)))) -> DeclaredType(Single(Void)))))")
    XCTAssertTrue(actual.isFunction)
  }
  
  func testDeclaredType_parsesFullyQualifiedFunctionReturnType() {
    let actual = DeclaredType(from: "() -> Foundation.NSObject")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(Foundation.NSObject)))))")
    XCTAssertTrue(actual.isFunction)
  }
  
  func testDeclaredType_parsesFullyQualifiedGenericFunctionParameter() {
    let actual = DeclaredType(from: "(Foundation.Array<T>) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Foundation.Array<DeclaredType(Single(T))>)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFullyQualifiedGenericFunctionParameterAndReturnType() {
    let actual = DeclaredType(from: "(Foundation.Array<T>) -> Foundation.Array<T>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Foundation.Array<DeclaredType(Single(T))>)))) -> DeclaredType(Single(Foundation.Array<DeclaredType(Single(T))>)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFullyQualifiedCompoundGenericFunctionReturnType() {
    let actual = DeclaredType(from: "() -> Foundation.Array<Foundation.Set<String>>")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function(() -> DeclaredType(Single(Foundation.Array<DeclaredType(Single(Foundation.Set<DeclaredType(Single(String))>))>)))))")
    XCTAssert(actual.isFunction)
  }
  
  func testDeclaredType_parsesFullyQualifiedCompoundGenericFunctionParameter() {
    let actual = DeclaredType(from: "(Foundation.Array<Foundation.Set<String>>) -> Void")
    XCTAssertEqual(String(reflecting: actual), "DeclaredType(Single(Function((Parameter(DeclaredType(Single(Foundation.Array<DeclaredType(Single(Foundation.Set<DeclaredType(Single(String))>))>)))) -> DeclaredType(Single(Void)))))")
    XCTAssert(actual.isFunction)
  }
  
  // MARK: - Parameters
  
  func testParameterType_parsesDefaultParameters() {
    let actual = Function.Parameter(from: "label parameter: String = \"Hello\"")
    XCTAssertEqual(String(reflecting: actual), "Parameter(label parameter: DeclaredType(Single(String)))")
    XCTAssertEqual(actual.defaultValue, "\"Hello\"")
  }
}
