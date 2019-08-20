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
  
  override func setUp() {
    child = ChildMock()
  }
  
  enum Constants {
    static let asyncTestTimeout: TimeInterval = 1.0
  }
  
  /// Test harness.
  class ChildCaller {
    static func callTrivialInstanceMethod(on child: Child, times: UInt = 1) {
      for _ in 0..<times { child.childTrivialInstanceMethod() }
    }
    
    static func callParameterizedInstanceMethod(on child: Child, times: UInt = 1) {
      for _ in 0..<times { _ = child.childParameterizedInstanceMethod(param1: true, 1) }
    }
  }
  
  func testAsyncVerificationTrivialOnce() {
    let expectation = eventually("childTrivialInstanceMethod() is called") {
      verify(self.child.childTrivialInstanceMethod()).wasCalled()
    }
    let queue = DispatchQueue(label: "co.bird.mockingbird.tests")
    queue.async {
      ChildCaller.callTrivialInstanceMethod(on: self.child)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerificationTrivialTwice() {
    let expectation = eventually("childTrivialInstanceMethod() is called twice") {
      verify(self.child.childTrivialInstanceMethod()).wasCalled(exactly(2))
    }
    let queue = DispatchQueue(label: "co.bird.mockingbird.tests")
    queue.async {
      ChildCaller.callTrivialInstanceMethod(on: self.child, times: 2)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerificationParameterizedOnce() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called once") {
      verify(self.child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    }
    let queue = DispatchQueue(label: "co.bird.mockingbird.tests")
    queue.async {
      ChildCaller.callParameterizedInstanceMethod(on: self.child)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerificationParameterizedTwice() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called twice") {
      verify(self.child.childParameterizedInstanceMethod(param1: any(), any()))
        .wasCalled(exactly(2))
    }
    let queue = DispatchQueue(label: "co.bird.mockingbird.tests")
    queue.async {
      ChildCaller.callParameterizedInstanceMethod(on: self.child, times: 2)
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerificationOnSynchronousInvocations() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called twice") {
      verify(self.child.childParameterizedInstanceMethod(param1: any(), any()))
        .wasCalled(exactly(2))
    }
    ChildCaller.callParameterizedInstanceMethod(on: self.child, times: 2)
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
  
  func testAsyncVerificationReceivesPastInvocations() {
    given(self.child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    ChildCaller.callParameterizedInstanceMethod(on: self.child, times: 2)
    let expectation = eventually("childParameterizedInstanceMethod(param1:_:) is called twice") {
      verify(self.child.childParameterizedInstanceMethod(param1: any(), any()))
        .wasCalled(exactly(2))
    }
    wait(for: [expectation], timeout: Constants.asyncTestTimeout)
  }
}
