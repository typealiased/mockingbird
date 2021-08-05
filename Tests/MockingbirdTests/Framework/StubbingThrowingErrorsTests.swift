//
//  StubbingThrowingErrorsTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/25/21.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class StubbingThrowingErrorsTests: BaseTestCase {
  
  struct FakeError: Error {}
  
  var throwingProtocol: ThrowingProtocolMock!
  var throwingProtocolInstance: ThrowingProtocol { return throwingProtocol }
  
  var rethrowingProtocol: RethrowingProtocolMock!
  var rethrowingProtocolInstance: RethrowingProtocol { return rethrowingProtocol }
  
  override func setUp() {
    throwingProtocol = mock(ThrowingProtocol.self)
    rethrowingProtocol = mock(RethrowingProtocol.self)
  }

  func testStubThrowingMethod_returnsValue() {
    given(throwingProtocol.throwingMethod()) ~> true
    XCTAssertTrue(try throwingProtocolInstance.throwingMethod())
    verify(throwingProtocol.throwingMethod()).returning(Bool.self).wasCalled()
  }
  func testStubThrowingMethod_throwsError() {
    given(throwingProtocol.throwingMethod()) ~> { () throws -> Bool in throw FakeError() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod() as Bool)
    verify(throwingProtocol.throwingMethod()).returning(Bool.self).wasCalled()
  }
  func testStubParameterizedThrowingMethod_throwsError() {
    given(throwingProtocol.throwingMethod(block: any())) ~> { _ in throw FakeError() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod(block: { true }))
    verify(throwingProtocol.throwingMethod(block: any())).wasCalled()
  }
  func testStubParameterizedThrowingMethod_implicitlyRethrowsError() {
    given(throwingProtocol.throwingMethod(block: any())) ~> { _ = try $0() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod(block: { throw FakeError() }))
    verify(throwingProtocol.throwingMethod(block: any())).wasCalled()
  }
  
  func testStubThrowingMethod_returnsValue_explicitSyntax() {
    given(throwingProtocol.throwingMethod()).willReturn(true)
    XCTAssertTrue(try throwingProtocolInstance.throwingMethod())
    verify(throwingProtocol.throwingMethod()).returning(Bool.self).wasCalled()
  }
  func testStubThrowingMethod_throwsError_explicitSyntax() {
    given(throwingProtocol.throwingMethod()).returning(Bool.self).willThrow(FakeError())
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod() as Bool)
    verify(throwingProtocol.throwingMethod()).returning(Bool.self).wasCalled()
  }
  func testStubParameterizedThrowingMethod_throwsError_explicitSyntax() {
    given(throwingProtocol.throwingMethod(block: any())).willThrow(FakeError())
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod(block: { true }))
    verify(throwingProtocol.throwingMethod(block: any())).wasCalled()
  }
  func testStubParameterizedThrowingMethod_implicitlyRethrowsError_explicitSyntax() {
    given(throwingProtocol.throwingMethod(block: any())).will { _ = try $0() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod(block: { throw FakeError() }))
    verify(throwingProtocol.throwingMethod(block: any())).wasCalled()
  }
  
  func testStubRethrowingReturningMethod_returnsValue() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> true
    XCTAssertTrue(try rethrowingProtocolInstance.rethrowingMethod(block: { throw FakeError() }))
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Bool.self).wasCalled()
  }
  func testStubRethrowingReturningMethod_returnsValueFromBlock() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> { return try $0() }
    XCTAssertTrue(rethrowingProtocolInstance.rethrowingMethod(block: { return true }))
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Bool.self).wasCalled()
  }
  func testStubRethrowingReturningMethod_rethrowsError() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> { return try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Bool)
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Bool.self).wasCalled()
  }
  func testStubRethrowingNonReturningMethod_rethrowsError() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> { _ = try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Void)
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Void.self).wasCalled()
  }
  
  func testStubRethrowingReturningMethod_returnsValue_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).willReturn(true)
    XCTAssertTrue(try rethrowingProtocolInstance.rethrowingMethod(block: { throw FakeError() }))
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Bool.self).wasCalled()
  }
  func testStubRethrowingReturningMethod_returnsValueFromBlock_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).will { return try $0() }
    XCTAssertTrue(rethrowingProtocolInstance.rethrowingMethod(block: { return true }))
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Bool.self).wasCalled()
  }
  func testStubRethrowingReturningMethod_rethrowsError_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).will { return try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Bool)
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Bool.self).wasCalled()
  }
  func testStubRethrowingNonReturningMethod_rethrowsError_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).will { _ = try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Void)
    verify(rethrowingProtocol.rethrowingMethod(block: any())).returning(Void.self).wasCalled()
  }
}
