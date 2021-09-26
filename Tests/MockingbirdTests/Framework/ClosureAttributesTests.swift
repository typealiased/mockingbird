//
//  ClosureAttributeTests.swift
//  MockingbirdTests
//
//  Created by Peter Tolsma on 9/25/21.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class ClosureAttributesTests: XCTestCase {
  var concreteClassMock: ClosureAttributesConcreteChildMock!
  var protocolMock: ClosureAttributesProtocolMock!

  override func setUp() {
    concreteClassMock = mock(ClosureAttributesConcreteChild.self)
    protocolMock = mock(ClosureAttributesProtocol.self)
  }

  // MARK: - Class Tests

  func test_classMock_genericEscaping_wildcardMatching() {
    given(concreteClassMock.doGenericEscaping(output: any())) ~> nil
    let closure: () -> String? = { "suh" }
    XCTAssertEqual(concreteClassMock.doGenericEscaping(output: closure), nil)
  }

  func test_classMock_concreteEscaping_wildcardMatching() {
    given(concreteClassMock.doConcreteEscaping(output: any())) ~> 84
    let closure: () -> Int = { 32 }
    XCTAssertEqual(concreteClassMock.doConcreteEscaping(output: closure), 84)
  }

  func test_classMock_genericInout_wildcardMatching() {
    given(concreteClassMock.doGenericInout(output: any())) ~> "gabbagool"
    var closure: () -> String = { "ABBA" }
    XCTAssertEqual(concreteClassMock.doGenericInout(output: &closure), "gabbagool")
  }

  func test_classMock_concreteInout_wildcardMatching() {
    given(concreteClassMock.doConcreteInout(output: any())) ~> 99
    var closure: () -> Int = { 33 }
    XCTAssertEqual(concreteClassMock.doConcreteInout(output: &closure), 99)
  }

  func test_classMock_genericAutoclosure_wildcardMatching() {
    given(concreteClassMock.doGenericAutoclosure(output: any())) ~> "autobot"
    XCTAssertEqual(concreteClassMock.doGenericAutoclosure(output: "decepticon"), "autobot")
  }

  func test_classMock_concreteAutoclosure_wildcardMatching() {
    given(concreteClassMock.doConcreteAutoclosure(output: any())) ~> 32
    XCTAssertEqual(concreteClassMock.doConcreteAutoclosure(output: 77), 32)
  }

  func test_classMock_genericEscapingAutoclosure_wildcardMatching() {
    given(concreteClassMock.doGenericEscapingAutoclosure(output: any())) ~> "birb"
    let someString = "on a scooter"
    XCTAssertEqual(concreteClassMock.doGenericEscapingAutoclosure(output: someString), "birb")
  }

  func test_classMock_concreteEscapingAutoclosure_wildcardMatching() {
    given(concreteClassMock.doConcreteEscapingAutoclosure(output: any())) ~> 33334
    let someInt = -8
    XCTAssertEqual(concreteClassMock.doConcreteEscapingAutoclosure(output: someInt), 33334)
  }

  // MARK: - Protocol Tests

  func test_protocolMock_escaping_wildcardMatching() {
    given(protocolMock.doEscaping(output: any())) ~> 14.3
    let closure: () -> Double = { 33.0 }
    XCTAssertEqual(protocolMock.doEscaping(output: closure), 14.3)
  }

  func test_protocolMock_inout_wildcardMatching() {
    given(protocolMock.doInout(output: any())) ~> Array("mansionz")
    var closure: () -> [Character] = { Array("The Life Of A Troubadour") }
    XCTAssertEqual(protocolMock.doInout(output: &closure), Array("mansionz"))
  }

  func test_protocolMock_autoclosure_wildcardMatching() {
    given(protocolMock.doAutoclosure(output: any())) ~> "auaaa"
    let someString = "asdfs"
    XCTAssertEqual(protocolMock.doAutoclosure(output: someString), "auaaa")
  }

  func test_protocolMock_escapingAutoclosure_wildcardMatching() {
    given(protocolMock.doEscapingAutoclosure(output: any())) ~> (-30..<30)
    let someRange = 0..<3
    XCTAssertEqual(protocolMock.doEscapingAutoclosure(output: someRange), -30..<30)
  }
}
