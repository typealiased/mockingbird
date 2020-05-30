//
//  OverloadedMethodTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/25/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class OverloadedMethodTests: XCTestCase {
  
  var classMock: OverloadedMethodsClassMock!
  var classInstance: OverloadedMethodsClass { return classMock }
  var protocolMock: OverloadedMethodsProtocolMock!
  var protocolInstance: OverloadedMethodsProtocol { return protocolMock }
  
  override func setUp() {
    classMock = mock(OverloadedMethodsClass.self)
    protocolMock = mock(OverloadedMethodsProtocol.self)
  }
  
  func testOverloadedMethod_classMock_overloadedParameters() {
    given(classMock.overloadedParameters(param1: any(Bool.self), param2: any())) ~> true
    given(classMock.overloadedParameters(param1: any(Int.self), param2: any())) ~> false
    XCTAssertTrue(classInstance.overloadedParameters(param1: true, param2: false))
    XCTAssertFalse(classInstance.overloadedParameters(param1: 1, param2: 2))
    verify(classMock.overloadedParameters(param1: any(Bool.self), param2: any())).wasCalled()
    verify(classMock.overloadedParameters(param1: any(Int.self), param2: any())).wasCalled()
  }
  func testOverloadedMethod_protocolMock_overloadedParameters() {
    given(protocolMock.overloadedParameters(param1: any(Bool.self), param2: any())) ~> true
    given(protocolMock.overloadedParameters(param1: any(Int.self), param2: any())) ~> false
    XCTAssertTrue(protocolInstance.overloadedParameters(param1: true, param2: false))
    XCTAssertFalse(protocolInstance.overloadedParameters(param1: 1, param2: 2))
    verify(protocolMock.overloadedParameters(param1: any(Bool.self), param2: any())).wasCalled()
    verify(protocolMock.overloadedParameters(param1: any(Int.self), param2: any())).wasCalled()
  }
  
  func testOverloadedMethod_classMock_overloadedReturnType() {
    given(classMock.overloadedReturnType()) ~> true
    given(classMock.overloadedReturnType()) ~> 1
    XCTAssert(classInstance.overloadedReturnType() == true)
    XCTAssert(classInstance.overloadedReturnType() == 1)
    verify(classMock.overloadedReturnType()).returning(Bool.self).wasCalled()
    verify(classMock.overloadedReturnType()).returning(Int.self).wasCalled()
  }
  func testOverloadedMethod_protocolMock_overloadedReturnType() {
    given(protocolMock.overloadedReturnType()) ~> true
    given(protocolMock.overloadedReturnType()) ~> 1
    XCTAssert(protocolInstance.overloadedReturnType() == true)
    XCTAssert(protocolInstance.overloadedReturnType() == 1)
    verify(protocolMock.overloadedReturnType()).returning(Bool.self).wasCalled()
    verify(protocolMock.overloadedReturnType()).returning(Int.self).wasCalled()
  }
  
  func testOverloadedMethod_classMock_overloadedParameters_separateInvocationCounts() {
    given(classMock.overloadedParameters(param1: any(Bool.self), param2: any())) ~> true
    given(classMock.overloadedParameters(param1: any(Int.self), param2: any())) ~> false
    XCTAssertTrue(classInstance.overloadedParameters(param1: true, param2: false))
    verify(classMock.overloadedParameters(param1: any(Bool.self), param2: any())).wasCalled()
    verify(classMock.overloadedParameters(param1: any(Int.self), param2: any())).wasNeverCalled()
  }
  func testOverloadedMethod_protocolMock_overloadedParameters_separateInvocationCounts() {
    given(protocolMock.overloadedParameters(param1: any(Bool.self), param2: any())) ~> true
    given(protocolMock.overloadedParameters(param1: any(Int.self), param2: any())) ~> false
    XCTAssertTrue(protocolInstance.overloadedParameters(param1: true, param2: false))
    verify(protocolMock.overloadedParameters(param1: any(Bool.self), param2: any())).wasCalled()
    verify(protocolMock.overloadedParameters(param1: any(Int.self), param2: any())).wasNeverCalled()
  }
  
  func testOverloadedMethod_classMock_overloadedReturnType_separateInvocationCounts() {
    given(classMock.overloadedReturnType()) ~> true
    given(classMock.overloadedReturnType()) ~> 1
    XCTAssert(classInstance.overloadedReturnType() == true)
    verify(classMock.overloadedReturnType()).returning(Bool.self).wasCalled()
    verify(classMock.overloadedReturnType()).returning(Int.self).wasNeverCalled()
  }
  func testOverloadedMethod_protocolMock_overloadedReturnType_separateInvocationCounts() {
    given(protocolMock.overloadedReturnType()) ~> true
    given(protocolMock.overloadedReturnType()) ~> 1
    XCTAssert(protocolInstance.overloadedReturnType() == true)
    verify(protocolMock.overloadedReturnType()).returning(Bool.self).wasCalled()
    verify(protocolMock.overloadedReturnType()).returning(Int.self).wasNeverCalled()
  }
  
  func testOverloadedMethod_classMock_overloadedGenericReturnType_separateInvocationCounts() {
    given(classMock.overloadedGenericReturnType()) ~> true
    given(classMock.overloadedGenericReturnType()) ~> 1
    XCTAssert(classInstance.overloadedGenericReturnType() == true)
    verify(classMock.overloadedGenericReturnType()).returning(Bool.self).wasCalled()
    verify(classMock.overloadedReturnType()).returning(Int.self).wasNeverCalled()
  }
  func testOverloadedMethod_protocolMock_overloadedGenericReturnType_separateInvocationCounts() {
    given(protocolMock.overloadedGenericReturnType()) ~> true
    given(protocolMock.overloadedGenericReturnType()) ~> 1
    XCTAssert(protocolInstance.overloadedGenericReturnType() == true)
    verify(protocolMock.overloadedGenericReturnType()).returning(Bool.self).wasCalled()
    verify(protocolMock.overloadedGenericReturnType()).returning(Int.self).wasNeverCalled()
  }
}
