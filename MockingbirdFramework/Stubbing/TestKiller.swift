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
  
  private var testCase: XCTestCase?
  func testCase(_ testCase: XCTestCase,
                didFailWithDescription description: String,
                inFile filePath: String?,
                atLine lineNumber: Int) {
    // TODO: This doesn't synchronously stop the current test case on failure if the invocation
    // happens from outside of the main thread. Dispatching to main doesn't solve the issue.
    testCase.continueAfterFailure = false
    self.testCase = testCase
  }
  
  func failTest(_ error: TestFailure, at sourceLocation: SourceLocation? = nil) {
    failTest("\(error)", at: sourceLocation)
  }
  
  func failTest(_ message: String, at sourceLocation: SourceLocation? = nil) {
    if let sourceLocation = sourceLocation {
      MKBFail(message, file: sourceLocation.file, line: sourceLocation.line)
    } else {
      MKBFail(message)
    }
    
    // `XCTest` execution should already be "gracefully" stopped by this point, EXCEPT that
    // Nimble doesn't respect the `XCTestCase.continueAfterFailure` flag and has no built-in
    // support for anything similar <https://github.com/Quick/Quick/issues/249>. The hacky
    // workaround is to force an assertion failure within `xctest` by calling `stop()`
    // multiple times on the current test run.
    testCase?.testRun?.stop()
    testCase?.testRun?.stop()
  }
}
