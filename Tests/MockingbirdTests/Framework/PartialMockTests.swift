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
  
  class MinimalImplementer: MinimalProtocol {
    var property: String = "foobar"
    func method(value: String) -> String {
      return value
    }
  }
  
  override func setUpWithError() throws {
    protocolMock = mock(MinimalProtocol.self)
  }
  
  func testForwardToSuperclass() throws {
    let target = MinimalImplementer()
    given(self.protocolMock.property).willForward(to: .object(target))
    XCTAssertEqual(protocolMock.property, "foobar")
  }
}
