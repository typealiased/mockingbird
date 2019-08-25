//
//  StubbingTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

class StubbingTests: XCTestCase {
  
  var child: ChildMock!
  var childProtocol: ChildProtocolMock!
  
  override func setUp() {
    child = ChildMock()
    childProtocol = ChildProtocolMock()
  }
  
  func callTrivialInstanceMethod(on child: Child) {
    child.childTrivialInstanceMethod()
  }
  func callTrivialInstanceMethod(on child: ChildProtocol) {
    child.childTrivialInstanceMethod()
  }
  
  func callParameterizedInstanceMethod(on child: Child) -> Bool {
    return child.childParameterizedInstanceMethod(param1: true, 1)
  }
  func callParameterizedInstanceMethod(on child: ChildProtocol) -> Bool {
    return child.childParameterizedInstanceMethod(param1: true, 1)
  }
  
  func getChildComputedInstanceVariable(on child: Child) -> Bool {
    return child.childComputedInstanceVariable
  }
  func getChildInstanceVariable(on child: ChildProtocol) -> Bool {
    return child.childInstanceVariable
  }
  func getParentComputedInstanceVariable(on child: Child) -> Bool {
    return child.parentComputedInstanceVariable
  }
  func getParentInstanceVariable(on child: ChildProtocol) -> Bool {
    return child.parentInstanceVariable
  }
  
  func testStubTrivialMethod_onClassMock_implicitlyStubbed() {
    callTrivialInstanceMethod(on: child)
  }
  func testStubTrivialMethod_onProtocolMock_implicitlyStubbed() {
    callTrivialInstanceMethod(on: childProtocol)
  }
  
  func testStubTrivialMethod_onClassMock() {
    given(self.child.childTrivialInstanceMethod()) ~> ()
    callTrivialInstanceMethod(on: child)
  }
  func testStubTrivialMethod_onProtocolMock() {
    given(self.childProtocol.childTrivialInstanceMethod()) ~> ()
    callTrivialInstanceMethod(on: childProtocol)
  }
  
  func testStubParameterizedMethod_onClassMock_withAnyMatcher() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethod_onProtocolMock_withAnyMatcher() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubParameterizedMethod_onClassMock_stubPrecedence() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethod_onProtocolMock_stubPrecedence() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubParameterizedMethod_onClassMock_laterNonMatchingStubIsIgnored() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.child.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethod_onProtocolMock_laterNonMatchingStubIsIgnored() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubMultipleInvocations_onClassMock_withSameReturnType() {
    given(
      self.child.getChildComputedInstanceVariable(),
      self.child.getParentComputedInstanceVariable()
    ) ~> true
    XCTAssertTrue(getChildComputedInstanceVariable(on: child))
    XCTAssertTrue(getParentComputedInstanceVariable(on: child))
  }
  func testStubMultipleInvocations_onProtocolMock_withSameReturnType() {
    given(
      self.childProtocol.getChildInstanceVariable(),
      self.childProtocol.getParentInstanceVariable()
    ) ~> true
    XCTAssertTrue(getChildInstanceVariable(on: childProtocol))
    XCTAssertTrue(getParentInstanceVariable(on: childProtocol))
  }
  
  func testStubParameterizedMethod_onClassMock_withExplicitlyTypedClosure() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> {
      (param1: Bool, param2: Int) -> Bool in
      return param1 && param2 == 1
    }
    XCTAssertTrue(callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethod_onProtocolMock_withExplicitlyTypedClosure() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> {
      (param1: Bool, param2: Int) -> Bool in
      return param1 && param2 == 1
    }
    XCTAssertTrue(callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubParameterizedMethod_onClassMock_withImplicitlyTypedClosure() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any()))
      ~> { $0 && $1 == 1 }
    XCTAssertTrue(callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethod_onProtocolMock_withImplicitlyTypedClosure() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any()))
      ~> { $0 && $1 == 1 }
    XCTAssertTrue(callParameterizedInstanceMethod(on: childProtocol))
  }
}
