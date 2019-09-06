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
    initializerClass = mock(InitializerClass.self).init()
    initializerClass = mock(InitializerClass.self).init(param: true)
    initializerClass = mock(InitializerClass.self).init(param: 1)
    initializerClass = try! mock(InitializerClass.self).init(param: "hello world")
    initializerClass = mock(InitializerClass.self).init(param: Optional<String>(nil))
    initializerClass = mock(InitializerClass.self).init(param: Optional<Double>(nil))
  }
  
  func testInitializerProtocol() {
    initializerProtocol = mock(InitializerProtocol.self)
  }
}

