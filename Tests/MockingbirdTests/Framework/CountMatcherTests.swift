//
//  CountMatcherTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/2/20.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

// TODO: Create XFAIL equivalent for XCTestCase to test expected verification failures.
class CountMatcherTests: XCTestCase {
  
  var child: ChildProtocolMock!
  
  override func setUp() {
    child = mock(ChildProtocol.self)
  }
  
  // MARK: - Adverbial counts
  
  // MARK: Exact
  
  func testAdverbialCount_exactlyNever() {
    verify(child.childTrivialInstanceMethod()).wasCalled(never)
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(never))
    verify(child.childTrivialInstanceMethod()).wasNeverCalled()
  }
  
  func testAdverbialCount_exactlyOnce() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(once)
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(once))
  }
  
  func testAdverbialCount_exactlyTwice() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(twice)
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(twice))
  }
  
  // MARK: Inequality
  
  func testAdverbialCount_atMostOnce() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atMost(once))
  }
  
  func testAdverbialCount_atLeastOnce() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(once))
  }
  
  func testAdverbialCount_atMostTwice() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atMost(twice))
  }
  
  func testAdverbialCount_atLeastTwice() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(twice))
  }
  
  // MARK: - Exact count matcher
  
  func testExactCountMatcher() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(3))
  }
  
  func testExactCountMatcher_convenience() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(3)
  }
  
  // MARK: - Inequality count matcher
  
  func testInequalityCountMatcher_atLeast_atThreshold() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(3))
  }
  
  func testInequalityCountMatcher_atLeast_aboveThreshold() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(3))
  }
  
  func testInequalityCountMatcher_atMost_atThreshold() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atMost(3))
  }
  
  func testInequalityCountMatcher_atMost_belowThreshold() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(atMost(3))
  }
  
  // MARK: - Composition
  
  func testCountMatcherComposition_orOperator() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(once).or(exactly(twice)))
    
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(once).or(exactly(twice)))
  }
  
  func testCountMatcherComposition_andOperator() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(exactly(once).and(atMost(twice)))
  }
  
  func testCountMatcherComposition_notOperator() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(not(exactly(once)))
  }
  
  func testCountMatcherComposition_notOperatorWithAndOperator() {
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled(not(exactly(once).and(atMost(twice))))
  }
}
