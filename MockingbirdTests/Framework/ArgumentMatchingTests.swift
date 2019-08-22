//
//  ArgumentMatchingTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class ArgumentMatchingTests: XCTestCase {
  
  var mock: ArgumentMatchingProtocolMock!
  
  override func setUp() {
    mock = ArgumentMatchingProtocolMock()
  }
  
  func callMethod(on object: ArgumentMatchingProtocol,
                  structType: StructType = StructType(),
                  classType: ClassType = ClassType(),
                  enumType: EnumType = .success,
                  stringType: String = "foo-bar",
                  boolType: Bool = true,
                  metaType: ClassType.Type = ClassType.self,
                  anyType: Any = true,
                  anyObjectType: AnyObject = ClassType()) -> Bool {
    return object.method(structType: structType,
                         classType: classType,
                         enumType: enumType,
                         stringType: stringType,
                         boolType: boolType,
                         metaType: metaType,
                         anyType: anyType,
                         anyObjectType: anyObjectType)
  }
  
  func callOptionalMethod(on object: ArgumentMatchingProtocol,
                          optionalStructType: StructType? = StructType(),
                          optionalClassType: ClassType? = ClassType(),
                          optionalEnumType: EnumType? = .success,
                          optionalStringType: String? = "foo-bar",
                          optionalBoolType: Bool? = true,
                          optionalMetaType: ClassType.Type? = ClassType.self,
                          optionalAnyType: Any? = true,
                          optionalAnyObjectType: AnyObject? = ClassType()) -> Bool {
    return object.method(optionalStructType: optionalStructType,
                         optionalClassType: optionalClassType,
                         optionalEnumType: optionalEnumType,
                         optionalStringType: optionalStringType,
                         optionalBoolType: optionalBoolType,
                         optionalMetaType: optionalMetaType,
                         optionalAnyType: optionalAnyType,
                         optionalAnyObjectType: optionalAnyObjectType)
  }
  
  // MARK: - Non-optional arguments
  
  func testArgumentMatching_structType() {
    given(self.mock.method(structType: StructType(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, structType: StructType()))
    verify(self.mock.method(structType: StructType(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_classType() {
    let classTypeReference = ClassType()
    given(self.mock.method(structType: any(),
                           classType: classTypeReference,
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, classType: classTypeReference))
    verify(self.mock.method(structType: any(),
                            classType: classTypeReference,
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_enumType() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: .failure,
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, enumType: .failure))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: .failure,
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_stringType() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: "hello-world",
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, stringType: "hello-world"))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: "hello-world",
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_boolType() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: false,
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, boolType: false))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: false,
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_metaType() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: ClassType.self,
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, metaType: ClassType.self))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: ClassType.self,
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_anyType() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: ArgumentMatcher(1),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, anyType: 1))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: ArgumentMatcher(1),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_anyObjectType() {
    struct ConcreteAnyType: Equatable {}
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: ArgumentMatcher(ConcreteAnyType()),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, anyType: ConcreteAnyType()))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: ArgumentMatcher(ConcreteAnyType()),
                            anyObjectType: any())).wasCalled()
  }
  
  // MARK: - Optional arguments + strict matching
  
  func testArgumentMatching_optionalStructType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: nil,
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalStructType: nil))
    verify(self.mock.method(optionalStructType: nil,
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: nil,
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalClassType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: nil,
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: nil,
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalEnumType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: nil,
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: nil,
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalStringType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: nil,
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: nil,
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalBoolType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: nil,
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: nil,
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalMetaType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: nil,
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: nil,
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalAnyType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: nil,
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: nil)) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalAnyObjectType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: nil)).wasCalled()
  }
  
  // MARK: - Optional arguments + wildcard matching
  
  func testArgumentMatching_optionalStructType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalStructType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalClassType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalEnumType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalStringType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalBoolType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalMetaType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalAnyType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingWildcardMatching() {
    given(self.mock.method(optionalStructType: any(),
                           optionalClassType: any(),
                           optionalEnumType: any(),
                           optionalStringType: any(),
                           optionalBoolType: any(),
                           optionalMetaType: any(),
                           optionalAnyType: any(),
                           optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalAnyObjectType: nil))
    verify(self.mock.method(optionalStructType: any(),
                            optionalClassType: any(),
                            optionalEnumType: any(),
                            optionalStringType: any(),
                            optionalBoolType: any(),
                            optionalMetaType: any(),
                            optionalAnyType: any(),
                            optionalAnyObjectType: any())).wasCalled()
  }
}
