//
//  SequentialValueStubbingTests.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/15/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class SequentialValueStubbingTests: XCTestCase {
  
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
  
  func testLastValueUsedWhenSequenceFinished() {
    given(concreteMock.fakeableInt()) ~> sequence(of: 1, 2, 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 1)
    XCTAssertEqual(concreteInstance.fakeableInt(), 2)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    XCTAssertEqual(concreteInstance.fakeableInt(), 3)
    verify(concreteMock.fakeableInt()).wasCalled(exactly(5))
  }
}
