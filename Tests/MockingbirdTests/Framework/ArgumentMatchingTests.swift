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
  var concreteInstance: ArgumentMatchingProtocol { return concreteMock }
  
  override func setUp() {
    concreteMock = mock(ArgumentMatchingProtocol.self)
  }
  
  // MARK: - Non-optional arguments
  
  func testArgumentMatching_structType() {
    given(concreteMock.method(structType: StructType())) ~> true
    XCTAssertTrue(concreteInstance.method(structType: StructType()))
    verify(concreteMock.method(structType: StructType())).wasCalled()
  }
  
  func testArgumentMatching_classType() {
    let classTypeReference = ClassType()
    given(concreteMock.method(classType: classTypeReference)) ~> true
    XCTAssertTrue(concreteInstance.method(classType: classTypeReference))
    verify(concreteMock.method(classType: classTypeReference)).wasCalled()
  }
  
  func testArgumentMatching_enumType() {
    given(concreteMock.method(enumType: .failure)) ~> true
    XCTAssertTrue(concreteInstance.method(enumType: .failure))
    verify(concreteMock.method(enumType: .failure)).wasCalled()
  }
  
  func testArgumentMatching_stringType() {
    given(concreteMock.method(stringType: "hello-world")) ~> true
    XCTAssertTrue(concreteInstance.method(stringType: "hello-world"))
    verify(concreteMock.method(stringType: "hello-world")).wasCalled()
  }
  
  func testArgumentMatching_boolType() {
    given(concreteMock.method(boolType: false)) ~> true
    XCTAssertTrue(concreteInstance.method(boolType: false))
    verify(concreteMock.method(boolType: false)).wasCalled()
  }
  
  func testArgumentMatching_protocolType_classImplementation() {
    let classTypeReference = ClassType()
    given(concreteMock.method(protocolType: classTypeReference)) ~> true
    XCTAssertTrue(concreteInstance.method(protocolType: classTypeReference))
    verify(concreteMock.method(protocolType: classTypeReference)).wasCalled()
  }
  
  func testArgumentMatching_protocolType_structImplementation() {
    given(concreteMock.method(protocolType: StructType())) ~> true
    XCTAssertTrue(concreteInstance.method(protocolType: StructType()))
    verify(concreteMock.method(protocolType: StructType())).wasCalled()
  }
  
  func testArgumentMatching_protocolType_mixedImplementation() {
    given(concreteMock.method(protocolType: StructType())) ~> true
    XCTAssertTrue(concreteInstance.method(protocolType: StructType()))
    verify(concreteMock.method(protocolType: ClassType())).wasNeverCalled()
  }
  
  func testArgumentMatching_metaType() {
    given(concreteMock.method(metaType: ClassType.self)) ~> true
    XCTAssertTrue(concreteInstance.method(metaType: ClassType.self))
    verify(concreteMock.method(metaType: ClassType.self)).wasCalled()
  }
  
  func testArgumentMatching_anyType() {
    given(concreteMock.method(anyType: any(of: 1))) ~> true
    XCTAssertTrue(concreteInstance.method(anyType: 1))
    verify(concreteMock.method(anyType: any(of: 1))).wasCalled()
  }
  
  func testArgumentMatching_anyTypeStruct() {
    struct ConcreteAnyType: Equatable {}
    given(concreteMock.method(anyType: any(ConcreteAnyType.self))) ~> true
    XCTAssertTrue(concreteInstance.method(anyType: ConcreteAnyType()))
    verify(concreteMock.method(anyType: any(ConcreteAnyType.self))).wasCalled()
  }
  
  func testArgumentMatching_anyObjectType() {
    given(concreteMock.method(anyType: any(ClassType.self))) ~> true
    XCTAssertTrue(concreteInstance.method(anyType: ClassType()))
    verify(concreteMock.method(anyType: any(ClassType.self))).wasCalled()
  }
  
  // MARK: - Optional arguments + strict matching
  
  func testArgumentMatching_optionalStructType_usingStrictMatching() {
    given(concreteMock.method(optionalStructType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalStructType: nil))
    verify(concreteMock.method(optionalStructType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingStrictMatching() {
    given(concreteMock.method(optionalClassType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalClassType: nil))
    verify(concreteMock.method(optionalClassType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingStrictMatching() {
    given(concreteMock.method(optionalEnumType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalEnumType: nil))
    verify(concreteMock.method(optionalEnumType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingStrictMatching() {
    given(concreteMock.method(optionalStringType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalStringType: nil))
    verify(concreteMock.method(optionalStringType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingStrictMatching() {
    given(concreteMock.method(optionalBoolType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalBoolType: nil))
    verify(concreteMock.method(optionalBoolType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalProtocolType_usingStrictMatching() {
    given(concreteMock.method(optionalProtocolType: Optional<ClassType>(nil))) ~> true
    XCTAssertTrue(concreteInstance.method(optionalProtocolType: Optional<ClassType>(nil)))
    verify(concreteMock.method(optionalProtocolType: Optional<ClassType>(nil))).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingStrictMatching() {
    given(concreteMock.method(optionalMetaType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalMetaType: nil))
    verify(concreteMock.method(optionalMetaType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingStrictMatching() {
    given(concreteMock.method(optionalAnyType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyType: nil))
    verify(concreteMock.method(optionalAnyType: nil)).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingStrictMatching() {
    given(concreteMock.method(optionalAnyObjectType: nil)) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyObjectType: nil))
    verify(concreteMock.method(optionalAnyObjectType: nil)).wasCalled()
  }
  
  // MARK: - Optional arguments + notNil wildcard matching
  
  func testArgumentMatching_optionalStructType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalStructType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalStructType: StructType()))
    verify(concreteMock.method(optionalStructType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalClassType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalClassType: ClassType()))
    verify(concreteMock.method(optionalClassType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalEnumType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalEnumType: .failure))
    verify(concreteMock.method(optionalEnumType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalStringType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalStringType: "hello-world"))
    verify(concreteMock.method(optionalStringType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalBoolType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalBoolType: false))
    verify(concreteMock.method(optionalBoolType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalProtocolType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalProtocolType: notNil(Optional<ClassType>.self))) ~> true
    XCTAssertTrue(concreteInstance.method(optionalProtocolType: ClassType()))
    verify(concreteMock.method(optionalProtocolType: notNil(Optional<ClassType>.self))).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalMetaType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalMetaType: ClassType.self))
    verify(concreteMock.method(optionalMetaType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalAnyType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyType: 1))
    verify(concreteMock.method(optionalAnyType: notNil())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingNotNilWildcardMatching() {
    given(concreteMock.method(optionalAnyObjectType: notNil())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyObjectType: ClassType()))
    verify(concreteMock.method(optionalAnyObjectType: notNil())).wasCalled()
  }
  
  // MARK: - Optional arguments + any wildcard matching
  
  func testArgumentMatching_optionalStructType_usingWildcardMatching() {
    given(concreteMock.method(optionalStructType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalStructType: nil))
    verify(concreteMock.method(optionalStructType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalClassType_usingWildcardMatching() {
    given(concreteMock.method(optionalClassType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalClassType: nil))
    verify(concreteMock.method(optionalClassType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalEnumType_usingWildcardMatching() {
    given(concreteMock.method(optionalEnumType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalEnumType: nil))
    verify(concreteMock.method(optionalEnumType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalStringType_usingWildcardMatching() {
    given(concreteMock.method(optionalStringType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalStringType: nil))
    verify(concreteMock.method(optionalStringType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalBoolType_usingWildcardMatching() {
    given(concreteMock.method(optionalBoolType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalBoolType: nil))
    verify(concreteMock.method(optionalBoolType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalProtocolType_usingWildcardMatching() {
    given(concreteMock.method(optionalProtocolType: any(Optional<ClassType>.self))) ~> true
    XCTAssertTrue(concreteInstance.method(optionalProtocolType: Optional<ClassType>(nil)))
    verify(concreteMock.method(optionalProtocolType: any(Optional<ClassType>.self))).wasCalled()
  }
  
  func testArgumentMatching_optionalMetaType_usingWildcardMatching() {
    given(concreteMock.method(optionalMetaType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalMetaType: nil))
    verify(concreteMock.method(optionalMetaType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyType_usingWildcardMatching() {
    given(concreteMock.method(optionalAnyType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyType: nil))
    verify(concreteMock.method(optionalAnyType: any())).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyTypeStruct_usingWildcardMatching() {
    struct ConcreteAnyType: Equatable {}
    given(concreteMock.method(optionalAnyType: any(ConcreteAnyType.self))) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyType: ConcreteAnyType()))
    verify(concreteMock.method(optionalAnyType: any(ConcreteAnyType.self))).wasCalled()
  }
  
  func testArgumentMatching_optionalAnyObjectType_usingWildcardMatching() {
    given(concreteMock.method(optionalAnyObjectType: any())) ~> true
    XCTAssertTrue(concreteInstance.method(optionalAnyObjectType: nil))
    verify(concreteMock.method(optionalAnyObjectType: any())).wasCalled()
  }
  
  // MARK: - Multiple argument matching
  
  func testArgumentMatching_structType_multipleValueMatching() {
    given(concreteMock.method(structType: any(of: StructType(value: 0), StructType(value: 1)))) ~> true
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 1)))
    verify(concreteMock.method(structType: any(of: StructType(value: 0), StructType(value: 1)))).wasCalled()
  }
  
  func testArgumentMatching_classType_multipleValueMatching() {
    let classType = ClassType()
    let otherClassType = ClassType()
    given(concreteMock.method(classType: any(of: otherClassType, classType))) ~> true
    XCTAssertTrue(concreteInstance.method(classType: classType))
    verify(concreteMock.method(classType: any(of: otherClassType, classType))).wasCalled()
  }
  
  func testArgumentMatching_enumType_multipleValueMatching() {
    given(concreteMock.method(enumType: any(of: .success, .failure))) ~> true
    XCTAssertTrue(concreteInstance.method(enumType: .failure))
    verify(concreteMock.method(enumType: any(of: .success, .failure))).wasCalled()
  }
  
  func testArgumentMatching_stringType_multipleValueMatching() {
    given(concreteMock.method(stringType: any(of: "foo", "bar", "hello-world"))) ~> true
    XCTAssertTrue(concreteInstance.method(stringType: "hello-world"))
    verify(concreteMock.method(stringType: any(of: "foo", "bar", "hello-world"))).wasCalled()
  }
  
  func testArgumentMatching_boolType_multipleValueMatching() {
    given(concreteMock.method(boolType: any(of: true, false))) ~> true
    XCTAssertTrue(concreteInstance.method(boolType: false))
    verify(concreteMock.method(boolType: any(of: true, false))).wasCalled()
  }
  
  func testArgumentMatching_anyObjectType_multipleValueMatching() {
    let classTypeReference = ClassType()
    given(concreteMock.method(anyObjectType: any(of: ClassType(), classTypeReference))) ~> true
    XCTAssertTrue(concreteInstance.method(anyObjectType: classTypeReference))
    verify(concreteMock.method(anyObjectType: any(of: ClassType(), classTypeReference))).wasCalled()
  }
  
  // MARK: - Conditional matching
  
  func testArgumentMatching_structType_conditionalMatching() {
    given(concreteMock.method(structType: any(where: { $0.value > 99 }))) ~> true
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 100)))
    verify(concreteMock.method(structType: any(where: { $0.value > 99 }))).wasCalled()
  }
  
  func testArgumentMatching_structType_didNotMatchConditionalMatching() {
    given(concreteMock.method(structType: any())) ~> true
    given(concreteMock.method(structType: any(where: { $0.value > 99 }))) ~> false
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 1)))
    verify(concreteMock.method(structType: any(where: { $0.value > 99 }))).wasNeverCalled()
  }
}
