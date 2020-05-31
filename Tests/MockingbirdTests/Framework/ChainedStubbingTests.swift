//
//  ChainedStubbingTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 5/30/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class ChainedStubbingTests: BaseTestCase {
  
  struct FakeError: Error {}
  
  var protocolMock: ThrowingProtocolMock!
  var protocolInstance: ThrowingProtocol { return protocolMock }
  
  override func setUp() {
    protocolMock = mock(ThrowingProtocol.self)
  }
  
  func testChainedReturnValues() {
    given(protocolMock.throwingMethod())
      .willReturn(true)
      .willReturn(false)
      .willReturn(true)
    
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertFalse(try protocolInstance.throwingMethod())
    XCTAssertTrue(try protocolInstance.throwingMethod())
    
    // Check behavior is clamped to last stub.
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertTrue(try protocolInstance.throwingMethod())
  }
  
  func testChainedClosureImplementations() {
    given(protocolMock.throwingMethod())
      .will { return true }
      .will { return false }
      .will { return true }
    
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertFalse(try protocolInstance.throwingMethod())
    XCTAssertTrue(try protocolInstance.throwingMethod())
    
    // Check behavior is clamped to last stub.
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertTrue(try protocolInstance.throwingMethod())
  }
  
  func testImplementationProviderChain() {
    given(protocolMock.throwingMethod())
      .willReturn(sequence(of: true, false, true), transition: .after(3))
      .willReturn(false)
    
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertFalse(try protocolInstance.throwingMethod())
    XCTAssertTrue(try protocolInstance.throwingMethod())
    
    XCTAssertFalse(try protocolInstance.throwingMethod())
    
    // Check behavior is clamped to last stub.
    XCTAssertFalse(try protocolInstance.throwingMethod())
    XCTAssertFalse(try protocolInstance.throwingMethod())
  }
  
  func testMixedTypeChain() {
    given(protocolMock.throwingMethod())
      .will { return true }
      .willReturn(false)
      .will { return true }
      .willThrow(FakeError())
    
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertFalse(try protocolInstance.throwingMethod())
    XCTAssertTrue(try protocolInstance.throwingMethod())
    XCTAssertThrowsError(try protocolInstance.throwingMethod() as Bool)
    
    // Check behavior is clamped to last stub.
    XCTAssertThrowsError(try protocolInstance.throwingMethod() as Bool)
    XCTAssertThrowsError(try protocolInstance.throwingMethod() as Bool)
  }
}
