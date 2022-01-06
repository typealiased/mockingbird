//
//  ObjectiveCParameterTests.swift
//  MockingbirdTestsHost
//
//  Created by typealias on 12/22/21.
//

import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class ObjectiveCParameterTests: BaseTestCase {
  
  var parametersMock: ObjCParametersMock!
  var parametersInstance: ObjCParameters { parametersMock }
  
  override func setUpWithError() throws {
    self.parametersMock = mock(ObjCParameters.self)
  }
  
  func testExactParameterMatching() {
    let instance = NSViewController()
    given(parametersMock.method(value: instance)).willReturn(true)
    XCTAssertTrue(parametersInstance.method(value: instance))
    verify(parametersMock.method(value: instance)).wasCalled()
  }
  func testExactParameterMatching_stubbingOperator() {
    let instance = NSViewController()
    given(parametersMock.method(value: instance)) ~> true
    XCTAssertTrue(parametersInstance.method(value: instance))
    verify(parametersMock.method(value: instance)).wasCalled()
  }
  
  func testExactNilParameterMatching() {
    given(parametersMock.method(optionalValue: nil)).willReturn(true)
    XCTAssertTrue(parametersInstance.method(optionalValue: nil))
    verify(parametersMock.method(optionalValue: nil)).wasCalled()
  }
  func testExactNilParameterMatching_stubbingOperator() {
    given(parametersMock.method(optionalValue: nil)) ~> true
    XCTAssertTrue(parametersInstance.method(optionalValue: nil))
    verify(parametersMock.method(optionalValue: nil)).wasCalled()
  }
  
  func testWildcardParameterMatchingAny() {
    given(parametersMock.method(value: any())).willReturn(true)
    XCTAssertTrue(parametersInstance.method(value: NSViewController()))
    verify(parametersMock.method(value: any())).wasCalled()
  }
  func testWildcardParameterMatchingAny_stubbingOperator() {
    given(parametersMock.method(value: any())) ~> true
    XCTAssertTrue(parametersInstance.method(value: NSViewController()))
    verify(parametersMock.method(value: any())).wasCalled()
  }
  
  func testWildcardOptionalParameterMatchingAny() {
    given(parametersMock.method(optionalValue: any())).willReturn(true)
    XCTAssertTrue(parametersInstance.method(optionalValue: nil))
    verify(parametersMock.method(optionalValue: any())).wasCalled()
  }
  func testWildcardOptionalParameterMatchingAny_stubbingOperator() {
    given(parametersMock.method(optionalValue: any())) ~> true
    XCTAssertTrue(parametersInstance.method(optionalValue: nil))
    verify(parametersMock.method(optionalValue: any())).wasCalled()
  }
  
  func testWildcardParameterMatchingAnyWhere() {
    let instance = NSViewController()
    given(parametersMock.method(value: any(where: { $0 === instance }))).willReturn(true)
    XCTAssertTrue(parametersInstance.method(value: instance))
    verify(parametersMock.method(value: any(where: { $0 === instance }))).wasCalled()
  }
  func testWildcardParameterMatchingAnyWhere_stubbingOperator() {
    let instance = NSViewController()
    given(parametersMock.method(value: any(where: { $0 === instance }))) ~> true
    XCTAssertTrue(parametersInstance.method(value: instance))
    verify(parametersMock.method(value: any(where: { $0 === instance }))).wasCalled()
  }
  
  func testWildcardParameterMatchingNotNil() {
    given(parametersMock.method(value: notNil())).willReturn(true)
    XCTAssertTrue(parametersInstance.method(value: NSViewController()))
    verify(parametersMock.method(value: notNil())).wasCalled()
  }
  func testWildcardParameterMatchingNotNil_stubbingOperator() {
    given(parametersMock.method(value: notNil())) ~> true
    XCTAssertTrue(parametersInstance.method(value: NSViewController()))
    verify(parametersMock.method(value: notNil())).wasCalled()
  }
  
  func testWildcardOptionalParameterMatchingNotNil() {
    given(parametersMock.method(optionalValue: notNil())).willReturn(true)
    XCTAssertTrue(parametersInstance.method(optionalValue: NSViewController()))
    verify(parametersMock.method(optionalValue: notNil())).wasCalled()
  }
  func testWildcardOptionalParameterMatchingNotNil_stubbingOperator() {
    given(parametersMock.method(optionalValue: notNil())) ~> true
    XCTAssertTrue(parametersInstance.method(optionalValue: NSViewController()))
    verify(parametersMock.method(optionalValue: notNil())).wasCalled()
  }
  
  func testWildcardOptionalParameterDoesNotMatchNil() {
    shouldFail {
      given(self.parametersMock.method(optionalValue: notNil())).willReturn(true)
      XCTAssertTrue(self.parametersInstance.method(optionalValue: nil))
    }
  }
  func testWildcardOptionalParameterDoesNotMatchNil_stubbingOperator() {
    shouldFail {
      given(self.parametersMock.method(optionalValue: notNil())) ~> true
      XCTAssertTrue(self.parametersInstance.method(optionalValue: nil))
    }
  }
}
