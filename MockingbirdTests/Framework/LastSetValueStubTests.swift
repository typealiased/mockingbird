//
//  LastSetValueStubTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class LastSetValueStubTests: XCTestCase {
  
  var child: ChildProtocolMock!
  
  override func setUp() {
    child = ChildProtocolMock()
  }
  
  class ChildVerificationProxy {
    static func getInstanceVariable(for child: ChildProtocol) -> Bool {
      return child.childInstanceVariable
    }
    
    static func setInstanceVariable(for child: ChildProtocol, to value: Bool) {
      var childCopy = child
      childCopy.childInstanceVariable = value
    }
  }
  
  func testLastSetValueStubReturnsInitialValue() {
    given(self.child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    XCTAssertFalse(ChildVerificationProxy.getInstanceVariable(for: child))
  }
  
  func testLastSetValueStubReturnsLastSetValue() {
    given(self.child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    ChildVerificationProxy.setInstanceVariable(for: child, to: true)
    XCTAssertTrue(ChildVerificationProxy.getInstanceVariable(for: child))
  }
  
  func testSettingValueOverridesLastSetValue() {
    given(self.child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    ChildVerificationProxy.setInstanceVariable(for: child, to: true)
    ChildVerificationProxy.setInstanceVariable(for: child, to: false)
    XCTAssertFalse(ChildVerificationProxy.getInstanceVariable(for: child))
  }
}
