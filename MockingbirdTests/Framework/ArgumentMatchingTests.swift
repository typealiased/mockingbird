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
    mock = mockProtocol(ArgumentMatchingProtocol.self)
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
                           anyType: any(of: 1),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, anyType: 1))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(of: 1),
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
                           anyType: any(of: ConcreteAnyType()),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, anyType: ConcreteAnyType()))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(of: ConcreteAnyType()),
                            anyObjectType: any())).wasCalled()
  }
  
  // MARK: - Optional arguments + strict matching
  
  func testArgumentMatching_optionalStructType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: nil,
                           optionalClassType: notNil(),
                           optionalEnumType: notNil(),
                           optionalStringType: notNil(),
                           optionalBoolType: notNil(),
                           optionalMetaType: notNil(),
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalStructType: nil))
    verify(self.mock.method(optionalStructType: nil,
                            optionalClassType: notNil(),
                            optionalEnumType: notNil(),
                            optionalStringType: notNil(),
                            optionalBoolType: notNil(),
                            optionalMetaType: notNil(),
                            optionalAnyType: notNil(),
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: nil,
                           optionalEnumType: notNil(),
                           optionalStringType: notNil(),
                           optionalBoolType: notNil(),
                           optionalMetaType: notNil(),
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalClassType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: nil,
                            optionalEnumType: notNil(),
                            optionalStringType: notNil(),
                            optionalBoolType: notNil(),
                            optionalMetaType: notNil(),
                            optionalAnyType: notNil(),
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: notNil(),
                           optionalEnumType: nil,
                           optionalStringType: notNil(),
                           optionalBoolType: notNil(),
                           optionalMetaType: notNil(),
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalEnumType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: notNil(),
                            optionalEnumType: nil,
                            optionalStringType: notNil(),
                            optionalBoolType: notNil(),
                            optionalMetaType: notNil(),
                            optionalAnyType: notNil(),
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: notNil(),
                           optionalEnumType: notNil(),
                           optionalStringType: nil,
                           optionalBoolType: notNil(),
                           optionalMetaType: notNil(),
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalStringType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: notNil(),
                            optionalEnumType: notNil(),
                            optionalStringType: nil,
                            optionalBoolType: notNil(),
                            optionalMetaType: notNil(),
                            optionalAnyType: notNil(),
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: notNil(),
                           optionalEnumType: notNil(),
                           optionalStringType: notNil(),
                           optionalBoolType: nil,
                           optionalMetaType: notNil(),
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalBoolType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: notNil(),
                            optionalEnumType: notNil(),
                            optionalStringType: notNil(),
                            optionalBoolType: nil,
                            optionalMetaType: notNil(),
                            optionalAnyType: notNil(),
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: notNil(),
                           optionalEnumType: notNil(),
                           optionalStringType: notNil(),
                           optionalBoolType: notNil(),
                           optionalMetaType: nil,
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalMetaType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: notNil(),
                            optionalEnumType: notNil(),
                            optionalStringType: notNil(),
                            optionalBoolType: notNil(),
                            optionalMetaType: nil,
                            optionalAnyType: notNil(),
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: notNil(),
                           optionalEnumType: notNil(),
                           optionalStringType: notNil(),
                           optionalBoolType: notNil(),
                           optionalMetaType: notNil(),
                           optionalAnyType: nil,
                           optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalAnyType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: notNil(),
                            optionalEnumType: notNil(),
                            optionalStringType: notNil(),
                            optionalBoolType: notNil(),
                            optionalMetaType: notNil(),
                            optionalAnyType: nil,
                            optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingStrictMatching() {
    given(self.mock.method(optionalStructType: notNil(),
                           optionalClassType: notNil(),
                           optionalEnumType: notNil(),
                           optionalStringType: notNil(),
                           optionalBoolType: notNil(),
                           optionalMetaType: notNil(),
                           optionalAnyType: notNil(),
                           optionalAnyObjectType: nil)) ~> true
    XCTAssertTrue(callOptionalMethod(on: mock, optionalAnyObjectType: nil))
    verify(self.mock.method(optionalStructType: notNil(),
                            optionalClassType: notNil(),
                            optionalEnumType: notNil(),
                            optionalStringType: notNil(),
                            optionalBoolType: notNil(),
                            optionalMetaType: notNil(),
                            optionalAnyType: notNil(),
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
  
  // MARK: - Multiple argument matching
  
  func testArgumentMatching_structType_multipleValueMatching() {
    given(self.mock.method(structType: any(of: StructType(value: 0), StructType(value: 1)),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, structType: StructType(value: 1)))
    verify(self.mock.method(structType: any(of: StructType(value: 0), StructType(value: 1)),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_classType_multipleValueMatching() {
    let classType = ClassType()
    let otherClassType = ClassType()
    given(self.mock.method(structType: any(),
                           classType: any(of: otherClassType, classType),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, classType: classType))
    verify(self.mock.method(structType: any(),
                            classType: any(of: otherClassType, classType),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_enumType_multipleValueMatching() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(of: .success, .failure),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, enumType: .failure))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(of: .success, .failure),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_stringType_multipleValueMatching() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(of: "foo", "bar", "hello-world"),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, stringType: "hello-world"))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(of: "foo", "bar", "hello-world"),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_boolType_multipleValueMatching() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(of: true, false),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, boolType: false))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(of: true, false),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_anyType_multipleValueMatching() {
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(of: true, "hello", StructType(), ClassType()),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, anyType: "hello"))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(of: true, "hello", StructType(), ClassType()),
                            anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_anyObjectType_multipleValueMatching() {
    let classTypeReference = ClassType()
    given(self.mock.method(structType: any(),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any(of: ClassType(), classTypeReference))) ~> true
    XCTAssertTrue(callMethod(on: mock, anyObjectType: classTypeReference))
    verify(self.mock.method(structType: any(),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any(of: ClassType(), classTypeReference))).wasCalled()
  }
  
  // MARK: - Conditional matching
  
  func testArgumentMatching_structType_conditionalMatching() {
    given(self.mock.method(structType: any(where: { $0.value > 99 }),
                           classType: any(),
                           enumType: any(),
                           stringType: any(),
                           boolType: any(),
                           metaType: any(),
                           anyType: any(),
                           anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: mock, structType: StructType(value: 100)))
    verify(self.mock.method(structType: any(where: { $0.value > 99 }),
                            classType: any(),
                            enumType: any(),
                            stringType: any(),
                            boolType: any(),
                            metaType: any(),
                            anyType: any(),
                            anyObjectType: any())).wasCalled()
  }
}
