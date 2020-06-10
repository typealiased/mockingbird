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
    child = MockingbirdTests.mock(ChildProtocol.self)
  }
  
  func getInstanceVariable(for child: ChildProtocol) -> Bool {
    return child.childInstanceVariable
  }
  
  func setInstanceVariable(for child: ChildProtocol, to value: Bool) {
    var childCopy = child
    childCopy.childInstanceVariable = value
  }
  
  func testLastSetValueStub_returnsInitialValue() {
    given(child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    XCTAssertFalse(getInstanceVariable(for: child))
  }
  
  func testLastSetValueStub_returnsInitialValue_explicitSyntax() {
    given(child.getChildInstanceVariable()).willReturn(lastSetValue(initial: false))
    XCTAssertFalse(getInstanceVariable(for: child))
  }
  
  func testLastSetValueStub_returnsLastSetValue() {
    given(child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    setInstanceVariable(for: child, to: true)
    XCTAssertTrue(getInstanceVariable(for: child))
  }
  
  func testLastSetValueStub_returnsLastSetValue_explicitSyntax() {
    given(child.getChildInstanceVariable()).willReturn(lastSetValue(initial: false))
    setInstanceVariable(for: child, to: true)
    XCTAssertTrue(getInstanceVariable(for: child))
  }
  
  func testLastSetValueStub_settingValueOverridesLastSetValue() {
    given(child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    setInstanceVariable(for: child, to: true)
    setInstanceVariable(for: child, to: false)
    XCTAssertFalse(getInstanceVariable(for: child))
  }
  
  func testLastSetValueStub_settingValueOverridesLastSetValue_explicitSyntax() {
    given(child.getChildInstanceVariable()).willReturn(lastSetValue(initial: false))
    setInstanceVariable(for: child, to: true)
    setInstanceVariable(for: child, to: false)
    XCTAssertFalse(getInstanceVariable(for: child))
  }
}
