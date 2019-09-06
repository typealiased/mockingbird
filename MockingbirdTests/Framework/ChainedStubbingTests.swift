//
//  ChainedStubbingTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/29/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class ChainedStubbingTests: XCTestCase {
  
  var serviceRepository: ServiceRepositoryMock!
  
  override func setUp() {
    serviceRepository = mock(ServiceRepository.self)
  }
  
  func runTestCase(serviceRepository: ServiceRepository, description: String = "foo-bar") -> Bool {
    return serviceRepository.testManager.currentTest.testCase.run(description: description)
  }
  
  func testChainedStubbing_withSpecificMatching() {
    given(serviceRepository
      .getTestManager() ~ mock(TestManager.self)
        .getCurrentTest() ~ mock(Test.self)
          .getTestCase() ~ mock(TestCase.self)
            .run(description: "my test")) ~> true
    XCTAssertTrue(runTestCase(serviceRepository: serviceRepository, description: "my test"))
  }
  
  func testChainedStubbing_withWildcardMatching() {
    given(serviceRepository
      .getTestManager() ~ mock(TestManager.self)
        .getCurrentTest() ~ mock(Test.self)
          .getTestCase() ~ mock(TestCase.self)
            .run(description: any())) ~> true
    XCTAssertTrue(runTestCase(serviceRepository: serviceRepository, description: "my test"))
  }
}
