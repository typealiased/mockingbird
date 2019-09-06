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
  
  func testArgumentCaptor_capturesSingleValue() {
    let structTypeCaptor = ArgumentCaptor<StructType>()
    given(concreteMock.method(structType: structTypeCaptor.matcher,
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 99)))
    XCTAssert(structTypeCaptor.value?.value == 99)
  }
  
  func testArgumentCaptor_capturesMultipleValues_returnsLastValueCaptured() {
    let structTypeCaptor = ArgumentCaptor<StructType>()
    given(concreteMock.method(structType: structTypeCaptor.matcher,
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 99)))
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 42)))
    XCTAssert(structTypeCaptor.value?.value == 42)
  }
  
  func testArgumentCaptor_capturesMultipleValues_returnsAllValuesCaptured() {
    let structTypeCaptor = ArgumentCaptor<StructType>()
    given(concreteMock.method(structType: structTypeCaptor.matcher,
                              classType: any(),
                              enumType: any(),
                              stringType: any(),
                              boolType: any(),
                              metaType: any(),
                              anyType: any(),
                              anyObjectType: any())) ~> true
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 99)))
    XCTAssertTrue(callMethod(on: concreteMock, structType: StructType(value: 42)))
    XCTAssert(structTypeCaptor.allValues.map({ $0.value }) == [99, 42])
  }
}
