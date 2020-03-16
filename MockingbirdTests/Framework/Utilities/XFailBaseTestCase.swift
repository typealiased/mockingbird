//
//  XFailBaseTestCase.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/11/20.
//

import Foundation
import XCTest
import Mockingbird

class XFailBaseTestCase: XCTestCase {
  private var testFailer: XFailTestFailer!
  var expectedFailures: Int? = nil
  
  override func setUp() {
    super.setUp()
    testFailer = XFailTestFailer(testCase: self)
    swizzleTestFailer(testFailer)
  }

  override func tearDown() {
    testFailer.verify(expectedFailures: 1)
  }
}
