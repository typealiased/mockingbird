//
//  InitializerTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/5/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class InitializerTests: XCTestCase {
  
  var initializerClass: InitializerClassMock!
  var initializerProtocol: InitializerProtocolMock!
  
  func testInitializerClass() {
    initializerClass = mock(InitializerClass.self).initialize()
    initializerClass = mock(InitializerClass.self).initialize(param: true)
    initializerClass = mock(InitializerClass.self).initialize(param: 1)
    initializerClass = try! mock(InitializerClass.self).initialize(param: "hello world")
    initializerClass = mock(InitializerClass.self).initialize(param: Optional<String>(nil))
  }
  
  func testInitializerProtocol() {
    initializerProtocol = mock(InitializerProtocol.self)
  }
}

