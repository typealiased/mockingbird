import Foundation
import XCTest

/// A type that can handle test failures emitted by Mockingbird.
public protocol TestFailer {
  /// Fail the current test case.
  ///
  /// - Parameters:
  ///   - message: A description of the failure.
  ///   - isFatal: If `true`, test case execution should not continue.
  ///   - file: The file where the failure occurred.
  ///   - line: The line in the file where the failure occurred.
  func fail(message: String, isFatal: Bool, file: StaticString, line: UInt)
}

/// Change the current global test failer.
///
/// - Parameter newTestFailer: A test failer instance to start handling test failures.
public func swizzleTestFailer(_ newTestFailer: TestFailer) {
  if Thread.isMainThread {
    testFailer = newTestFailer
  } else {
    DispatchQueue.main.sync { testFailer = newTestFailer }
  }
}

/// Called by Mockingbird on test assertion failures.
///
/// - Parameters:
///   - message: A description of the failure.
///   - isFatal: If `true`, test case execution should not continue.
///   - file: The file where the failure occurred.
///   - line: The line in the file where the failure occurred.
@discardableResult
func FailTest(_ message: String, isFatal: Bool = false,
              file: StaticString = #file, line: UInt = #line) -> String {
  testFailer.fail(message: message, isFatal: isFatal, file: file, line: line)
  return message
}

// MARK: - Internal

private class StandardTestFailer: TestFailer {
  func fail(message: String, isFatal: Bool, file: StaticString, line: UInt) {
    guard isFatal else {
      return XCTFail(message, file: file, line: line)
    }
    
    // Raise an Objective-C exception to stop the test runner.
    MKBStopTest(message)
    
    // Test execution should usually be stopped by this point.
    fatalError(message)
  }
}

private var testFailer: TestFailer = StandardTestFailer()
