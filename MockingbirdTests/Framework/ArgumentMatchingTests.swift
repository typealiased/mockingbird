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
  
  var concreteMock: ArgumentMatchingProtocolMock!
  
  override func setUp() {
    concreteMock = mock(ArgumentMatchingProtocol.self)
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
    given(concreteMock.method(structType: StructType(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType()))
    verify(concreteMock.method(structType: StructType(),
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
    given(concreteMock.method(structType: any(),
                              classType: classTypeReference,
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, classType: classTypeReference))
    verify(concreteMock.method(structType: any(),
                               classType: classTypeReference,
                               enumType: any(),
                               stringType: any(),
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_enumType() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: .failure,
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, enumType: .failure))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: .failure,
                               stringType: any(),
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_stringType() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: "hello-world",
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, stringType: "hello-world"))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: any(),
                               stringType: "hello-world",
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_boolType() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: false,
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, boolType: false))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: any(),
                               stringType: any(),
                               boolType: false,
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_metaType() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: ClassType.self,
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, metaType: ClassType.self))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: any(),
                               stringType: any(),
                               boolType: any(),
                               metaType: ClassType.self,
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_anyType() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(of: 1),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, anyType: 1))
    verify(concreteMock.method(structType: any(),
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
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(of: ConcreteAnyType()),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, anyType: ConcreteAnyType()))
    verify(concreteMock.method(structType: any(),
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
    given(concreteMock.method(optionalStructType: nil,
                              optionalClassType: notNil(),
                              optionalEnumType: notNil(),
                              optionalStringType: notNil(),
                              optionalBoolType: notNil(),
                              optionalMetaType: notNil(),
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalStructType: nil))
    verify(concreteMock.method(optionalStructType: nil,
                               optionalClassType: notNil(),
                               optionalEnumType: notNil(),
                               optionalStringType: notNil(),
                               optionalBoolType: notNil(),
                               optionalMetaType: notNil(),
                               optionalAnyType: notNil(),
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: nil,
                              optionalEnumType: notNil(),
                              optionalStringType: notNil(),
                              optionalBoolType: notNil(),
                              optionalMetaType: notNil(),
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalClassType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
                               optionalClassType: nil,
                               optionalEnumType: notNil(),
                               optionalStringType: notNil(),
                               optionalBoolType: notNil(),
                               optionalMetaType: notNil(),
                               optionalAnyType: notNil(),
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: notNil(),
                              optionalEnumType: nil,
                              optionalStringType: notNil(),
                              optionalBoolType: notNil(),
                              optionalMetaType: notNil(),
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalEnumType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
                               optionalClassType: notNil(),
                               optionalEnumType: nil,
                               optionalStringType: notNil(),
                               optionalBoolType: notNil(),
                               optionalMetaType: notNil(),
                               optionalAnyType: notNil(),
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: notNil(),
                              optionalEnumType: notNil(),
                              optionalStringType: nil,
                              optionalBoolType: notNil(),
                              optionalMetaType: notNil(),
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalStringType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
                               optionalClassType: notNil(),
                               optionalEnumType: notNil(),
                               optionalStringType: nil,
                               optionalBoolType: notNil(),
                               optionalMetaType: notNil(),
                               optionalAnyType: notNil(),
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: notNil(),
                              optionalEnumType: notNil(),
                              optionalStringType: notNil(),
                              optionalBoolType: nil,
                              optionalMetaType: notNil(),
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalBoolType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
                               optionalClassType: notNil(),
                               optionalEnumType: notNil(),
                               optionalStringType: notNil(),
                               optionalBoolType: nil,
                               optionalMetaType: notNil(),
                               optionalAnyType: notNil(),
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: notNil(),
                              optionalEnumType: notNil(),
                              optionalStringType: notNil(),
                              optionalBoolType: notNil(),
                              optionalMetaType: nil,
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalMetaType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
                               optionalClassType: notNil(),
                               optionalEnumType: notNil(),
                               optionalStringType: notNil(),
                               optionalBoolType: notNil(),
                               optionalMetaType: nil,
                               optionalAnyType: notNil(),
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: notNil(),
                              optionalEnumType: notNil(),
                              optionalStringType: notNil(),
                              optionalBoolType: notNil(),
                              optionalMetaType: notNil(),
                              optionalAnyType: nil,
                              optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalAnyType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
                               optionalClassType: notNil(),
                               optionalEnumType: notNil(),
                               optionalStringType: notNil(),
                               optionalBoolType: notNil(),
                               optionalMetaType: notNil(),
                               optionalAnyType: nil,
                               optionalAnyObjectType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: notNil(),
                              optionalClassType: notNil(),
                              optionalEnumType: notNil(),
                              optionalStringType: notNil(),
                              optionalBoolType: notNil(),
                              optionalMetaType: notNil(),
                              optionalAnyType: notNil(),
                              optionalAnyObjectType: nil)) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalAnyObjectType: nil))
    verify(concreteMock.method(optionalStructType: notNil(),
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
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalStructType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalClassType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalEnumType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalStringType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalBoolType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalMetaType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalAnyType: nil))
    verify(concreteMock.method(optionalStructType: any(),
                               optionalClassType: any(),
                               optionalEnumType: any(),
                               optionalStringType: any(),
                               optionalBoolType: any(),
                               optionalMetaType: any(),
                               optionalAnyType: any(),
                               optionalAnyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any(),
                              optionalClassType: any(),
                              optionalEnumType: any(),
                              optionalStringType: any(),
                              optionalBoolType: any(),
                              optionalMetaType: any(),
                              optionalAnyType: any(),
                              optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(callOptionalMethod(on: concreteMock, optionalAnyObjectType: nil))
    verify(concreteMock.method(optionalStructType: any(),
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
    given(concreteMock.method(structType: any(of: StructType(value: 0), StructType(value: 1)),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 1)))
    verify(concreteMock.method(structType: any(of: StructType(value: 0), StructType(value: 1)),
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
    given(concreteMock.method(structType: any(),
                              classType: any(of: otherClassType, classType),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, classType: classType))
    verify(concreteMock.method(structType: any(),
                               classType: any(of: otherClassType, classType),
                               enumType: any(),
                               stringType: any(),
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_enumType_multipleValueMatching() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(of: .success, .failure),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, enumType: .failure))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: any(of: .success, .failure),
                               stringType: any(),
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_stringType_multipleValueMatching() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(of: "foo", "bar", "hello-world"),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, stringType: "hello-world"))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: any(),
                               stringType: any(of: "foo", "bar", "hello-world"),
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_boolType_multipleValueMatching() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(of: true, false),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, boolType: false))
    verify(concreteMock.method(structType: any(),
                               classType: any(),
                               enumType: any(),
                               stringType: any(),
                               boolType: any(of: true, false),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
  
  func testArgumentMatching_anyType_multipleValueMatching() {
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(of: true, "hello", StructType(), ClassType()),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, anyType: "hello"))
    verify(concreteMock.method(structType: any(),
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
    given(concreteMock.method(structType: any(),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any(of: ClassType(), classTypeReference))) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, anyObjectType: classTypeReference))
    verify(concreteMock.method(structType: any(),
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
    given(concreteMock.method(structType: any(where: { $0.value > 99 }),
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 100)))
    verify(concreteMock.method(structType: any(where: { $0.value > 99 }),
                               classType: any(),
                               enumType: any(),
                               stringType: any(),
                               boolType: any(),
                               metaType: any(),
                               anyType: any(),
                               anyObjectType: any())).wasCalled()
  }
}
