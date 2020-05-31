//
//  SequentialValueStubbingTests.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/15/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class SequentialValueStubbingTests: BaseTestCase {
  
  var concreteMock: FakeableTypeReferencerMock!
  var concreteInstance: FakeableTypeReferencer { return concreteMock }
  
  override func setUp() {
    concreteMock = mock(FakeableTypeReferencer.self)
  }
  
  func testValuesReturnedInOrder() {
    given(concreteMock.fakeableInt()) ~> sequence(of: 1, 2, 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(3))
  }
  
  func testImplementationsReturnedInOrder() {
    given(concreteMock.fakeableInt()) ~> sequence(of: {1}, {2}, {3})
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(3))
  }
  
  func testImplementationsEvaluatedLazily() {
    given(concreteMock.fakeableInt()) ~> sequence(of: {1}, { XCTFail("Not lazy"); fatalError() })
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testThrowingImplementationThrows() {
    let concreteMock = mock(ThrowingProtocol.self)
    let concreteInstance = concreteMock as ThrowingProtocol
    struct LazyError: Error {}
    func generateBool() throws -> Bool { throw LazyError() }
    given(concreteMock.throwingMethod()) ~> sequence(of: {true}, {try generateBool()})
    XCTAssertEqual(try concreteInstance.throwingMethod(), true)
    XCTAssertThrowsError(try concreteInstance.throwingMethod() as Bool)
  }
  
  func testParameterizedImplementation() {
    let concreteMock = mock(ChildProtocol.self)
    let concreteInstance = concreteMock as ChildProtocol
    given(concreteMock.childParameterizedInstanceMethod(param1: any(), any())) ~>
      sequence(of: { _, _ in
        return true
      }, { param1, param2 in
        return param1 && param2 > 42
      })
    XCTAssertTrue(concreteInstance.childParameterizedInstanceMethod(param1: false, 0))
    XCTAssertTrue(concreteInstance.childParameterizedInstanceMethod(param1: true, 43))
    XCTAssertFalse(concreteInstance.childParameterizedInstanceMethod(param1: false, 43))
    XCTAssertFalse(concreteInstance.childParameterizedInstanceMethod(param1: true, 41))
  }
  
  // MARK: Last value sequence
  
  func testLastValueUsedWhenSequenceFinished() {
    given(concreteMock.fakeableInt()) ~> sequence(of: 1, 2, 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(5))
  }
  
  func testImplementationUsedWhenSequenceFinished() {
    given(concreteMock.fakeableInt()) ~> sequence(of: {1}, {2}, {3})
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(5))
  }
  
  // MARK: Looping sequence
  
  func testSequenceLoopsValuesWhenReachesEnd() {
    given(concreteMock.fakeableInt()) ~> loopingSequence(of: 1, 2, 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(6))
  }
  
  func testSequenceLoopsImplementationsWhenReachesEnd() {
    given(concreteMock.fakeableInt()) ~> loopingSequence(of: {1}, {2}, {3})
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(6))
  }
  
  // MARK: Finite sequence
  
  func testSequenceStopsReturningValuesWhenReachesEnd() {
    shouldFail {
      given(self.concreteMock.fakeableInt()) ~> finiteSequence(of: 1, 2, 3)
      XCTAssertEqual(self.concreteInstance.fakeableInt(), 1)
      XCTAssertEqual(self.concreteInstance.fakeableInt(), 2)
      XCTAssertEqual(self.concreteInstance.fakeableInt(), 3)
      _ = self.concreteInstance.fakeableInt()
    }
  }
  
  func testSequenceStopsReturningImplementationsWhenReachesEnd() {
    shouldFail {
      given(self.concreteMock.fakeableInt()) ~> finiteSequence(of: {1}, {2}, {3})
      XCTAssertEqual(self.concreteInstance.fakeableInt(), 1)
      XCTAssertEqual(self.concreteInstance.fakeableInt(), 2)
      XCTAssertEqual(self.concreteInstance.fakeableInt(), 3)
      _ = self.concreteInstance.fakeableInt()
    }
  }
}
