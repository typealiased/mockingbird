//
//  ClosureParameterTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 11/29/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class ClosureParameterTests: XCTestCase {
  
  var concreteMock: ClosureParametersProtocolMock!
  
  override func setUp() {
    concreteMock = mock(ClosureParametersProtocol.self)
  }
  
  // MARK: - any()
  
  // MARK: Non-escaping

  func testTrivialClosure_anyWildcardMatching() {
    given(concreteMock.trivialClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .trivialClosure(block: {}))
    verify(concreteMock.trivialClosure(block: any())).wasCalled()
  }
  
  func testTrivialReturningClosure_anyWildcardMatching() {
    given(concreteMock.trivialReturningClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .trivialReturningClosure(block: { fatalError() }))
    verify(concreteMock.trivialReturningClosure(block: any())).wasCalled()
  }
  
  func testParameterizedClosure_anyWildcardMatching() {
    given(concreteMock.parameterizedClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .parameterizedClosure(block: { _ in }))
    verify(concreteMock.parameterizedClosure(block: any())).wasCalled()
  }
  
  func testParameterizedReturningClosure_anyWildcardMatching() {
    given(concreteMock.parameterizedReturningClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .parameterizedReturningClosure(block: { _ in fatalError() }))
    verify(concreteMock.parameterizedReturningClosure(block: any())).wasCalled()
  }
  
  // MARK: Escaping
  
  func testEscapingTrivialClosure_anyWildcardMatching() {
    given(concreteMock.escapingTrivialClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .escapingTrivialClosure(block: {}))
    verify(concreteMock.escapingTrivialClosure(block: any())).wasCalled()
  }
  
  func testEscapingTrivialReturningClosure_anyWildcardMatching() {
    given(concreteMock.escapingTrivialReturningClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .escapingTrivialReturningClosure(block: { fatalError() }))
    verify(concreteMock.escapingTrivialReturningClosure(block: any())).wasCalled()
  }
  
  func testEscapingParameterizedClosure_anyWildcardMatching() {
    given(concreteMock.escapingParameterizedClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .escapingParameterizedClosure(block: { _ in }))
    verify(concreteMock.escapingParameterizedClosure(block: any())).wasCalled()
  }
  
  func testEscapingParameterizedReturningClosure_anyWildcardMatching() {
    given(concreteMock.escapingParameterizedReturningClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .escapingParameterizedReturningClosure(block: { _ in fatalError() }))
    verify(concreteMock.escapingParameterizedReturningClosure(block: any())).wasCalled()
  }
  
  // MARK: Nullable
  
  func testImplicitEscapingTrivialClosure_anyWildcardMatching() {
    given(concreteMock.implicitEscapingTrivialClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingTrivialClosure(block: {}))
    verify(concreteMock.implicitEscapingTrivialClosure(block: any())).wasCalled()
  }
  
  func testImplicitEscapingTrivialReturningClosure_anyWildcardMatching() {
    given(concreteMock.implicitEscapingTrivialReturningClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingTrivialReturningClosure(block: { fatalError() }))
    verify(concreteMock.implicitEscapingTrivialReturningClosure(block: any())).wasCalled()
  }
  
  func testImplicitEscapingParameterizedClosure_anyWildcardMatching() {
    given(concreteMock.implicitEscapingParameterizedClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingParameterizedClosure(block: { _ in }))
    verify(concreteMock.implicitEscapingParameterizedClosure(block: any())).wasCalled()
  }
  
  func testImplicitEscapingParameterizedReturningClosure_anyWildcardMatching() {
    given(concreteMock.implicitEscapingParameterizedReturningClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingParameterizedReturningClosure(block: { _ in fatalError() }))
    verify(concreteMock.implicitEscapingParameterizedReturningClosure(block: any())).wasCalled()
  }
  
  // MARK: Wrapped
  
  func testWrappedClosureParameter_anyWildcardMatching() {
    given(concreteMock.wrappedClosureParameter(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol).wrappedClosureParameter(block: ClosureWrapper()))
    verify(concreteMock.wrappedClosureParameter(block: any())).wasCalled()
  }
  
  // MARK: Tuple wrapped non-escaping
  
  func testTrivialTupleClosure_anyWildcardMatching() {
    given(concreteMock.trivialTupleClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .trivialTupleClosure(block: {}))
    verify(concreteMock.trivialTupleClosure(block: any())).wasCalled()
  }
  
  func testTrivialReturningTupleClosure_anyWildcardMatching() {
    given(concreteMock.trivialReturningTupleClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .trivialReturningTupleClosure(block: { fatalError() }))
    verify(concreteMock.trivialReturningTupleClosure(block: any())).wasCalled()
  }
  
  func testParameterizedTupleClosure_anyWildcardMatching() {
    given(concreteMock.parameterizedTupleClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .parameterizedTupleClosure(block: { _ in }))
    verify(concreteMock.parameterizedTupleClosure(block: any())).wasCalled()
  }
  
  func testParameterizedReturningTupleClosure_anyWildcardMatching() {
    given(concreteMock.parameterizedReturningTupleClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .parameterizedReturningTupleClosure(block: { _ in fatalError() }))
    verify(concreteMock.parameterizedReturningTupleClosure(block: any())).wasCalled()
  }
  
  // MARK: Tuple wrapped escaping
  
  func testImplicitEscapingMultipleTupleClosure_anyWildcardMatching() {
    given(concreteMock.implicitEscapingMultipleTupleClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingMultipleTupleClosure(block: ({}, { _ in fatalError() })))
    verify(concreteMock.implicitEscapingMultipleTupleClosure(block: any())).wasCalled()
  }
  
  func testImplicitEscapingMultipleLabeledTupleClosure_anyWildcardMatching() {
    given(concreteMock.implicitEscapingMultipleLabeledTupleClosure(block: any())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingMultipleLabeledTupleClosure(block: (a: {}, b: { _ in fatalError() })))
    verify(concreteMock.implicitEscapingMultipleLabeledTupleClosure(block: any())).wasCalled()
  }
  
  
  // MARK: - notNil()
  
  func testImplicitEscapingTrivialClosure_notNilWildcardMatching_matchesNotNil() {
    given(concreteMock.implicitEscapingTrivialClosure(block: notNil())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingTrivialClosure(block: {}))
    verify(concreteMock.implicitEscapingTrivialClosure(block: notNil())).wasCalled()
  }
  
  func testImplicitEscapingTrivialClosure_notNilWildcardMatching_doesNotMatchNil() {
    given(concreteMock.implicitEscapingTrivialClosure(block: any())) ~> true
    given(concreteMock.implicitEscapingTrivialClosure(block: notNil())) ~> false
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingTrivialClosure(block: nil))
    verify(concreteMock.implicitEscapingTrivialClosure(block: any())).wasCalled()
    verify(concreteMock.implicitEscapingTrivialClosure(block: notNil())).wasNeverCalled()
  }
  
  func testImplicitEscapingTrivialReturningClosure_notNilWildcardMatching_matchesNotNil() {
    given(concreteMock.implicitEscapingTrivialReturningClosure(block: notNil())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingTrivialReturningClosure(block: { fatalError() }))
    verify(concreteMock.implicitEscapingTrivialReturningClosure(block: notNil())).wasCalled()
  }
  
  func testImplicitEscapingTrivialReturningClosure_notNilWildcardMatching_doesNotMatchNil() {
    given(concreteMock.implicitEscapingTrivialReturningClosure(block: any())) ~> true
    given(concreteMock.implicitEscapingTrivialReturningClosure(block: notNil())) ~> false
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingTrivialReturningClosure(block: nil))
    verify(concreteMock.implicitEscapingTrivialReturningClosure(block: any())).wasCalled()
    verify(concreteMock.implicitEscapingTrivialReturningClosure(block: notNil())).wasNeverCalled()
  }
  
  func testImplicitEscapingParameterizedClosure_notNilWildcardMatching_matchesNotNil() {
    given(concreteMock.implicitEscapingParameterizedClosure(block: notNil())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingParameterizedClosure(block: { _ in }))
    verify(concreteMock.implicitEscapingParameterizedClosure(block: notNil())).wasCalled()
  }
  
  func testImplicitEscapingParameterizedClosure_notNilWildcardMatching_doesNotMatchNil() {
    given(concreteMock.implicitEscapingParameterizedClosure(block: any())) ~> true
    given(concreteMock.implicitEscapingParameterizedClosure(block: notNil())) ~> false
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingParameterizedClosure(block: nil))
    verify(concreteMock.implicitEscapingParameterizedClosure(block: any())).wasCalled()
    verify(concreteMock.implicitEscapingParameterizedClosure(block: notNil())).wasNeverCalled()
  }
  
  func testImplicitEscapingParameterizedReturningClosure_notNilWildcardMatching_matchesNotNil() {
    given(concreteMock.implicitEscapingParameterizedReturningClosure(block: notNil())) ~> true
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingParameterizedReturningClosure(block: { _ in fatalError() }))
    verify(concreteMock.implicitEscapingParameterizedReturningClosure(block: notNil())).wasCalled()
  }
  
  func testImplicitEscapingParameterizedReturningClosure_notNilWildcardMatching_doesNotMatchNil() {
    given(concreteMock.implicitEscapingParameterizedReturningClosure(block: any())) ~> true
    given(concreteMock.implicitEscapingParameterizedReturningClosure(block: notNil())) ~> false
    XCTAssertTrue((concreteMock as ClosureParametersProtocol)
      .implicitEscapingParameterizedReturningClosure(block: nil))
    verify(concreteMock.implicitEscapingParameterizedReturningClosure(block: any())).wasCalled()
    verify(concreteMock.implicitEscapingParameterizedReturningClosure(block: notNil())).wasNeverCalled()
  }
}
