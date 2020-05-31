//
//  OrderedVerification.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 3/8/20.
//

import Foundation
import XCTest

/// Enforce the relative order of invocations.
///
/// Calls to `verify` within the scope of an `inOrder` verification block are checked relative to
/// each other.
///
///     // Verify that `fly` was called before `chirp`
///     inOrder {
///       verify(bird.fly()).wasCalled()
///       verify(bird.chirp()).wasCalled()
///     }
///
/// Pass options to `inOrder` verification blocks for stricter checks with additional invariants.
///
///     inOrder(with: .noInvocationsAfter) {
///       verify(bird.fly()).wasCalled()
///       verify(bird.chirp()).wasCalled()
///     }
///
/// An `inOrder` block is resolved greedily, such that each verification must happen from the oldest
/// remaining unsatisfied invocations.
///
///     // Given these unsatisfied invocations
///     bird.fly()
///     bird.fly()
///     bird.chirp()
///
///     // Greedy strategy _must_ start from the first `fly`
///     inOrder {
///       verify(bird.fly()).wasCalled(twice)
///       verify(bird.chirp()).wasCalled()
///     }
///
///     // Non-greedy strategy can start from the second `fly`
///     inOrder {
///       verify(bird.fly()).wasCalled()
///       verify(bird.chirp()).wasCalled()
///     }
///
/// - Parameters:
///   - options: Options to use when verifying invocations.
///   - block: A block containing ordered verification calls.
public func inOrder(with options: OrderedVerificationOptions = [],
                    file: StaticString = #file, line: UInt = #line,
                    _ block: () -> Void) {
  createOrderedContext(at: SourceLocation(file, line), options: options, block: block)
}

/// Additional options to increase the strictness of `inOrder` verification blocks.
public struct OrderedVerificationOptions: OptionSet {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  /// Check that there are no recorded invocations before those explicitly verified in the block.
  ///
  /// Use this option to disallow invocations prior to those satisfying the first verification.
  ///
  ///     bird.eat()
  ///     bird.fly()
  ///     bird.chirp()
  ///
  ///     // Passes _without_ the option
  ///     inOrder {
  ///       verify(bird.fly()).wasCalled()
  ///       verify(bird.chirp()).wasCalled()
  ///     }
  ///
  ///     // Fails with the option
  ///     inOrder(with: .noInvocationsBefore) {
  ///       verify(bird.fly()).wasCalled()
  ///       verify(bird.chirp()).wasCalled()
  ///     }
  public static let noInvocationsBefore = OrderedVerificationOptions(rawValue: 1 << 0)
  
  /// Check that there are no recorded invocations after those explicitly verified in the block.
  ///
  /// Use this option to disallow subsequent invocations to those satisfying the last verification.
  ///
  ///     bird.fly()
  ///     bird.chirp()
  ///     bird.eat()
  ///
  ///     // Passes _without_ the option
  ///     inOrder {
  ///       verify(bird.fly()).wasCalled()
  ///       verify(bird.chirp()).wasCalled()
  ///     }
  ///
  ///     // Fails with the option
  ///     inOrder(with: .noInvocationsAfter) {
  ///       verify(bird.fly()).wasCalled()
  ///       verify(bird.chirp()).wasCalled()
  ///     }
  public static let noInvocationsAfter = OrderedVerificationOptions(rawValue: 1 << 1)
  
  /// Check that there are no recorded invocations between those explicitly verified in the block.
  ///
  /// Use this option to disallow non-consecutive invocations to each verification.
  ///
  ///     bird.fly()
  ///     bird.eat()
  ///     bird.chirp()
  ///
  ///     // Passes _without_ the option
  ///     inOrder {
  ///       verify(bird.fly()).wasCalled()
  ///       verify(bird.chirp()).wasCalled()
  ///     }
  ///
  ///     // Fails with the option
  ///     inOrder(with: .noInvocationsAfter) {
  ///       verify(bird.fly()).wasCalled()
  ///       verify(bird.chirp()).wasCalled()
  ///     }
  public static let onlyConsecutiveInvocations = OrderedVerificationOptions(rawValue: 1 << 2)
}

private func getAllInvocations(in contexts: [UUID: MockingContext],
                               after baseInvocation: Invocation?) -> [Invocation] {
  return contexts.values
    .flatMap({ $0.allInvocations.value })
    .filter({
      guard let baseInvocation = baseInvocation else { return true }
      return $0 > baseInvocation
    })
    .sorted(by: <)
}

private func assertNoInvocationsBefore(_ capturedExpectation: CapturedExpectation,
                                       baseInvocation: Invocation?,
                                       contexts: [UUID: MockingContext]) throws {
  let allInvocations = getAllInvocations(in: contexts, after: baseInvocation)
  
  // Failure if the first invocation in all contexts doesn't match the first expectation.
  if let firstInvocation = allInvocations.first, firstInvocation != capturedExpectation.invocation {
    let endIndex = allInvocations.firstIndex(where: { $0 == capturedExpectation.invocation })
      ?? allInvocations.endIndex
    let unexpectedInvocations = Array(allInvocations[allInvocations.startIndex..<endIndex])
    
    let failure = TestFailure.unexpectedInvocations(
      baseInvocation: capturedExpectation.invocation,
      unexpectedInvocations: unexpectedInvocations,
      priorToBase: true
    )
    throw ExpectationGroup.Failure(error: failure,
                                   sourceLocation: capturedExpectation.expectation.sourceLocation)
  }
}

