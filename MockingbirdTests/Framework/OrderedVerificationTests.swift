//
//  OrderedVerificationTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/9/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class OrderedVerificationTests: XCTestCase {
  
  var child: ChildMock!
  
  override func setUp() {
    child = mock(Child.self)
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
  }
  
  // MARK: - Relative ordering
  
  func testRelativeOrderVerification_trivialComparison() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingBefore() {
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingBetween() {
    (child as Child).childTrivialInstanceMethod()
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingAfter() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
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
    (child as Child).childTrivialInstanceMethod()
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
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled(atMost(twice))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testRelativeOrderVerification_handlesCompoundCountMatcher() {
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder {
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      verify(child.childTrivialInstanceMethod()).wasCalled(not(once).and(not(twice)))
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  
  // MARK: - Only consecutive invocations
  
  func testOnlyConsecutiveInvocations() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder(with: .onlyConsecutiveInvocations) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testOnlyConsecutiveInvocations_paddingBefore() {
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    inOrder(with: .onlyConsecutiveInvocations) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
  
  func testOnlyConsecutiveInvocations_paddingAfter() {
    (child as Child).childTrivialInstanceMethod()
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
    
    // Padding
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: false, 1337))
    
    inOrder(with: .onlyConsecutiveInvocations) {
      verify(child.childTrivialInstanceMethod()).wasCalled()
      verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
    }
  }
}
