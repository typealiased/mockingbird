//
//  XFailOrderedVerificationTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/12/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class XFailOrderedVerificationTests: XFailBaseTestCase {
  
  var child: ChildMock!
  
  override func setUp() {
    super.setUp()
    expectedFailures = 1
    
    child = mock(Child.self)
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
  }
  
  // MARK: - Relative ordering
  
  func testRelativeOrderVerification_trivialComparison() {
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingBefore() {
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingBetween() {
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    (child as Child).childTrivialInstanceMethod()
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingAfter() {
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_multipleSameInvocationsBefore() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_multipleSameInvocationsAfter() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesExactCountMatcher() {
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled(twice)
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesAtLeastCountMatcher() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(twice))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesAtLeastCountMatcher_validPaddingBefore() {
    // Padding
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(twice))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesAtLeastCountMatcher_validPaddingBetween() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(twice))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesAtMostCountMatcher() {
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled(atMost(twice))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesAtMostCountMatcher_validPaddingBefore() {
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled(atMost(twice))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  
  // MARK: - Only consecutive invocations
  
  func testOnlyConsecutiveInvocations_paddingBetween() {
    (child as Child).childTrivialInstanceMethod()
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder(with: .onlyConsecutiveInvocations) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  
  // MARK: - No invocations before
  
  func testNoInvocationsBefore_arbitraryPaddingBefore() {
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder(with: .noInvocationsBefore) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testNoInvocationsBefore_validPaddingBefore() {
    // Padding
    (child as Child).childTrivialInstanceMethod()
    
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder(with: .noInvocationsBefore) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  
  // MARK: - No invocations after
  
  func testNoInvocationsBefore_arbitraryPaddingAfter() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    inOrder(with: .noInvocationsAfter) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testNoInvocationsBefore_validPaddingAfter() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder(with: .noInvocationsAfter) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
}
