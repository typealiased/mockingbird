//
//  PartialMockTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/25/21.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

class PartialMockTests: BaseTestCase {
  
  var protocolMock: MinimalProtocolMock!
  var protocolInstance: MinimalProtocol { return protocolMock }
  
  var classMock: MinimalClassMock!
  var classInstance: MinimalClass { return classMock }
  
  var implementer: MinimalImplementer!
  
  class MinimalImplementer: MinimalProtocol {
    var property: String = "foobar"
    func method(value: String) -> String {
      return value
    }
  }
  
  class OverriddenImplementer: MinimalProtocol {
    var property: String {
      get {
        XCTFail("Property getter should not be called")
        return ""
      }
      set {
        XCTFail("Property setter should not be called")
      }
    }
    func method(value: String) -> String {
      XCTFail("Method should not be called")
      return ""
    }
  }
  
  override func setUpWithError() throws {
    protocolMock = mock(MinimalProtocol.self)
    classMock = mock(MinimalClass.self)
    implementer = MinimalImplementer()
  }
  
  // MARK: - Specific members
  
  func testForwardPropertyGetterToObject() throws {
    given(self.protocolMock.property).willForward(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "foobar") // Setter is not stubbed
    verify(self.protocolMock.property).wasCalled(twice)
  }
  func testForwardPropertyGetterToObject_stubbingOperator() throws {
    given(self.protocolMock.property) ~> forward(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "foobar") // Setter is not stubbed
    verify(self.protocolMock.property).wasCalled(twice)
  }
  
  func testForwardPropertySetterToObject() throws {
    given(self.protocolMock.property = firstArg(any())).willForward(to: implementer)
    protocolMock.property = "hello"
    XCTAssertEqual(implementer.property, "hello")
    verify(self.protocolMock.property = "hello").wasCalled()
  }
  func testForwardPropertySetterToObject_stubbingOperator() throws {
    given(self.protocolMock.property = firstArg(any())) ~> forward(to: implementer)
    protocolMock.property = "hello"
    XCTAssertEqual(implementer.property, "hello")
    verify(self.protocolMock.property = "hello").wasCalled()
  }
  
  func testForwardMethodToObject() throws {
    given(protocolMock.method(value: any())).willForward(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  func testForwardMethodToObject_stubbingOperator() throws {
    given(protocolMock.method(value: any())) ~> forward(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  
  func testForwardPropertyToSuperclass() throws {
    given(self.classMock.property).willForwardToSuper()
    given(self.classMock.property = firstArg(any())).willForwardToSuper()
    XCTAssertEqual(classMock.property, "super")
    classMock.property = "hello"
    XCTAssertEqual(classMock.property, "hello")
    verify(self.classMock.property = firstArg(any())).wasCalled()
  }
  func testForwardPropertyToSuperclass_stubbingOperator() throws {
    given(self.classMock.property) ~> forwardToSuper()
    given(self.classMock.property = firstArg(any())) ~> forwardToSuper()
    XCTAssertEqual(classMock.property, "super")
    classMock.property = "hello"
    XCTAssertEqual(classMock.property, "hello")
    verify(self.classMock.property = firstArg(any())).wasCalled()
  }
  
  func testForwardMethodToSuperclass() throws {
    given(classMock.method(value: any())).willForwardToSuper()
    XCTAssertEqual(classMock.method(value: "hello"), "super-hello")
    verify(classMock.method(value: "hello")).wasCalled()
  }
  func testForwardMethodToSuperclass_stubbingOperator() throws {
    given(classMock.method(value: any())) ~> forwardToSuper()
    XCTAssertEqual(classMock.method(value: "hello"), "super-hello")
    verify(classMock.method(value: "hello")).wasCalled()
  }
  
  // MARK: - Precedence
  
  func testPropertyGetterForwardingPrecedence() throws {
    given(self.protocolMock.property).willForward(to: OverriddenImplementer())
    given(self.protocolMock.property).willForward(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  func testPropertyGetterForwardingPrecedence_stubbingOperator() throws {
    given(self.protocolMock.property) ~> forward(to: OverriddenImplementer())
    given(self.protocolMock.property) ~> forward(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  
  func testPropertyGetterForwardingPrecedenceWithExplicitStubs() throws {
    given(self.protocolMock.property).willForward(to: OverriddenImplementer())
    given(self.protocolMock.property).willReturn("hello")
    XCTAssertEqual(protocolMock.property, "hello")
  }
  func testPropertyGetterForwardingPrecedenceWithExplicitStubs_stubbingOperator() throws {
    given(self.protocolMock.property) ~> forward(to: OverriddenImplementer())
    given(self.protocolMock.property) ~> "hello"
    XCTAssertEqual(protocolMock.property, "hello")
  }
  
  func testPropertySetterForwardingPrecedence() throws {
    given(self.protocolMock.property = firstArg(any())).willForward(to: OverriddenImplementer())
    given(self.protocolMock.property = firstArg(any())).willForward(to: implementer)
    protocolMock.property = "foobar"
  }
  func testPropertySetterForwardingPrecedence_stubbingOperator() throws {
    given(self.protocolMock.property = firstArg(any())) ~> forward(to: OverriddenImplementer())
    given(self.protocolMock.property = firstArg(any())) ~> forward(to: implementer)
    protocolMock.property = "foobar"
  }
  
  func testPropertySetterForwardingPrecedenceWithExplicitStubs() throws {
    given(self.protocolMock.property = firstArg(any())).willForward(to: OverriddenImplementer())
    let expectation = XCTestExpectation()
    given(self.protocolMock.property = "foobar").will { expectation.fulfill() }
    protocolMock.property = "foobar"
    wait(for: [expectation], timeout: 2)
  }
  func testPropertySetterForwardingPrecedenceWithExplicitStubs_stubbingOperator() throws {
    given(self.protocolMock.property = firstArg(any())) ~> forward(to: OverriddenImplementer())
    let expectation = XCTestExpectation()
    given(self.protocolMock.property = "foobar") ~> { expectation.fulfill() }
    protocolMock.property = "foobar"
    wait(for: [expectation], timeout: 2)
  }
  
  func testMethodForwardingPrecedence() throws {
    given(protocolMock.method(value: any())).willForward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())).willForward(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
  }
  func testMethodForwardingPrecedence_stubbingOperator() throws {
    given(protocolMock.method(value: any())) ~> forward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())) ~> forward(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
  }
  
  func testMethodForwardingPrecedenceWithExplicitStubs() throws {
    given(protocolMock.method(value: any())).willForward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())).willReturn("hello")
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
  }
  func testMethodForwardingPrecedenceWithExplicitStubs_stubbingOperator() throws {
    given(protocolMock.method(value: any())) ~> forward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())) ~> "hello"
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
  }
  
  // MARK: - Global
  
  func testForwardAllPropertiesToObject() throws {
    protocolMock.forwarding(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "hello")
    XCTAssertEqual(implementer.property, "hello")
    verify(self.protocolMock.property).wasCalled(twice)
  }
  
  func testForwardAllMethodsToObject() throws {
    protocolMock.forwarding(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  
}
