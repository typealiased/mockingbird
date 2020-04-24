//
//  InferTypeTests.swift
//  MockingbirdTests
//
//  Created by Ryan Meisters on 4/23/20.
//

import XCTest

@testable import MockingbirdGenerator

class InferTypeTests: XCTestCase {
  func testInferType_InitializedType() {
    let input = "Bool(booleanLiteral: true)"
    XCTAssertEqual(inferType(from: input), "Bool")
  }

  func testInferType_InitializedTypeExplicitInit() {
    let input = "Bool.init(booleanLiteral: true)"
    XCTAssertEqual(inferType(from: input), "Bool")
  }

  func testInferType_ComplexGenericType() {
    let input = "Array<(String, String)>(arrayLiteral: (\"Test\", \"Test\"))"
    XCTAssertEqual(inferType(from: input), "Array<(String, String)>")
  }
}
