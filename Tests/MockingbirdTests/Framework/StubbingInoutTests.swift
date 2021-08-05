//
//  StubbingInoutTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/25/21.
//

import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class StubbingInoutTests: BaseTestCase {
  
  var inoutProtocol: InoutProtocolMock!
  var inoutProtocolInstance: InoutProtocol { return inoutProtocol }
  
  override func setUp() {
    inoutProtocol = mock(InoutProtocol.self)
  }
  
  // MARK: Inout parameters

  func testInoutParameter_doesNotMutateString() {
    given(inoutProtocol.parameterizedMethod(object: any())) ~> { _ in }
    var valueType = "foo bar"
    inoutProtocolInstance.parameterizedMethod(object: &valueType)
    XCTAssertEqual(valueType, "foo bar")
    verify(inoutProtocol.parameterizedMethod(object: any())).wasCalled()
  }
  func testInoutParameter_uppercasesString() {
    given(inoutProtocol.parameterizedMethod(object: any())) ~> { $0 = $0.uppercased() }
    var valueType = "foo bar"
    inoutProtocolInstance.parameterizedMethod(object: &valueType)
    XCTAssertEqual(valueType, "FOO BAR")
    verify(inoutProtocol.parameterizedMethod(object: any())).wasCalled()
  }
}
