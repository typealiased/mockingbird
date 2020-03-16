//
//  AsyncVerificationTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/13/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class AsyncVerificationTests: XCTestCase {
  
  var child: ChildMock!
  var queue: DispatchQueue!
  
  override func setUp() {
    child = mock(Child.self)
    queue = DispatchQueue(label: "co.bird.mockingbird.tests")
  }
  
  enum Constants {
    static let asyncTestTimeout: TimeInterval = 1.0
  }
  
  func callTrivialInstanceMethod(on child: Child, times: UInt = 1) {
    for _ in 0..<times { child.childTrivialInstanceMethod() }
  }
  
  func callParameterizedInstanceMethod(on child: Child, times: UInt = 1) {
    for _ in 0..<times { _ = child.childParameterizedInstanceMethod(param1: true, 1) }
  }
  
  func testAsyncVerification_receivesTrivialInvocationOnce() {
    let expectation = eventually("childTrivialInstanceMethod() is called") {
      verify(child.childTrivialInstanceMethod()).wasCalled()
    }
    queue.async {
      self.callTrivialInstanceMethod(on: self.child)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_receivesTrivialInvocationTwice() {
    let expectation = eventually("childTrivialInstanceMethod() is called twice") {
      verify(child.childTrivialInstanceMethod()).wasCalled(exactly(2))
    }
    queue.async {
      self.callTrivialInstanceMethod(on: self.child, times: 2)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_receivesParameterizedInvocationOnce() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called once") {
      verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    }
    queue.async {
      self.callParameterizedInstanceMethod(on: self.child)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_receivesParameterizedInvocationTwice() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called twice") {
      verify(child.childParameterizedInstanceMethod(param1: any(), any()))
        .wasCalled(exactly(2))
    }
    queue.async {
      self.callParameterizedInstanceMethod(on: self.child, times: 2)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_withSynchronousInvocations() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called twice") {
      verify(child.childParameterizedInstanceMethod(param1: any(), any()))
        .wasCalled(exactly(2))
    }
    callParameterizedInstanceMethod(on: self.child, times: 2)
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_receivesPastInvocations() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    callParameterizedInstanceMethod(on: self.child, times: 2)
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called twice") {
      verify(child.childParameterizedInstanceMethod(param1: any(), any()))
        .wasCalled(exactly(2))
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  
  // MARK: - Ordered verification compatibility
  
  func testAsyncVerification_handlesNestedInOrderVerifications() {
    let expectation = eventually {
      inOrder {
        verify(child.childTrivialInstanceMethod()).wasCalled()
        verify(child.parentTrivialInstanceMethod()).wasCalled()
        verify(child.grandparentTrivialInstanceMethod()).wasCalled()
      }
    }
    
    queue.async {
      (self.child as Child).childTrivialInstanceMethod()
      (self.child as Child).parentTrivialInstanceMethod()
      (self.child as Child).grandparentTrivialInstanceMethod()
    }
    
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_handlesNestedInOrderVerifications_withSynchronousInvocations() {
    let expectation = eventually {
      inOrder {
        verify(child.childTrivialInstanceMethod()).wasCalled()
        verify(child.parentTrivialInstanceMethod()).wasCalled()
        verify(child.grandparentTrivialInstanceMethod()).wasCalled()
      }
    }
    
    (self.child as Child).childTrivialInstanceMethod()
    (self.child as Child).parentTrivialInstanceMethod()
    (self.child as Child).grandparentTrivialInstanceMethod()
    
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerification_handlesNestedInOrderVerifications_receivesPastInvocations() {
    (self.child as Child).childTrivialInstanceMethod()
    (self.child as Child).parentTrivialInstanceMethod()
    (self.child as Child).grandparentTrivialInstanceMethod()
    
    let expectation = eventually {
      inOrder {
        verify(child.childTrivialInstanceMethod()).wasCalled()
        verify(child.parentTrivialInstanceMethod()).wasCalled()
        verify(child.grandparentTrivialInstanceMethod()).wasCalled()
      }
    }

    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
}
