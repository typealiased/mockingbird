//
//  ArgumentCaptorTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/25/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class ArgumentCaptorTests: XCTestCase {
  
  var concreteMock: ArgumentMatchingProtocolMock!
  var concreteInstance: ArgumentMatchingProtocol { return concreteMock }
  
  override func setUp() {
    concreteMock = mock(ArgumentMatchingProtocol.self)
  }
  
  func testArgumentCaptor_capturesSingleValue() {
    let structTypeCaptor = ArgumentCaptor<StructType>()
    given(concreteMock.method(structType: structTypeCaptor.any())) ~> true
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 99)))
    XCTAssert(structTypeCaptor.value?.value == 99)
  }
  
  func testArgumentCaptor_capturesMultipleValues_returnsLastValueCaptured() {
    let structTypeCaptor = ArgumentCaptor<StructType>()
    given(concreteMock.method(structType: structTypeCaptor.any())) ~> true
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 99)))
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 42)))
    XCTAssert(structTypeCaptor.value?.value == 42)
  }
  
  func testArgumentCaptor_capturesMultipleValues_returnsAllValuesCaptured() {
    let structTypeCaptor = ArgumentCaptor<StructType>()
    given(concreteMock.method(structType: structTypeCaptor.any())) ~> true
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 99)))
    XCTAssertTrue(concreteInstance.method(structType: StructType(value: 42)))
    XCTAssert(structTypeCaptor.allValues.map({ $0.value }) == [99, 42])
  }
}
