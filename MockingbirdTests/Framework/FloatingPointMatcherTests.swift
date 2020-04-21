//
//  FloatingPointMatcherTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/3/20.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

class FloatingPointMatcherTests: XCTestCase {
  
  var floatingPoint: ArgumentMatchingProtocolMock!
  
  override func setUp() {
    floatingPoint = mock(ArgumentMatchingProtocol.self)
  }
  
  func testMethod_exactMatch() {
    given(floatingPoint.method(floatingPoint: 0.42)) ~> true
    XCTAssertTrue((floatingPoint as ArgumentMatchingProtocol).method(floatingPoint: 0.42))
    verify(floatingPoint.method(floatingPoint: 0.42)).wasCalled()
    verify(floatingPoint.method(floatingPoint: 0.421)).wasNeverCalled()
  }
  
  func testMethod_fuzzyMatch_equalToTarget() {
    given(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.01))) ~> true
    XCTAssertTrue((floatingPoint as ArgumentMatchingProtocol).method(floatingPoint: 0.42))
    verify(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.01))).wasCalled()
    verify(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.001))).wasCalled()
  }
  
  func testMethod_fuzzyMatch_aboveTarget() {
    given(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.01))) ~> true
    XCTAssertTrue((floatingPoint as ArgumentMatchingProtocol).method(floatingPoint: 0.429))
    verify(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.01))).wasCalled()
    verify(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.001))).wasNeverCalled()
  }
  
  func testMethod_fuzzyMatch_belowTarget() {
    given(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.01))) ~> true
    XCTAssertTrue((floatingPoint as ArgumentMatchingProtocol).method(floatingPoint: 0.411))
    verify(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.01))).wasCalled()
    verify(floatingPoint.method(floatingPoint: around(0.42, tolerance: 0.001))).wasNeverCalled()
  }
}