private func assertNoInvocationsAfter(_ capturedExpectation: CapturedExpectation,
                                      baseInvocation: Invocation?,
                                      contexts: [UUID: MockingContext]) throws {
  let allInvocations = getAllInvocations(in: contexts, after: baseInvocation)
  guard !allInvocations.isEmpty else { return }
  
  let failure = TestFailure.unexpectedInvocations(
    baseInvocation: capturedExpectation.invocation,
    unexpectedInvocations: allInvocations,
    priorToBase: false
  )
  throw ExpectationGroup.Failure(error: failure,
                                 sourceLocation: capturedExpectation.expectation.sourceLocation)
}

private struct Solution {
  let firstInvocation: Invocation?
  let lastInvocation: Invocation?
  
  enum Failure: Error {
    case unsatisfiable
  }
}

private func satisfy(_ capturedExpectations: [CapturedExpectation],
                     at index: Int = 0,
                     baseInvocation: Invocation? = nil,
                     contexts: [UUID: MockingContext],
                     options: OrderedVerificationOptions) throws -> Solution {
  let capturedExpectation = capturedExpectations[index]
  let allInvocations = findInvocations(in: capturedExpectation.mockingContext,
                                       with: capturedExpectation.invocation.selectorName,
                                       before: nil,
                                       after: baseInvocation)
  var nextInvocationIndex = 1
  
  while true {
    if options.contains(.onlyConsecutiveInvocations), baseInvocation != nil {
      try assertNoInvocationsBefore(capturedExpectation,
                                    baseInvocation: baseInvocation,
                                    contexts: contexts)
    }

    do {
      // Try to satisfy the current expectations.
      let allInvocations = try expect(capturedExpectation.mockingContext,
                                      handled: capturedExpectation.invocation,
                                      using: capturedExpectation.expectation,
                                      before: allInvocations.get(nextInvocationIndex),
                                      after: baseInvocation)
      guard index+1 < capturedExpectations.count else { // Found a solution!
        return Solution(firstInvocation: allInvocations.first, lastInvocation: allInvocations.last)
      }
      
      // Potential match with the current base invocation, try satisfying the next expectation.
      let allMatchingInvocations = allInvocations.filter({ $0 == capturedExpectation.invocation })
      let result = try satisfy(capturedExpectations,
                               at: index+1,
                               baseInvocation: allMatchingInvocations.first,
                               contexts: contexts,
                               options: options)
      
      // Check if still satisfiable when using the next invocation as a constraint.
      if let nextBaseInvocation = result.firstInvocation {
        try expect(capturedExpectation.mockingContext,
                   handled: capturedExpectation.invocation,
                   using: capturedExpectation.expectation,
                   before: nextBaseInvocation,
                   after: baseInvocation)
      }
      
      return Solution(firstInvocation: allInvocations.first, lastInvocation: result.lastInvocation)
    } catch let error as ExpectationGroup.Failure { // Propagate the precondition failure.
      throw error
    } catch { // Unable to satisfy the current expectation.
      guard nextInvocationIndex+1 <= allInvocations.count else {
        throw Solution.Failure.unsatisfiable // Unable to grow the window further.
      }
      nextInvocationIndex += 1 // Grow the invocation window.
    }
  }
}

/// Internal helper for `inOrder` verification scopes.
///   1. Creates an attributed `DispatchQueue` scope which collects all verifications.
///   2. Checks invocations on each mock using the provided `options`.
func createOrderedContext(at sourceLocation: SourceLocation,
                          options: OrderedVerificationOptions,
                          block scope: () -> Void) {
  let group = ExpectationGroup { group in
    let contexts = group.expectations.reduce(into: [UUID: MockingContext]()) {
      (result, expectation) in
      result[expectation.mockingContext.identifier] = expectation.mockingContext
    }
    
    // Check for invocations prior to the first expectation's invocation(s).
    if options.contains(.noInvocationsBefore), let firstExpectation = group.expectations.first {
      try assertNoInvocationsBefore(firstExpectation, baseInvocation: nil, contexts: contexts)
    }
    
    do {
      let result = try satisfy(group.expectations, contexts: contexts, options: options)
      
      // Check for invocations after the last expectation's invocation(s).
      if options.contains(.noInvocationsAfter), let lastExpectation = group.expectations.last {
        try assertNoInvocationsAfter(lastExpectation,
                                     baseInvocation: result.lastInvocation,
                                     contexts: contexts)
      }
    } catch let error as ExpectationGroup.Failure {
      throw error // Propagate wrapped precondition error.
    } catch _ as Solution.Failure {
      // It's difficult to clearly determine which expectation is breaking the group, so instead
      // just throw an error at the group level instead.
      let allInvocations = getAllInvocations(in: contexts, after: nil)
      let failure = TestFailure.unsatisfiableExpectations(capturedExpectations: group.expectations,
                                                          allInvocations: allInvocations)
      throw ExpectationGroup.Failure(error: failure, sourceLocation: sourceLocation)
    } catch {
      fatalError("Unexpected error type") // This shouldn't happen.
    }
  }
  
  let queue = DispatchQueue(label: "co.bird.mockingbird.ordered-verification-scope")
  queue.setSpecific(key: ExpectationGroup.contextKey, value: group)
  queue.sync { scope() }
  
  do {
    try group.verify()
  } catch let error as ExpectationGroup.Failure {
    MKBFail(String(describing: error),
            file: error.sourceLocation.file,
            line: error.sourceLocation.line)
  } catch {
    fatalError("Unexpected error type") // This shouldn't happen.
  }
}
