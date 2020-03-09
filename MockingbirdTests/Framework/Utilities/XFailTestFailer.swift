//
//  XFailTestFailer.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/11/20.
//

import Foundation
import Mockingbird
import XCTest

class XFailTestFailer: TestFailer {
  private var failures = [String]()
  
  private let sourceLocation: (file: String, line: Int)
  private let testCase: XCTestCase
  
  init(file: String = #file, line: Int = #line, testCase: XCTestCase) {
    self.sourceLocation = (file, line)
    self.testCase = testCase
  }
  
  func fail(message: String, file: StaticString, line: UInt) {
    failures.append(message)
  }
  
  func verify(expectedFailures: Int?) {
    guard failures.count != (expectedFailures ?? failures.count) else { return }
    let expectedFailuresDescription: String
    if let expectedFailures = expectedFailures {
      expectedFailuresDescription = "\(expectedFailures) failure\(expectedFailures == 1 ? "" : "s")"
    } else {
      expectedFailuresDescription = "at least 1 failure"
    }
    
    let allFailures = failures.isEmpty ? "   No failures recorded" :
      failures.enumerated()
        .map({ (offset: Int, element: String) in
          return "(\(offset+1)) =========\n\(element)"
        })
        .joined(separator: "\n\n")
    
    let description = """
    Expected \(expectedFailuresDescription) but got \(failures.count)
    
    All failures:
    \(allFailures)
    """
    
    testCase.recordFailure(withDescription: description,
                           inFile: sourceLocation.file,
                           atLine: sourceLocation.line,
                           expected: true)
  }
}
