//
//  StubbingTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

class StubbingTests: BaseTestCase {
  
  struct FakeError: Error {}
  
  var child: ChildMock!
  var childInstance: Child { return child }
  
  var childProtocol: ChildProtocolMock!
  var childProtocolInstance: ChildProtocol { return childProtocol }
  
  override func setUp() {
    child = mock(Child.self)
    childProtocol = mock(ChildProtocol.self)
  }
  
  func testStubTrivialMethod_onClassMock_implicitlyStubbed() {
    childInstance.childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  func testStubTrivialMethod_onProtocolMock_implicitlyStubbed() {
    childProtocolInstance.childTrivialInstanceMethod()
    verify(childProtocol.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testStubTrivialMethod_onClassMock() {
    given(child.childTrivialInstanceMethod()) ~> ()
    childInstance.childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  func testStubTrivialMethod_onProtocolMock() {
    given(childProtocol.childTrivialInstanceMethod()) ~> ()
    childProtocolInstance.childTrivialInstanceMethod()
    verify(childProtocol.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testStubTrivialMethod_onClassMock_explicitSyntax() {
    given(child.childTrivialInstanceMethod()).willReturn(())
    childInstance.childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  func testStubTrivialMethod_onProtocolMock_explicitSyntax() {
    given(childProtocol.childTrivialInstanceMethod()).willReturn(())
    childProtocolInstance.childTrivialInstanceMethod()
    verify(childProtocol.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testStubTrivialMethod_onClassMock_convenienceExplicitSyntax() {
    given(child.childTrivialInstanceMethod()).willReturn()
    childInstance.childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  func testStubTrivialMethod_onProtocolMock_convenienceExplicitSyntax() {
    given(childProtocol.childTrivialInstanceMethod()).willReturn()
    childProtocolInstance.childTrivialInstanceMethod()
    verify(childProtocol.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testStubParameterizedMethodWithWildcardMatcher_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodWithWildcardMatcher_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  func testStubParameterizedMethodWithWildcardMatcher_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodWithWildcardMatcher_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  func testStubParameterizedMethodWithExactValue_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: true, 1)) ~> true
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodWithExactValue_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: true, 1)) ~> true
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  func testStubParameterizedMethodWithExactValue_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: true, 1)).willReturn(true)
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodWithExactValue_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  // MARK: Non-matching
  
  func testStubParameterizedMethodWithWildcardMatcher_doesNotMatch_onClassMock() {
    shouldFail {
      given(self.child.childParameterizedInstanceMethod(param1: any(), 1)) ~> true
      XCTAssertTrue(self.childInstance.childParameterizedInstanceMethod(param1: true, 2))
    }
  }
  func testStubParameterizedMethodWithWildcardMatcher_doesNotMatch_onProtocolMock() {
    shouldFail {
      given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), 1)) ~> true
      XCTAssertTrue(self.childProtocolInstance.childParameterizedInstanceMethod(param1: true, 2))
    }
  }
  
  func testStubParameterizedMethodWithWildcardMatcher_doesNotMatch_onClassMock_explicitSyntax() {
    shouldFail {
      given(self.child.childParameterizedInstanceMethod(param1: any(), 1)).willReturn(true)
      XCTAssertTrue(self.childInstance.childParameterizedInstanceMethod(param1: true, 2))
    }
  }
  func testStubParameterizedMethodWithWildcardMatcher_doesNotMatch_onProtocolMock_explicitSyntax() {
    shouldFail {
      given(self.childProtocol.childParameterizedInstanceMethod(param1: any(), 1)).willReturn(true)
      XCTAssertTrue(self.childProtocolInstance.childParameterizedInstanceMethod(param1: true, 2))
    }
  }
  
  func testStubParameterizedMethodWithExactValue_doesNotMatch_onClassMock() {
    shouldFail {
      given(self.child.childParameterizedInstanceMethod(param1: true, 1)) ~> true
      XCTAssertTrue(self.childInstance.childParameterizedInstanceMethod(param1: false, 1))
    }
  }
  func testStubParameterizedMethodWithExactValue_doesNotMatch_onProtocolMock() {
    shouldFail {
      given(self.childProtocol.childParameterizedInstanceMethod(param1: true, 1)) ~> true
      XCTAssertTrue(self.childProtocolInstance.childParameterizedInstanceMethod(param1: false, 1))
    }
  }
  
  func testStubParameterizedMethodWithExactValue_doesNotMatch_onClassMock_explicitSyntax() {
    shouldFail {
      given(self.child.childParameterizedInstanceMethod(param1: true, 1)).willReturn(true)
      XCTAssertTrue(self.childInstance.childParameterizedInstanceMethod(param1: false, 1))
    }
  }
  func testStubParameterizedMethodWithExactValue_doesNotMatch_onProtocolMock_explicitSyntax() {
    shouldFail {
      given(self.childProtocol.childParameterizedInstanceMethod(param1: true, 1)).willReturn(true)
      XCTAssertTrue(self.childProtocolInstance.childParameterizedInstanceMethod(param1: false, 1))
    }
  }
  
  // MARK: Value consistency
  
  func testStubReturnValueReturnsSameValue_onClassMock() {
    given(child.getChildComputedInstanceVariable()) ~> true
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    verify(child.getChildComputedInstanceVariable()).wasCalled(exactly(3))
  }
  func testStubReturnValueReturnsSameValue_onProtocolMock() {
    given(childProtocol.getChildInstanceVariable()) ~> true
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    verify(childProtocol.getChildInstanceVariable()).wasCalled(exactly(3))
  }
  
  func testStubReturnValueReturnsSameValue_onClassMock_explicitSyntax() {
    given(child.getChildComputedInstanceVariable()).willReturn(true)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    verify(child.getChildComputedInstanceVariable()).wasCalled(exactly(3))
  }
  func testStubReturnValueReturnsSameValue_onProtocolMock_explicitSyntax() {
    given(childProtocol.getChildInstanceVariable()).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    verify(childProtocol.getChildInstanceVariable()).wasCalled(exactly(3))
  }
  
  // MARK: Precedence
  
  func testStubParameterizedMethodOverridesPrevious_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodOverridesPrevious_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  func testStubParameterizedMethodOverridesPrevious_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(false)
    XCTAssertFalse(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodOverridesPrevious_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(false)
    XCTAssertFalse(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  func testStubParameterizedMethodIgnoresNonMatching_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(child.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodIgnoresNonMatching_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  func testStubParameterizedMethodIgnoresNonMatching_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(child.childParameterizedInstanceMethod(param1: any(), 100)).willReturn(false)
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(child.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  func testStubParameterizedMethodIgnoresNonMatching_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), 100)).willReturn(false)
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
    verify(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).wasCalled()
  }
  
  // MARK: Clearing stubs
  
  func testClearStubs_onClassMock() {
    shouldFail {
      given(self.child.getChildStoredInstanceVariable()) ~> true
      clearStubs(on: self.child)
      XCTAssertTrue(self.child.childStoredInstanceVariable)
    }
  }
  func testClearStubs_onProtocolMock() {
    shouldFail {
      given(self.childProtocol.getChildInstanceVariable()) ~> true
      clearStubs(on: self.childProtocol)
      XCTAssertTrue(self.child.childComputedInstanceVariable)
    }
  }
  
  func testClearStubs_onClassMock_explicitSyntax() {
    shouldFail {
      given(self.child.getChildStoredInstanceVariable()).willReturn(true)
      clearStubs(on: self.child)
      XCTAssertTrue(self.child.childStoredInstanceVariable)
    }
  }
  func testClearStubs_onProtocolMock_explicitSyntax() {
    shouldFail {
      given(self.childProtocol.getChildInstanceVariable()).willReturn(true)
      clearStubs(on: self.childProtocol)
      XCTAssertTrue(self.child.childComputedInstanceVariable)
    }
  }
  
  // MARK: Closure implementation stubs
  
  func testStubParameterizedMethod_onClassMock_withExplicitlyTypedClosure() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> {
      (param1: Bool, param2: Int) -> Bool in
      return param1 && param2 == 1
    }
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
  }
  func testStubParameterizedMethod_onProtocolMock_withExplicitlyTypedClosure() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> {
      (param1: Bool, param2: Int) -> Bool in
      return param1 && param2 == 1
    }
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
  }
  
  func testStubParameterizedMethod_onClassMock_withImplicitlyTypedClosure() {
    given(child.childParameterizedInstanceMethod(param1: any(), any()))
      ~> { $0 && $1 == 1 }
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(child.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
  }
  func testStubParameterizedMethod_onProtocolMock_withImplicitlyTypedClosure() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any()))
      ~> { $0 && $1 == 1 }
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
    verify(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).wasCalled()
  }
  
  func testStubTrivialMethod_onClassMock_withExplicitClosure() {
    given(child.childTrivialInstanceMethod()) ~> {}
    childInstance.childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  func testStubTrivialMethod_onProtocolMock_withExplicitClosure() {
    given(childProtocol.childTrivialInstanceMethod()) ~> {}
    childProtocolInstance.childTrivialInstanceMethod()
    verify(childProtocol.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testStubNonParameterizedReturningMethod_onClassMock_withExplicitClosure() {
    given(child.getChildComputedInstanceVariable()) ~> {true}
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    verify(child.getChildComputedInstanceVariable()).wasCalled()
  }
  func testStubNonParameterizedReturningMethod_onProtocolMock_withExplicitClosure() {
    given(childProtocol.getChildInstanceVariable()) ~> {true}
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    verify(childProtocol.getChildInstanceVariable()).wasCalled()
  }
  
  // MARK: Chained stubbing
  
  func testTransitionsToNextStub_afterCount() {
    given(childProtocol.getChildInstanceVariable())
      .willReturn(loopingSequence(of: true, false), transition: .after(4))
      .willReturn(true)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertFalse(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertFalse(childProtocolInstance.childInstanceVariable)
    
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    
    // Check clamped to last value
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    
    verify(childProtocol.getChildInstanceVariable()).wasCalled(exactly(6))
  }
  
  func testTransitionsToNextStub_afterCount_skipsValueWhenStubbedLater() {
    let stubbingManager = given(childProtocol.getChildInstanceVariable())
      .willReturn(loopingSequence(of: false), transition: .after(2))
    XCTAssertFalse(childProtocolInstance.childInstanceVariable)
    XCTAssertFalse(childProtocolInstance.childInstanceVariable)
    XCTAssertFalse(childProtocolInstance.childInstanceVariable) // Still using sequence value
    
    stubbingManager.willReturn(true)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable) // Should skip to latest stub
    
    // Check clamped to last value
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    
    verify(childProtocol.getChildInstanceVariable()).wasCalled(exactly(5))
  }
  
  func testTransitionsToNextStub_onFirstNil() {
    given(childProtocol.getChildInstanceVariable())
      .willReturn(finiteSequence(of: true, false))
      .willReturn(true)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertFalse(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    
    // Check clamped to last value
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    
    verify(childProtocol.getChildInstanceVariable()).wasCalled(exactly(4))
  }
}
