//
//  OptionalsTests.swift
//  MockingbirdTests
//
//  Created by typealias on 12/22/21.
//

import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class OptionalsTests: BaseTestCase {
  
  var optionalsMock: OptionalsProtocolMock!
  var optionalsInstance: OptionalsProtocol { optionalsMock }
  
  override func setUpWithError() throws {
    self.optionalsMock = mock(OptionalsProtocol.self)
  }
  
  func testStubNonNilReturnValue() {
    given(optionalsMock.methodWithOptionalReturn()).willReturn(true)
    XCTAssertEqual(optionalsInstance.methodWithOptionalReturn(), true)
    verify(optionalsMock.methodWithOptionalReturn()).wasCalled()
  }
  
  func testStubNilReturnValue() {
    given(optionalsMock.methodWithOptionalReturn()).willReturn(nil)
    XCTAssertNil(optionalsInstance.methodWithOptionalReturn())
    verify(optionalsMock.methodWithOptionalReturn()).wasCalled()
  }
  
  func testStubNonNilBridgedReturnValue() {
    given(optionalsMock.methodWithOptionalBridgedReturn()).willReturn("foobar")
    XCTAssertEqual(optionalsInstance.methodWithOptionalBridgedReturn(), "foobar")
    verify(optionalsMock.methodWithOptionalBridgedReturn()).wasCalled()
  }
  
  func testStubNilBridgedReturnValue() {
    given(optionalsMock.methodWithOptionalBridgedReturn()).willReturn(nil)
    XCTAssertNil(optionalsInstance.methodWithOptionalBridgedReturn())
    verify(optionalsMock.methodWithOptionalBridgedReturn()).wasCalled()
  }
  
  func testStubNonNilBridgedProperty() {
    given(optionalsMock.optionalBridgedVariable).willReturn("foobar")
    XCTAssertEqual(optionalsInstance.optionalBridgedVariable, "foobar")
    verify(optionalsMock.optionalBridgedVariable).wasCalled()
  }
  
  func testStubNilBridgedProperty() {
    given(optionalsMock.optionalBridgedVariable).willReturn(nil)
    XCTAssertNil(optionalsInstance.optionalBridgedVariable)
    verify(optionalsMock.optionalBridgedVariable).wasCalled()
  }
}
