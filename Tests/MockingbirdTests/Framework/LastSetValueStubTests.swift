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
  var concreteChild: ChildProtocol!
  
  override func setUp() {
    child = MockingbirdTests.mock(ChildProtocol.self)
    concreteChild = child as ChildProtocol
  }
  
  func testLastSetValueStub_returnsInitialValue() {
    given(child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    XCTAssertFalse(concreteChild.childInstanceVariable)
  }
  
  func testLastSetValueStub_returnsInitialValue_explicitSyntax() {
    given(child.getChildInstanceVariable()).willReturn(lastSetValue(initial: false))
    XCTAssertFalse(concreteChild.childInstanceVariable)
  }
  
  func testLastSetValueStub_returnsLastSetValue() {
    given(child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    concreteChild.childInstanceVariable = true
    XCTAssertTrue(concreteChild.childInstanceVariable)
  }
  
  func testLastSetValueStub_returnsLastSetValue_explicitSyntax() {
    given(child.getChildInstanceVariable()).willReturn(lastSetValue(initial: false))
    concreteChild.childInstanceVariable = true
    XCTAssertTrue(concreteChild.childInstanceVariable)
  }
  
  func testLastSetValueStub_settingValueOverridesLastSetValue() {
    given(child.getChildInstanceVariable()) ~> lastSetValue(initial: false)
    concreteChild.childInstanceVariable = true
    concreteChild.childInstanceVariable = false
    XCTAssertFalse(concreteChild.childInstanceVariable)
  }
  
  func testLastSetValueStub_settingValueOverridesLastSetValue_explicitSyntax() {
    given(child.getChildInstanceVariable()).willReturn(lastSetValue(initial: false))
    concreteChild.childInstanceVariable = true
    concreteChild.childInstanceVariable = false
    XCTAssertFalse(concreteChild.childInstanceVariable)
  }
}
