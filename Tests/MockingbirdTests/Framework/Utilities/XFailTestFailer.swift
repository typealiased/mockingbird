import Foundation
import Mockingbird
import XCTest

class XFailTestFailer: TestFailer {
  private var failures = [String]()
  private let testCase: XCTestCase
  private let sourceLocation: XCTSourceCodeLocation
  
  enum Constants {
    static let threadSemaphoreKey = "kMKBXFailTestSemaphoreKey"
  }
  
  init(testCase: XCTestCase, file: String = #file, line: Int = #line) {
    self.testCase = testCase
    self.sourceLocation = XCTSourceCodeLocation(filePath: file, lineNumber: line)
  }
  
  func fail(message: String, isFatal: Bool, file: StaticString, line: UInt) {
    failures.append(message)
    
    guard let semaphore =
      Thread.current.threadDictionary[Constants.threadSemaphoreKey] as? DispatchSemaphore
    else {
      // Not on a XFAIL testing thread, fail the test normally.
      XCTFail(message, file: file, line: line)
      return
    }
    
    semaphore.signal()
    if isFatal { Thread.exit() }
  }
  
  func verify(expectedFailures: Int = 1) {
    guard failures.count != expectedFailures else { return }
    
    let expectedFailuresDescription = "\(expectedFailures) failure\(expectedFailures == 1 ? "" : "s")"
    let allFailures = failures.isEmpty ? "   No failures recorded" :
      failures.enumerated()
        .map({ (offset: Int, element: String) in
          return "(\(offset+1)) =========\n\(element)"
        })
        .joined(separator: "\n\n")
    
    let compactDescription = "Expected \(expectedFailuresDescription) but got \(failures.count)"
    let detailedDescription = """
    \(compactDescription)
    
    All failures:
    \(allFailures)
    """
    
    let issue = XCTIssue(type: .assertionFailure,
                         compactDescription: compactDescription,
                         detailedDescription: detailedDescription,
                         sourceCodeContext: XCTSourceCodeContext(location: sourceLocation))
    testCase.record(issue)
  }
}
