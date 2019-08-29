//
//  TestKiller.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 8/20/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import XCTest

/// Create a TestKiller instance prior to triggering an XCTFail to permanently fail the test.
class TestKiller: NSObject, XCTestObservation {
  override init() {
    super.init()
    XCTestObservationCenter.shared.addTestObserver(self)
  }
  
  private(set) var testCase: XCTestCase?
  func testCase(_ testCase: XCTestCase,
                didFailWithDescription description: String,
                inFile filePath: String?,
                atLine lineNumber: Int) {
    testCase.continueAfterFailure = false
    self.testCase = testCase
  }
}
