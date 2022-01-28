import Foundation
import XCTest

public extension NSObject {
  /// Waits for the test to satisfy an array of expectations.
  ///
  /// - Parameters:
  ///   - expectations: An array of expectations that must be fulfilled.
  ///   - seconds: The number of seconds within which all expectations must be fulfilled.
  ///   - enforceOrderOfFulfillment: If `true`, the expectations specified by the expectations
  ///   parameter must be satisfied in the order they appear in the array.
  func wait(for expectations: [TestExpectation],
            timeout seconds: TimeInterval,
            enforceOrder enforceOrderOfFulfillment: Bool = false) {
    guard let testCase = self as? XCTestCase else {
      fatalError("Should never be called outside of a test case")
    }
    testCase.wait(for: expectations.map({ $0 as XCTestExpectation }),
                  timeout: seconds,
                  enforceOrder: enforceOrderOfFulfillment)
  }

  /// Create a deferrable test expectation from a block containing verification calls.
  ///
  /// Mocked methods that are invoked asynchronously can be verified using an `eventually` block
  /// which creates an `XCTestExpectation` and attaches it to the current `XCTestCase`.
  ///
  /// ```swift
  /// DispatchQueue.main.async {
  ///   Tree(with: bird).shake()
  /// }
  ///
  /// eventually {
  ///   verify(bird.fly()).wasCalled()
  ///   verify(bird.chirp()).wasCalled()
  /// }
  ///
  /// waitForExpectations(timeout: 1)
  /// ```
  ///
  /// - Parameters:
  ///   - description: An optional description for the test expectation.
  ///   - block: A block containing verification calls.
  /// - Returns: An XCTestExpectation that fulfilles once all verifications in the block are met.
  @discardableResult
  func eventually(_ description: String = "Async verification group",
                  _ block: () -> Void) -> TestExpectation {
    let expectation: XCTestExpectation = {
      guard let testCase = self as? XCTestCase else {
        return XCTestExpectation(description: description)
      }
      return testCase.expectation(description: description)
    }()
    createAsyncContext(expectation: expectation, block: block)
    return TestExpectation.create(from: expectation)
  }
}

/// Internal helper for `eventually` async verification scopes.
///   1. Creates an attributed `DispatchQueue` scope which collects all verifications.
///   2. Observes invocations on each mock and fulfills the test expectation if there is a match.
func createAsyncContext(expectation: XCTestExpectation, block scope: () -> Void) {
  let group = ExpectationGroup { group in
    expectation.expectedFulfillmentCount = group.countExpectations()
    print(expectation.expectedFulfillmentCount)
    print("asdasfdasfd")
    group.expectations.forEach({ capturedExpectation in
      let observer = InvocationObserver({ (invocation, mockingContext) -> Bool in
        do {
          try expect(mockingContext,
                     handled: capturedExpectation.invocation,
                     using: capturedExpectation.expectation)
          expectation.fulfill()
          return true
        } catch {
          return false
        }
      })
      capturedExpectation.mockingContext
        .addObserver(observer, for: capturedExpectation.invocation.selectorName)
    })

    group.subgroups.forEach({ subgroup in
      let observer = InvocationObserver({ (invocation, mockingContext) -> Bool in
        do {
          try subgroup.verify()
          expectation.fulfill()
          return true
        } catch {
          return false
        }
      })
      subgroup.expectations.forEach({ $0.mockingContext.addObserver(observer) })
    })
  }

  let queue = DispatchQueue(label: "co.bird.mockingbird.verify.eventually")
  queue.setSpecific(key: ExpectationGroup.contextKey, value: group)
  queue.sync { scope() }

  try? group.verify()
}
