//
//  BaseTestCase.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/11/20.
//

import Foundation
import XCTest
import Mockingbird

class BaseTestCase: XCTestCase {
  
  func shouldFail(_ times: Int = 1,
                  file: String = #file, line: Int = #line,
                  _ context: @escaping () -> Void) {
    let testFailer = XFailTestFailer(testCase: self, file: file, line: line)
    swizzleTestFailer(testFailer)
    
    let semaphore = DispatchSemaphore(value: 0)
    Thread {
      Thread.current.threadDictionary[XFailTestFailer.Constants.threadSemaphoreKey] = semaphore
      context()
    }.start()
    
    mainLoop: for _ in 0..<times {
      switch semaphore.wait(timeout: .now() + 1.0) {
      case .success: break
      case .timedOut: break mainLoop
      }
    }
    testFailer.verify(expectedFailures: times)
  }
}
