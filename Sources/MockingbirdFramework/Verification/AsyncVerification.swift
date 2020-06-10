//
//  AsyncVerification.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 3/8/20.
//

import Foundation
import XCTest

/// Create a deferrable test expectation from a block containing verification calls.
///
/// Mocked methods that are invoked asynchronously can be verified using an `eventually` block which
/// returns an `XCTestExpectation`.
///
///     DispatchQueue.main.async {
///       Tree(with: bird).shake()
///     }
///
///     let expectation =
///       eventually {
///         verify(bird.fly()).wasCalled()
///         verify(bird.chirp()).wasCalled()
///       }
///
///     wait(for: [expectation], timeout: 1.0)
///
/// - Parameters:
///   - description: An optional description for the created `XCTestExpectation`.
///   - block: A block containing verification calls.
/// - Returns: An XCTestExpectation that fulfilles once all verifications in the block are met.
public func eventually(_ description: String? = nil,
                       _ block: () -> Void) -> XCTestExpectation {
  return createAsyncContext(description: description, block: block)
}

/// Internal helper for `eventually` async verification scopes.
///   1. Creates an attributed `DispatchQueue` scope which collects all verifications.
///   2. Observes invocations on each mock and fulfills the test expectation if there is a match.
func createAsyncContext(description: String?, block scope: () -> Void) -> XCTestExpectation {
  let testExpectation = XCTestExpectation(description: description ?? "Async verification group")
  let group = ExpectationGroup { group in
    
    testExpectation.expectedFulfillmentCount = group.expectations.count + group.subgroups.count
    
    group.expectations.forEach({ capturedExpectation in
      let observer = InvocationObserver({ (invocation, mockingContext) -> Bool in
        do {
          try expect(mockingContext,
                     handled: capturedExpectation.invocation,
                     using: capturedExpectation.expectation)
          testExpectation.fulfill()
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
          testExpectation.fulfill()
          return true
        } catch {
          return false
        }
      })
      subgroup.expectations.forEach({ $0.mockingContext.addObserver(observer) })
    })
  }
  
  let queue = DispatchQueue(label: "co.bird.mockingbird.async-verification-scope")
  queue.setSpecific(key: ExpectationGroup.contextKey, value: group)
  queue.sync { scope() }
  
  try? group.verify()
  
  return testExpectation
}
