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
  
  class ChildVerificationProxy {
    static func callTrivialInstanceMethod(on child: Child) {
      child.childTrivialInstanceMethod()
    }
    static func callTrivialInstanceMethod(on child: ChildProtocol) {
      child.childTrivialInstanceMethod()
    }
    
    static func callParameterizedInstanceMethod(on child: Child) -> Bool {
      return child.childParameterizedInstanceMethod(param1: true, 1)
    }
    static func callParameterizedInstanceMethod(on child: ChildProtocol) -> Bool {
      return child.childParameterizedInstanceMethod(param1: true, 1)
    }
    
    static func getChildComputedInstanceVariable(on child: Child) -> Bool {
      return child.childComputedInstanceVariable
    }
    static func getChildInstanceVariable(on child: ChildProtocol) -> Bool {
      return child.childInstanceVariable
    }
    static func getParentComputedInstanceVariable(on child: Child) -> Bool {
      return child.parentComputedInstanceVariable
    }
    static func getParentInstanceVariable(on child: ChildProtocol) -> Bool {
      return child.parentInstanceVariable
    }
  }
  
  func testStubTrivialMethodImplicitlyStubbedOnClassMock() {
    ChildVerificationProxy.callTrivialInstanceMethod(on: child)
  }
  func testStubTrivialMethodImplicitlyStubbedOnProtocolMock() {
    ChildVerificationProxy.callTrivialInstanceMethod(on: childProtocol)
  }
  
  func testStubTrivialMethodOnClassMock() {
    given(self.child.childTrivialInstanceMethod()) ~> ()
    ChildVerificationProxy.callTrivialInstanceMethod(on: child)
  }
  func testStubTrivialMethodOnProtocolMock() {
    given(self.childProtocol.childTrivialInstanceMethod()) ~> ()
    ChildVerificationProxy.callTrivialInstanceMethod(on: childProtocol)
  }
  
  func testStubParameterizedMethodOnClassMockWithAny() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(ChildVerificationProxy.callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethodOnProtocolMockWithAny() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(ChildVerificationProxy.callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubParameterizedMethodOnClassMockStubPrecedence() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(ChildVerificationProxy.callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethodOnProtocolMockStubPrecedence() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(ChildVerificationProxy.callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubParameterizedMethodOnClassMockLaterNonMatchingStubIsIgnored() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.child.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(ChildVerificationProxy.callParameterizedInstanceMethod(on: child))
  }
  func testStubParameterizedMethodOnProtocolMockLaterNonMatchingStubIsIgnored() {
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(ChildVerificationProxy.callParameterizedInstanceMethod(on: childProtocol))
  }
  
  func testStubMultipleInvocationsOnClassMockWithSameReturnType() {
    given(
      self.child.getChildComputedInstanceVariable(),
      self.child.getParentComputedInstanceVariable()
    ) ~> true
    XCTAssertTrue(ChildVerificationProxy.getChildComputedInstanceVariable(on: child))
    XCTAssertTrue(ChildVerificationProxy.getParentComputedInstanceVariable(on: child))
  }
  func testStubMultipleInvocationsOnProtocolMockWithSameReturnType() {
    given(
      self.childProtocol.getChildInstanceVariable(),
      self.childProtocol.getParentInstanceVariable()
    ) ~> true
    XCTAssertTrue(ChildVerificationProxy.getChildInstanceVariable(on: childProtocol))
    XCTAssertTrue(ChildVerificationProxy.getParentInstanceVariable(on: childProtocol))
  }
}
