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
  
  class SelfReferencingImplementer: MinimalProtocol {
    var property: String = "foobar"
    func method(value: String) -> String {
      return property
    }
  }
  
  class UnrelatedType {}
  
  override func setUpWithError() throws {
    protocolMock = mock(MinimalProtocol.self)
    classMock = mock(MinimalClass.self)
  }
  
  // MARK: - Specific members
  
  func testForwardPropertyGetterToObject() throws {
    given(protocolMock.property).willForward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "foobar") // Setter is not stubbed
    verify(protocolMock.property).wasCalled(twice)
  }
  func testForwardPropertyGetterToObject_stubbingOperator() throws {
    given(protocolMock.property) ~> forward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "foobar") // Setter is not stubbed
    verify(protocolMock.property).wasCalled(twice)
  }
  
  func testForwardPropertySetterToObject() throws {
    let implementer = MinimalImplementer()
    given(protocolMock.property = firstArg(any())).willForward(to: implementer)
    protocolMock.property = "hello"
    XCTAssertEqual(implementer.property, "hello")
    verify(protocolMock.property = "hello").wasCalled()
  }
  func testForwardPropertySetterToObject_stubbingOperator() throws {
    let implementer = MinimalImplementer()
    given(protocolMock.property = firstArg(any())) ~> forward(to: implementer)
    protocolMock.property = "hello"
    XCTAssertEqual(implementer.property, "hello")
    verify(protocolMock.property = "hello").wasCalled()
  }
  
  func testForwardMethodToObject() throws {
    given(protocolMock.method(value: any())).willForward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  func testForwardMethodToObject_stubbingOperator() throws {
    given(protocolMock.method(value: any())) ~> forward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  
  func testForwardPropertyToSuperclass() throws {
    given(classMock.property).willForwardToSuper()
    given(classMock.property = firstArg(any())).willForwardToSuper()
    XCTAssertEqual(classMock.property, "super")
    classMock.property = "hello"
    XCTAssertEqual(classMock.property, "hello")
    verify(classMock.property = firstArg(any())).wasCalled()
  }
  func testForwardPropertyToSuperclass_stubbingOperator() throws {
    given(classMock.property) ~> forwardToSuper()
    given(classMock.property = firstArg(any())) ~> forwardToSuper()
    XCTAssertEqual(classMock.property, "super")
    classMock.property = "hello"
    XCTAssertEqual(classMock.property, "hello")
    verify(classMock.property = firstArg(any())).wasCalled()
  }
  
  func testForwardMethodToSuperclass() throws {
    given(classMock.property).willReturn("world")
    given(classMock.method(value: any())).willForwardToSuper()
    XCTAssertEqual(classMock.method(value: "hello"), "hello-world")
    verify(classMock.property).wasCalled()
    verify(classMock.method(value: "hello")).wasCalled()
  }
  func testForwardMethodToSuperclass_stubbingOperator() throws {
    given(classMock.property) ~> "world"
    given(classMock.method(value: any())) ~> forwardToSuper()
    XCTAssertEqual(classMock.method(value: "hello"), "hello-world")
    verify(classMock.property).wasCalled()
    verify(classMock.method(value: "hello")).wasCalled()
  }
  
  // MARK: - Precedence
  
  func testPropertyGetterForwardingPrecedence() throws {
    given(protocolMock.property).willForward(to: OverriddenImplementer())
    given(protocolMock.property).willForward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  func testPropertyGetterForwardingPrecedence_stubbingOperator() throws {
    given(protocolMock.property) ~> forward(to: OverriddenImplementer())
    given(protocolMock.property) ~> forward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  
  func testPropertyGetterForwardingPrecedenceWithExplicitStubs() throws {
    given(protocolMock.property).willForward(to: OverriddenImplementer())
    given(protocolMock.property).willReturn("hello")
    XCTAssertEqual(protocolMock.property, "hello")
  }
  func testPropertyGetterForwardingPrecedenceWithExplicitStubs_stubbingOperator() throws {
    given(protocolMock.property) ~> forward(to: OverriddenImplementer())
    given(protocolMock.property) ~> "hello"
    XCTAssertEqual(protocolMock.property, "hello")
  }
  
  func testPropertySetterForwardingPrecedence() throws {
    given(protocolMock.property = firstArg(any())).willForward(to: OverriddenImplementer())
    given(protocolMock.property = firstArg(any())).willForward(to: MinimalImplementer())
    protocolMock.property = "foobar"
  }
  func testPropertySetterForwardingPrecedence_stubbingOperator() throws {
    given(protocolMock.property = firstArg(any())) ~> forward(to: OverriddenImplementer())
    given(protocolMock.property = firstArg(any())) ~> forward(to: MinimalImplementer())
    protocolMock.property = "foobar"
  }
  
  func testPropertySetterForwardingPrecedenceWithExplicitStubs() throws {
    given(protocolMock.property = firstArg(any())).willForward(to: OverriddenImplementer())
    let expectation = XCTestExpectation()
    given(protocolMock.property = "foobar").will { expectation.fulfill() }
    protocolMock.property = "foobar"
    wait(for: [expectation], timeout: 2)
  }
  func testPropertySetterForwardingPrecedenceWithExplicitStubs_stubbingOperator() throws {
    given(protocolMock.property = firstArg(any())) ~> forward(to: OverriddenImplementer())
    let expectation = XCTestExpectation()
    given(protocolMock.property = "foobar") ~> { expectation.fulfill() }
    protocolMock.property = "foobar"
    wait(for: [expectation], timeout: 2)
  }
  
  func testMethodForwardingPrecedence() throws {
    given(protocolMock.method(value: any())).willForward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())).willForward(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
  }
  func testMethodForwardingPrecedence_stubbingOperator() throws {
    given(protocolMock.method(value: any())) ~> forward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())) ~> forward(to: MinimalImplementer())
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
    let implementer = MinimalImplementer()
    protocolMock.forwardCalls(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "hello")
    XCTAssertEqual(implementer.property, "hello")
    verify(protocolMock.property).wasCalled(twice)
  }
  
  func testForwardAllMethodsToObject() throws {
    protocolMock.forwardCalls(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  
  func testForwardAllMethodsPrecedence() throws {
    protocolMock.forwardCalls(to: OverriddenImplementer())
    protocolMock.forwardCalls(to: MinimalImplementer())
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  
  // MARK: - API misuse
  
  func testPropertyGetterForwardingUnrelatedTypeFails() throws {
    shouldFail {
      given(self.protocolMock.property).willForward(to: "foobar")
      _ = self.protocolMock.property
    }
  }
  func testPropertyGetterForwardingUnrelatedTypeFails_stubbingOperator() throws {
    shouldFail {
      given(self.protocolMock.property) ~> forward(to: "foobar")
      _ = self.protocolMock.property
    }
  }
  
  func testPropertyGetterForwardingUnrelatedTypePassesThrough() throws {
    given(protocolMock.property).willForward(to: MinimalImplementer())
    given(protocolMock.property).willForward(to: UnrelatedType())
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  func testPropertyGetterForwardingUnrelatedTypePassesThrough_stubbingOperator() throws {
    given(protocolMock.property) ~> forward(to: MinimalImplementer())
    given(protocolMock.property) ~> forward(to: UnrelatedType())
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  
  func testPropertySetterForwardingUnrelatedTypePassesThrough() throws {
    let implementer = MinimalImplementer()
    given(protocolMock.property = "foobar").willForward(to: implementer)
    given(protocolMock.property = "foobar").willForward(to: UnrelatedType())
    XCTAssertEqual(implementer.property, "foobar")
  }
  func testPropertySetterForwardingUnrelatedTypePassesThrough_stubbingOperator() throws {
    let implementer = MinimalImplementer()
    given(protocolMock.property = "foobar") ~> forward(to: implementer)
    given(protocolMock.property = "foobar") ~> forward(to: UnrelatedType())
    XCTAssertEqual(implementer.property, "foobar")
  }
  
  func testMethodForwardingUnrelatedTypePassesThrough() throws {
    given(protocolMock.method(value: any())).willForward(to: MinimalImplementer())
    given(protocolMock.method(value: any())).willForward(to: UnrelatedType())
    XCTAssertEqual(protocolMock.method(value: "foobar"), "foobar")
  }
  func testMethodForwardingUnrelatedTypePassesThrough_stubbingOperator() throws {
    given(protocolMock.method(value: any())) ~> forward(to: MinimalImplementer())
    given(protocolMock.method(value: any())) ~> forward(to: UnrelatedType())
    XCTAssertEqual(protocolMock.method(value: "foobar"), "foobar")
  }
  
}
