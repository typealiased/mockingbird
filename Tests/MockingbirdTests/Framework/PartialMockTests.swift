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
  
  func testForwardPropertyToObject() throws {
    given(self.protocolMock.property).willForward(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
    protocolMock.property = "hello"
    XCTAssertEqual(protocolMock.property, "hello")
    XCTAssertEqual(implementer.property, "hello")
    verify(self.protocolMock.property).wasCalled(twice)
  }
  
  func testForwardMethodToObject() throws {
    given(protocolMock.method(value: any())).willForward(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
    verify(protocolMock.method(value: "hello")).wasCalled()
  }
  
  func testForwardPropertyToSuperclass() throws {
    given(self.classMock.property).willForwardToSuper()
    XCTAssertEqual(classMock.property, "super")
    classMock.property = "hello"
    XCTAssertEqual(classMock.property, "hello")
    verify(self.classMock.property).wasCalled(twice)
  }
  
  func testForwardMethodToSuperclass() throws {
    given(classMock.method(value: any())).willForwardToSuper()
    XCTAssertEqual(classMock.method(value: "hello"), "super-hello")
    verify(classMock.method(value: "hello")).wasCalled()
  }
  
  // MARK: - Precedence
  
  func testPropertyGetterForwardingPrecedence() throws {
    given(self.protocolMock.property).willForward(to: OverriddenImplementer())
    given(self.protocolMock.property).willForward(to: implementer)
    XCTAssertEqual(protocolMock.property, "foobar")
  }
  
  func testPropertySetterForwardingPrecedence() throws {
    given(self.protocolMock.property).willForward(to: OverriddenImplementer())
    given(self.protocolMock.property).willForward(to: implementer)
    protocolMock.property = "foobar"
  }
  
  func testMethodForwardingPrecedence() throws {
    given(protocolMock.method(value: any())).willForward(to: OverriddenImplementer())
    given(protocolMock.method(value: any())).willForward(to: implementer)
    XCTAssertEqual(protocolMock.method(value: "hello"), "hello")
  }
}
