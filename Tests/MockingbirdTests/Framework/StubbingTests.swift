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
  
  var throwingProtocol: ThrowingProtocolMock!
  var throwingProtocolInstance: ThrowingProtocol { return throwingProtocol }
  
  var rethrowingProtocol: RethrowingProtocolMock!
  var rethrowingProtocolInstance: RethrowingProtocol { return rethrowingProtocol }
  
  var inoutProtocol: InoutProtocolMock!
  var inoutProtocolInstance: InoutProtocol { return inoutProtocol }
  
  override func setUp() {
    child = mock(Child.self)
    childProtocol = mock(ChildProtocol.self)
    throwingProtocol = mock(ThrowingProtocol.self)
    rethrowingProtocol = mock(RethrowingProtocol.self)
    inoutProtocol = mock(InoutProtocol.self)
  }
  
  func testStubTrivialMethod_onClassMock_implicitlyStubbed() {
    childInstance.childTrivialInstanceMethod()
  }
  func testStubTrivialMethod_onProtocolMock_implicitlyStubbed() {
    childProtocolInstance.childTrivialInstanceMethod()
  }
  
  func testStubTrivialMethod_onClassMock() {
    given(child.childTrivialInstanceMethod()) ~> ()
    childInstance.childTrivialInstanceMethod()
  }
  func testStubTrivialMethod_onProtocolMock() {
    given(childProtocol.childTrivialInstanceMethod()) ~> ()
    childProtocolInstance.childTrivialInstanceMethod()
  }
  
  func testStubTrivialMethod_onClassMock_explicitSyntax() {
    given(child.childTrivialInstanceMethod()).willReturn(())
    childInstance.childTrivialInstanceMethod()
  }
  func testStubTrivialMethod_onProtocolMock_explicitSyntax() {
    given(childProtocol.childTrivialInstanceMethod()).willReturn(())
    childProtocolInstance.childTrivialInstanceMethod()
  }
  
  func testStubTrivialMethod_onClassMock_convenienceExplicitSyntax() {
    given(child.childTrivialInstanceMethod()).willReturn()
    childInstance.childTrivialInstanceMethod()
  }
  func testStubTrivialMethod_onProtocolMock_convenienceExplicitSyntax() {
    given(childProtocol.childTrivialInstanceMethod()).willReturn()
    childProtocolInstance.childTrivialInstanceMethod()
  }
  
  func testStubParameterizedMethodWithWildcardMatcher_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodWithWildcardMatcher_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethodWithWildcardMatcher_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodWithWildcardMatcher_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethodWithExactValue_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: true, 1)) ~> true
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodWithExactValue_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: true, 1)) ~> true
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethodWithExactValue_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: true, 1)).willReturn(true)
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodWithExactValue_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: true, 1)).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
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
  }
  func testStubReturnValueReturnsSameValue_onProtocolMock() {
    given(childProtocol.getChildInstanceVariable()) ~> true
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
  }
  
  func testStubReturnValueReturnsSameValue_onClassMock_explicitSyntax() {
    given(child.getChildComputedInstanceVariable()).willReturn(true)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
  }
  func testStubReturnValueReturnsSameValue_onProtocolMock_explicitSyntax() {
    given(childProtocol.getChildInstanceVariable()).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
  }
  
  // MARK: Precedence
  
  func testStubParameterizedMethodOverridesPrevious_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodOverridesPrevious_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> false
    XCTAssertFalse(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethodOverridesPrevious_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(false)
    XCTAssertFalse(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodOverridesPrevious_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(false)
    XCTAssertFalse(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethodIgnoresNonMatching_onClassMock() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(child.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodIgnoresNonMatching_onProtocolMock() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> true
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), 100)) ~> false
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethodIgnoresNonMatching_onClassMock_explicitSyntax() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(child.childParameterizedInstanceMethod(param1: any(), 100)).willReturn(false)
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethodIgnoresNonMatching_onProtocolMock_explicitSyntax() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())).willReturn(true)
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), 100)).willReturn(false)
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
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
  
  // MARK: Multiple invocation stubbing
  
  func testStubMultipleInvocations_onClassMock() {
    given(
      child.getChildComputedInstanceVariable(),
      child.getParentComputedInstanceVariable()
    ) ~> true
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.parentComputedInstanceVariable)
  }
  func testStubMultipleInvocations_onProtocolMock() {
    given(
      childProtocol.getChildInstanceVariable(),
      childProtocol.getParentInstanceVariable()
    ) ~> true
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.parentInstanceVariable)
  }
  
  func testStubMultipleInvocations_onClassMock_explicitSyntax() {
    given(
      child.getChildComputedInstanceVariable(),
      child.getParentComputedInstanceVariable()
    ).willReturn(true)
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
    XCTAssertTrue(childInstance.parentComputedInstanceVariable)
  }
  func testStubMultipleInvocations_onProtocolMock_explicitSyntax() {
    given(
      childProtocol.getChildInstanceVariable(),
      childProtocol.getParentInstanceVariable()
    ).willReturn(true)
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
    XCTAssertTrue(childProtocolInstance.parentInstanceVariable)
  }
  
  // MARK: Closure implementation stubs
  
  func testStubParameterizedMethod_onClassMock_withExplicitlyTypedClosure() {
    given(child.childParameterizedInstanceMethod(param1: any(), any())) ~> {
      (param1: Bool, param2: Int) -> Bool in
      return param1 && param2 == 1
    }
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethod_onProtocolMock_withExplicitlyTypedClosure() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any())) ~> {
      (param1: Bool, param2: Int) -> Bool in
      return param1 && param2 == 1
    }
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubParameterizedMethod_onClassMock_withImplicitlyTypedClosure() {
    given(child.childParameterizedInstanceMethod(param1: any(), any()))
      ~> { $0 && $1 == 1 }
    XCTAssertTrue(childInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  func testStubParameterizedMethod_onProtocolMock_withImplicitlyTypedClosure() {
    given(childProtocol.childParameterizedInstanceMethod(param1: any(), any()))
      ~> { $0 && $1 == 1 }
    XCTAssertTrue(childProtocolInstance.childParameterizedInstanceMethod(param1: true, 1))
  }
  
  func testStubTrivialMethod_onClassMock_withExplicitClosure() {
    given(child.childTrivialInstanceMethod()) ~> {}
    childInstance.childTrivialInstanceMethod()
  }
  func testStubTrivialMethod_onProtocolMock_withExplicitClosure() {
    given(childProtocol.childTrivialInstanceMethod()) ~> {}
    childProtocolInstance.childTrivialInstanceMethod()
  }
  
  func testStubNonParameterizedReturningMethod_onClassMock_withExplicitClosure() {
    given(child.getChildComputedInstanceVariable()) ~> {true}
    XCTAssertTrue(childInstance.childComputedInstanceVariable)
  }
  func testStubNonParameterizedReturningMethod_onProtocolMock_withExplicitClosure() {
    given(childProtocol.getChildInstanceVariable()) ~> {true}
    XCTAssertTrue(childProtocolInstance.childInstanceVariable)
  }
  
  // MARK: Throwing errors
  
  func testStubThrowingMethod_returnsValue() {
    given(throwingProtocol.throwingMethod()) ~> true
    XCTAssertTrue(try throwingProtocolInstance.throwingMethod())
  }
  func testStubThrowingMethod_throwsError() {
    given(throwingProtocol.throwingMethod()) ~> { () throws -> Bool in throw FakeError() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod() as Bool)
  }
  func testStubThrowingMethod_implicitlyRethrowsError() {
    given(throwingProtocol.throwingMethod(block: any())) ~> { _ = try $0() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod(block: { throw FakeError() }))
  }
  
  func testStubThrowingMethod_returnsValue_explicitSyntax() {
    given(throwingProtocol.throwingMethod()).willReturn(true)
    XCTAssertTrue(try throwingProtocolInstance.throwingMethod())
  }
  func testStubThrowingMethod_throwsError_explicitSyntax() {
    given(throwingProtocol.throwingMethod()).returning(Bool.self).willThrow(FakeError())
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod() as Bool)
  }
  func testStubThrowingMethod_implicitlyRethrowsError_explicitSyntax() {
    given(throwingProtocol.throwingMethod(block: any())).will { _ = try $0() }
    XCTAssertThrowsError(try throwingProtocolInstance.throwingMethod(block: { throw FakeError() }))
  }
  
  func testStubRethrowingReturningMethod_returnsValue() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> true
    XCTAssertTrue(try rethrowingProtocolInstance.rethrowingMethod(block: { throw FakeError() }))
  }
  func testStubRethrowingReturningMethod_returnsValueFromBlock() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> { return try $0() }
    XCTAssertTrue(rethrowingProtocolInstance.rethrowingMethod(block: { return true }))
  }
  func testStubRethrowingReturningMethod_rethrowsError() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> { return try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Bool)
  }
  func testStubRethrowingNonReturningMethod_rethrowsError() {
    given(rethrowingProtocol.rethrowingMethod(block: any())) ~> { _ = try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Void)
  }
  
  func testStubRethrowingReturningMethod_returnsValue_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).willReturn(true)
    XCTAssertTrue(try rethrowingProtocolInstance.rethrowingMethod(block: { throw FakeError() }))
  }
  func testStubRethrowingReturningMethod_returnsValueFromBlock_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).will { return try $0() }
    XCTAssertTrue(rethrowingProtocolInstance.rethrowingMethod(block: { return true }))
  }
  func testStubRethrowingReturningMethod_rethrowsError_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).will { return try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Bool)
  }
  func testStubRethrowingNonReturningMethod_rethrowsError_explicitSyntax() {
    given(rethrowingProtocol.rethrowingMethod(block: any())).will { _ = try $0() }
    XCTAssertThrowsError(try rethrowingProtocolInstance.rethrowingMethod(block: {
      throw FakeError()
    }) as Void)
  }
  
  // MARK: Inout parameters
  
  func testInoutParameter_doesNotMutateString() {
    given(inoutProtocol.parameterizedMethod(object: any())) ~> { _ in }
    var valueType = "foo bar"
    inoutProtocolInstance.parameterizedMethod(object: &valueType)
    XCTAssertEqual(valueType, "foo bar")
  }
  func testInoutParameter_uppercasesString() {
    given(inoutProtocol.parameterizedMethod(object: any())) ~> { $0 = $0.uppercased() }
    var valueType = "foo bar"
    inoutProtocolInstance.parameterizedMethod(object: &valueType)
    XCTAssertEqual(valueType, "FOO BAR")
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
  }
}
