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
    if Thread.isMainThread {
      XCTestObservationCenter.shared.addTestObserver(self)
    } else {
      DispatchQueue.main.sync { XCTestObservationCenter.shared.addTestObserver(self) }
    }
  }
  
  private(set) var testCase: XCTestCase?
  func testCase(_ testCase: XCTestCase,
                didFailWithDescription description: String,
                inFile filePath: String?,
                atLine lineNumber: Int) {
    // TODO: This doesn't synchronously stop the current test case on failure if the invocation
    // happens from outside of the main thread. Dispatching to main doesn't solve the issue.
    testCase.continueAfterFailure = false
    self.testCase = testCase
  }
}
