//
//  XFailOrderedVerificationTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 3/12/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class XFailOrderedVerificationTests: BaseTestCase {
  
  var child: ChildMock!
  
  override func setUp() {
    child = mock(Child.self)
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
  }
  
  // MARK: - Relative ordering
  
  func testRelativeOrderVerification_trivialComparison() {
    let child: ChildMock = self.child
    shouldFail {
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      (child as Child).childTrivialInstanceMethod()
      
      inOrder {
        verify(child.childTrivialInstanceMethod()).wasCalled()
        verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      }
    }
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingBefore() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingBetween() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_trivialComparisonWithPaddingAfter() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_multipleSameInvocationsBefore() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_multipleSameInvocationsAfter() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_handlesExactCountMatcher() {
    let child: ChildMock = self.child
    shouldFail {
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      (child as Child).childTrivialInstanceMethod()
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      
      inOrder {
        verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
        verify(child.childTrivialInstanceMethod()).wasCalled(twice)
        verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      }
    }
  }
  
  func testRelativeOrderVerification_handlesAtLeastCountMatcher() {
    let child: ChildMock = self.child
    shouldFail {
      (child as Child).childTrivialInstanceMethod()
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      
      inOrder {
        verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(twice))
        verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      }
    }
  }
  
  func testRelativeOrderVerification_handlesAtLeastCountMatcher_validPaddingBefore() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_handlesAtLeastCountMatcher_validPaddingBetween() {
    let child: ChildMock = self.child
    shouldFail {
      (child as Child).childTrivialInstanceMethod()
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      (child as Child).childTrivialInstanceMethod()
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      
      inOrder {
        verify(child.childTrivialInstanceMethod()).wasCalled(atLeast(twice))
        verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      }
    }
  }
  
  func testRelativeOrderVerification_handlesAtMostCountMatcher() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testRelativeOrderVerification_handlesAtMostCountMatcher_validPaddingBefore() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  
  // MARK: - Only consecutive invocations
  
  func testOnlyConsecutiveInvocations_paddingBetween() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  
  // MARK: - No invocations before
  
  func testNoInvocationsBefore_arbitraryPaddingBefore() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testNoInvocationsBefore_validPaddingBefore() {
    let child: ChildMock = self.child
    shouldFail {
    // Padding
      (child as Child).childTrivialInstanceMethod()
      
      (child as Child).childTrivialInstanceMethod()
      XCTAssertTrue((child as Child).childParameterizedInstanceMethod(param1: true, 42))
      
      inOrder(with: .noInvocationsBefore) {
        verify(child.childTrivialInstanceMethod()).wasCalled()
        verify(child.childParameterizedInstanceMethod(param1: true, 42)).wasCalled()
      }
    }
  }
  
  
  // MARK: - No invocations after
  
  func testNoInvocationsBefore_arbitraryPaddingAfter() {
    let child: ChildMock = self.child
    shouldFail {
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
  }
  
  func testNoInvocationsBefore_validPaddingAfter() {
    let child: ChildMock = self.child
    shouldFail {
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
}
