//
//  InlinePropertyTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/25/21.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

class InlinePropertyTests: BaseTestCase {
  
  var protocolMock: MinimalProtocolMock!
  var protocolInstance: MinimalProtocol { return protocolMock }
  
  override func setUpWithError() throws {
    protocolMock = mock(MinimalProtocol.self)
  }
  
  // MARK: - Getter
  
  func testGetterReturnsValue() throws {
    given(protocolMock.property).willReturn("hello")
    XCTAssertEqual(protocolMock.property, "hello")
    verify(protocolMock.property).wasCalled()
  }
  func testGetterReturnsValue_stubbingOperator() throws {
    given(protocolMock.property) ~> "hello"
    XCTAssertEqual(protocolMock.property, "hello")
    verify(protocolMock.property).wasCalled()
  }
  
  func testGetterCallsImplementation() throws {
    given(protocolMock.property).will { return "hello" }
    XCTAssertEqual(protocolMock.property, "hello")
    verify(protocolMock.property).wasCalled()
  }
  func testGetterCallsImplementation_stubbingOperator() throws {
    given(protocolMock.property) ~> { return "hello" }
    XCTAssertEqual(protocolMock.property, "hello")
    verify(protocolMock.property).wasCalled()
  }
  
  func testGetterIgnoresThrowingErrorStub() throws {
    shouldFail {
      struct FakeError: Error {}
      given(self.protocolMock.property).willThrow(FakeError())
      _ = self.protocolMock.property
    }
  }
  func testGetterIgnoresThrowingErrorStub_stubbingOperator() throws {
    shouldFail {
      struct FakeError: Error {}
      given(self.protocolMock.property) ~> { throw FakeError() }
      _ = self.protocolMock.property
    }
  }
  
  // MARK: - Setter
  
  func testSetterExactMatchCallsImplementation() throws {
    let expectation = XCTestExpectation()
    given(protocolMock.property = "hello").will { expectation.fulfill() }
    protocolMock.property = "hello"
    verify(protocolMock.property = "hello").wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testSetterExactMatchCallsImplementation_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(protocolMock.property = "hello") ~> { expectation.fulfill() }
    protocolMock.property = "hello"
    verify(protocolMock.property = "hello").wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testSetterExactMatchIgnoresThrowingErrorStub() throws {
    struct FakeError: Error {}
    given(self.protocolMock.property = "hello").willThrow(FakeError())
    self.protocolMock.property = "hello"
  }
  func testSetterExactMatchIgnoresThrowingErrorStub_stubbingOperator() throws {
    struct FakeError: Error {}
    given(self.protocolMock.property = "hello") ~> { throw FakeError() }
    self.protocolMock.property = "hello"
  }
  
  func testSetterWildcardMatchCallsImplementation() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = any()).will { expectation.fulfill() }
    protocolMock.property = "hello"
    protocolMock.property = "goodbye"
    verify(protocolMock.property = any()).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  func testSetterWildcardMatchCallsImplementation_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = any()) ~> { expectation.fulfill() }
    protocolMock.property = "hello"
    protocolMock.property = "goodbye"
    verify(protocolMock.property = any()).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  
  func testSetterWildcardMatchWithExplicitIndexCallsImplementation() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = firstArg(any())).will { expectation.fulfill() }
    protocolMock.property = "hello"
    protocolMock.property = "goodbye"
    verify(protocolMock.property = firstArg(any())).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  func testSetterWildcardMatchWithExplicitIndexCallsImplementation_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = firstArg(any())) ~> { expectation.fulfill() }
    protocolMock.property = "hello"
    protocolMock.property = "goodbye"
    verify(protocolMock.property = firstArg(any())).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  
  
  func testSetterConditionalWildcardMatchCallsImplementation() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = any(where: { $0.first == "h" })).will { expectation.fulfill() }
    protocolMock.property = "hello"
    protocolMock.property = "hey"
    verify(protocolMock.property = any(where: { $0.first == "h" })).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  func testSetterConditionalWildcardMatchCallsImplementation_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = any(where: { $0.first == "h" })) ~> { expectation.fulfill() }
    protocolMock.property = "hello"
    protocolMock.property = "hey"
    verify(protocolMock.property = any(where: { $0.first == "h" })).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  
  func testSetterConditionalWildcardMatchDoesNotCallImplementation() throws {
    given(protocolMock.property = any(where: { $0.count == 10 })).will { XCTFail() }
    protocolMock.property = "hello"
    verify(protocolMock.property = any(where: { $0.count == 10 })).wasNeverCalled()
  }
  func testSetterConditionalWildcardMatchDoesNotCallImplementation_stubbingOperator() throws {
    given(protocolMock.property = any(where: { $0.count == 10 })) ~> { XCTFail() }
    protocolMock.property = "hello"
    verify(protocolMock.property = any(where: { $0.count == 10 })).wasNeverCalled()
  }
  
  // MARK: - Precendence
  
  func testGetterLaterStubsHavePrecendence() throws {
    given(protocolMock.property).willReturn("1")
    XCTAssertEqual(protocolMock.property, "1")
    given(protocolMock.property).willReturn("2")
    XCTAssertEqual(protocolMock.property, "2")
    verify(protocolMock.property).wasCalled(twice)
  }
  func testGetterLaterStubsHavePrecendence_stubbingOperator() throws {
    given(protocolMock.property) ~> "1"
    XCTAssertEqual(protocolMock.property, "1")
    given(protocolMock.property) ~> "2"
    XCTAssertEqual(protocolMock.property, "2")
    verify(protocolMock.property).wasCalled(twice)
  }
  
  func testSetterExactMatchLaterStubsHavePrecendence() throws {
    let expectation = XCTestExpectation()
    given(protocolMock.property = "1").will { XCTFail() }
    given(protocolMock.property = "1").will { expectation.fulfill() }
    protocolMock.property = "1"
    verify(protocolMock.property = "1").wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testSetterExactMatchLaterStubsHavePrecendence_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(protocolMock.property = "1") ~> { XCTFail() }
    given(protocolMock.property = "1") ~> { expectation.fulfill() }
    protocolMock.property = "1"
    verify(protocolMock.property = "1").wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testSetterWildcardMatchLaterStubsHavePrecendence() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = firstArg(any())).will { XCTFail() }
    given(protocolMock.property = firstArg(any())).will { expectation.fulfill() }
    protocolMock.property = "1"
    protocolMock.property = "2"
    verify(protocolMock.property = firstArg(any())).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  func testSetterWildcardMatchLaterStubsHavePrecendence_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(protocolMock.property = firstArg(any())) ~> { XCTFail() }
    given(protocolMock.property = firstArg(any())) ~> { expectation.fulfill() }
    protocolMock.property = "1"
    protocolMock.property = "2"
    verify(protocolMock.property = firstArg(any())).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  
}
