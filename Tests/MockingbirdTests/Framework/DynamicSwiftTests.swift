//
//  ObjectiveCTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/17/21.
//

import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

@objc class MinimalObjCClass: Foundation.NSObject {
  @objc dynamic func method(valueType: Bool) -> Bool { fatalError() }
  @objc dynamic func method(bridgedType: String) -> String { fatalError() }
  @objc dynamic func method(referenceType: Foundation.NSObject) -> Foundation.NSObject {
    fatalError()
  }
  @objc dynamic func method(first: String, second: String) -> String { fatalError() }
  
  @objc dynamic func throwingMethod() throws {}
  @objc dynamic public func trivialMethod() {}
  
  @objc dynamic var valueTypeProperty = false
  @objc dynamic var bridgedTypeProperty = ""
  @objc dynamic var referenceTypeProperty = Foundation.NSObject()
}

class MinimalObjCSubclass: MinimalObjCClass {}

class DynamicSwiftTests: BaseTestCase {
  
  var classMock: MinimalObjCClass!
  var subclassMock: MinimalObjCSubclass!
  
  override func setUpWithError() throws {
    self.classMock = mock(MinimalObjCClass.self)
    self.subclassMock = mock(MinimalObjCSubclass.self)
  }
  
  
  // MARK: - Swift Properties
  
  // MARK: Value types
  
  func testClassValueTypePropertyGetter() throws {
    given(classMock.valueTypeProperty).willReturn(true)
    XCTAssertTrue(classMock.valueTypeProperty)
    verify(classMock.valueTypeProperty).wasCalled()
  }
  func testClassValueTypePropertyGetter_stubbingOperator() throws {
    given(classMock.valueTypeProperty) ~> true
    XCTAssertTrue(classMock.valueTypeProperty)
    verify(classMock.valueTypeProperty).wasCalled()
  }
  
  func testClassValueTypePropertySetter() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = true).will { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = true).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassValueTypePropertySetter_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = true) ~> { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = true).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testClassValueTypePropertySetterMatchesWildcard() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = any()).will { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = any()).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassValueTypePropertySetterMatchesWildcard_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = any()) ~> { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = any()).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  // MARK: Bridged types
  
  func testClassBridgedPropertyGetter() throws {
    given(classMock.bridgedTypeProperty).willReturn("Ryan")
    XCTAssertEqual(classMock.bridgedTypeProperty, "Ryan")
    verify(classMock.bridgedTypeProperty).wasCalled()
  }
  func testClassBridgedPropertyGetter_stubbingOperator() throws {
    given(classMock.bridgedTypeProperty) ~> "Ryan"
    XCTAssertEqual(classMock.bridgedTypeProperty, "Ryan")
    verify(classMock.bridgedTypeProperty).wasCalled()
  }
  
  func testClassBridgedPropertySetter() throws {
    let expectation = XCTestExpectation()
    given(classMock.bridgedTypeProperty = "Ryan").will { (newValue: String) in
      XCTAssertEqual(newValue, "Ryan")
      expectation.fulfill()
    }
    classMock.bridgedTypeProperty = "Ryan"
    verify(classMock.bridgedTypeProperty = "Ryan").wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassBridgedPropertySetter_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.bridgedTypeProperty = "Ryan") ~> { (newValue: String) in
      XCTAssertEqual(newValue, "Ryan")
      expectation.fulfill()
    }
    classMock.bridgedTypeProperty = "Ryan"
    verify(classMock.bridgedTypeProperty = "Ryan").wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testClassBridgedPropertySetterMatchesWildcard() throws {
    let expectation = XCTestExpectation()
    given(classMock.bridgedTypeProperty = any()).will { (newValue: String) in
      XCTAssertEqual(newValue, "Ryan")
      expectation.fulfill()
    }
    classMock.bridgedTypeProperty = "Ryan"
    verify(classMock.bridgedTypeProperty = any()).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassBridgedPropertySetterMatchesWildcard_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.bridgedTypeProperty = any()) ~> { (newValue: String) in
      XCTAssertEqual(newValue, "Ryan")
      expectation.fulfill()
    }
    classMock.bridgedTypeProperty = "Ryan"
    verify(classMock.bridgedTypeProperty = any()).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  // MARK: Reference types
  
  func testClassReferenceTypePropertyGetter() throws {
    let ref = Foundation.NSObject()
    given(classMock.referenceTypeProperty).willReturn(ref)
    XCTAssertTrue(classMock.referenceTypeProperty === ref)
    verify(classMock.referenceTypeProperty).wasCalled()
  }
  func testClassReferenceTypePropertyGetter_stubbingOperator() throws {
    let ref = Foundation.NSObject()
    given(classMock.referenceTypeProperty) ~> ref
    XCTAssertTrue(classMock.referenceTypeProperty === ref)
    verify(classMock.referenceTypeProperty).wasCalled()
  }
  
  func testClassReferenceTypePropertySetter() throws {
    let ref = Foundation.NSObject()
    let expectation = XCTestExpectation()
    given(classMock.referenceTypeProperty = ref).will { (newValue: Foundation.NSObject) in
      XCTAssertEqual(newValue, ref)
      expectation.fulfill()
    }
    classMock.referenceTypeProperty = ref
    verify(classMock.referenceTypeProperty = ref).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassReferenceTypePropertySetter_stubbingOperator() throws {
    let ref = Foundation.NSObject()
    let expectation = XCTestExpectation()
    given(classMock.referenceTypeProperty = ref) ~> { (newValue: Foundation.NSObject) in
      XCTAssertEqual(newValue, ref)
      expectation.fulfill()
    }
    classMock.referenceTypeProperty = ref
    verify(classMock.referenceTypeProperty = ref).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testClassReferenceTypePropertySetterExclusive() throws {
    given(self.classMock.referenceTypeProperty = Foundation.NSObject()).will {
      (newValue: Foundation.NSObject) in
      XCTFail()
    }
    self.classMock.referenceTypeProperty = Foundation.NSObject()
  }
  func testClassReferenceTypePropertySetterExclusive_stubbingOperator() throws {
    given(self.classMock.referenceTypeProperty = Foundation.NSObject()) ~> {
      (newValue: Foundation.NSObject) in
      XCTFail()
    }
    self.classMock.referenceTypeProperty = Foundation.NSObject()
  }
  
  func testClassReferenceTypePropertySetterMatchesWildcard() throws {
    let ref = Foundation.NSObject()
    let expectation = XCTestExpectation()
    given(classMock.referenceTypeProperty = any()).will {
      (newValue: Foundation.NSObject) in
      XCTAssertEqual(newValue, ref)
      expectation.fulfill()
    }
    classMock.referenceTypeProperty = ref
    verify(classMock.referenceTypeProperty = any()).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassReferenceTypePropertySetterMatchesWildcard_stubbingOperator() throws {
    let ref = Foundation.NSObject()
    let expectation = XCTestExpectation()
    given(classMock.referenceTypeProperty = any()) ~> {
      (newValue: Foundation.NSObject) in
      XCTAssertEqual(newValue, ref)
      expectation.fulfill()
    }
    classMock.referenceTypeProperty = ref
    verify(classMock.referenceTypeProperty = any()).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  
  // MARK: - Swift methods
  
  // MARK: Value types
  
  func testClassValueTypeMethodMatchesExact() throws {
    given(classMock.method(valueType: true)).willReturn(true)
    XCTAssertTrue(classMock.method(valueType: true))
    verify(classMock.method(valueType: true)).wasCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  func testClassValueTypeMethodMatchesExact_stubbingOperator() throws {
    given(classMock.method(valueType: true)) ~> true
    XCTAssertTrue(classMock.method(valueType: true))
    verify(classMock.method(valueType: true)).wasCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  
  func testClassValueTypeMethodMatchesExactExclusive() throws {
    shouldFail {
      given(self.classMock.method(valueType: true)).willReturn(true)
      _ = self.classMock.method(valueType: false)
    }
  }
  func testClassValueTypeMethodMatchesExactExclusive_stubbingOperator() throws {
    shouldFail {
      given(self.classMock.method(valueType: true)) ~> true
      _ = self.classMock.method(valueType: false)
    }
  }
  
  func testClassValueTypeMethodMatchesWildcard() throws {
    given(classMock.method(valueType: firstArg(any()))).will {
      (valueType: Bool) in
      return valueType
    }
    XCTAssertTrue(classMock.method(valueType: true))
    XCTAssertFalse(classMock.method(valueType: false))
    verify(classMock.method(valueType: true)).wasCalled()
    verify(classMock.method(valueType: false)).wasCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  func testClassValueTypeMethodMatchesWildcard_stubbingOperator() throws {
    given(classMock.method(valueType: any())) ~> {
      (valueType: Bool) in
      return valueType
    }
    XCTAssertTrue(classMock.method(valueType: true))
    XCTAssertFalse(classMock.method(valueType: false))
    verify(classMock.method(valueType: true)).wasCalled()
    verify(classMock.method(valueType: false)).wasCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  
  // MARK: Bridged types
  
  func testClassBridgedTypeMethodMatchesExact() throws {
    given(classMock.method(bridgedType: "Ryan")).willReturn("Ryan")
    XCTAssertEqual(classMock.method(bridgedType: "Ryan"), "Ryan")
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: "Ryan")).wasCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  func testClassBridgedTypeMethodMatchesExact_stubbingOperator() throws {
    given(classMock.method(bridgedType: "Ryan")) ~> "Ryan"
    XCTAssertEqual(classMock.method(bridgedType: "Ryan"), "Ryan")
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: "Ryan")).wasCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  
  func testClassBridgedTypeMethodMatchesExactExclusive() throws {
    shouldFail {
      given(self.classMock.method(bridgedType: "Ryan")).willReturn("Ryan")
      _ = self.classMock.method(bridgedType: "Sterling")
    }
  }
  func testClassBridgedTypeMethodMatchesExactExclusive_stubbingOperator() throws {
    shouldFail {
      given(self.classMock.method(bridgedType: "Ryan")) ~> "Ryan"
      _ = self.classMock.method(bridgedType: "Sterling")
    }
  }
  
  func testClassBridgedTypeMethodMatchesWildcard() throws {
    given(classMock.method(bridgedType: any())).will {
      (valueType: String) in
      return valueType
    }
    XCTAssertEqual(classMock.method(bridgedType: "Ryan"), "Ryan")
    XCTAssertEqual(classMock.method(bridgedType: "Sterling"), "Sterling")
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: "Ryan")).wasCalled()
    verify(classMock.method(bridgedType: "Sterling")).wasCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  func testClassBridgedTypeMethodMatchesWildcard_stubbingOperator() throws {
    given(classMock.method(bridgedType: any())) ~> {
      (valueType: String) in
      return valueType
    }
    XCTAssertEqual(classMock.method(bridgedType: "Ryan"), "Ryan")
    XCTAssertEqual(classMock.method(bridgedType: "Sterling"), "Sterling")
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: "Ryan")).wasCalled()
    verify(classMock.method(bridgedType: "Sterling")).wasCalled()
    verify(classMock.method(referenceType: any())).wasNeverCalled()
  }
  
  // MARK: Reference types
  
  func testClassReferenceTypeMethodMatchesExact() throws {
    let ref = Foundation.NSObject()
    given(classMock.method(referenceType: ref)).willReturn(ref)
    XCTAssertEqual(classMock.method(referenceType: ref), ref)
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: ref)).wasCalled()
  }
  func testClassReferenceTypeMethodMatchesExact_stubbingOperator() throws {
    let ref = Foundation.NSObject()
    given(classMock.method(referenceType: ref)) ~> ref
    XCTAssertEqual(classMock.method(referenceType: ref), ref)
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: ref)).wasCalled()
  }
  
  func testClassReferenceTypeMethodMatchesExactExclusive() throws {
    shouldFail {
      let ref = Foundation.NSObject()
      given(self.classMock.method(referenceType: ref)).willReturn(ref)
      _ = self.classMock.method(referenceType: Foundation.NSObject())
    }
  }
  func testClassReferenceTypeMethodMatchesExactExclusive_stubbingOperator() throws {
    shouldFail {
      let ref = Foundation.NSObject()
      given(self.classMock.method(referenceType: ref)) ~> ref
      _ = self.classMock.method(referenceType: Foundation.NSObject())
    }
  }
  
  func testClassReferenceTypeMethodMatchesWildcard() throws {
    given(classMock.method(referenceType: any())).will {
      (valueType: Foundation.NSObject) in
      return valueType
    }
    let ref1 = Foundation.NSObject()
    let ref2 = Foundation.NSObject()
    XCTAssertEqual(classMock.method(referenceType: ref1), ref1)
    XCTAssertEqual(classMock.method(referenceType: ref2), ref2)
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: any())).wasCalled(twice)
  }
  func testClassReferenceTypeMethodMatchesWildcard_stubbingOperator() throws {
    given(classMock.method(referenceType: any())) ~> {
      (valueType: Foundation.NSObject) in
      return valueType
    }
    let ref1 = Foundation.NSObject()
    let ref2 = Foundation.NSObject()
    XCTAssertEqual(classMock.method(referenceType: ref1), ref1)
    XCTAssertEqual(classMock.method(referenceType: ref2), ref2)
    verify(classMock.method(valueType: any())).wasNeverCalled()
    verify(classMock.method(bridgedType: any())).wasNeverCalled()
    verify(classMock.method(referenceType: any())).wasCalled(twice)
  }
  
  // MARK: Multiple parameters
  
  func testClassMultipleParameterMethod_matchesHomogenousWildcard() throws {
    given(classMock.method(first: any(), second: any())).will {
      (first: String, second: String) in
      return first + "-" + second
    }
    XCTAssertEqual(classMock.method(first: "a", second: "b"), "a-b")
    verify(classMock.method(first: any(), second: any())).wasCalled()
  }
  
  func testClassMultipleParameterMethod_matchesHomogenousWildcard_explicitIndexes() throws {
    given(classMock.method(first: firstArg(any()), second: secondArg(any()))).will {
      (first: String, second: String) in
      return first + "-" + second
    }
    XCTAssertEqual(classMock.method(first: "a", second: "b"), "a-b")
    verify(classMock.method(first: firstArg(any()), second: secondArg(any()))).wasCalled()
  }
  
  func testClassMultipleParameterMethod_matchesHeterogenousWildcardFirst_explicitIndexes() throws {
    given(classMock.method(first: "a", second: secondArg(any()))).will {
      (first: String, second: String) in
      return first + "-" + second
    }
    XCTAssertEqual(classMock.method(first: "a", second: "b"), "a-b")
    verify(classMock.method(first: "a", second: secondArg(any()))).wasCalled()
  }
  
  func testClassMultipleParameterMethod_matchesHeterogenousWildcardSecond_explicitIndexes() throws {
    given(classMock.method(first: firstArg(any()), second: "b")).will {
      (first: String, second: String) in
      return first + "-" + second
    }
    XCTAssertEqual(classMock.method(first: "a", second: "b"), "a-b")
    verify(classMock.method(first: firstArg(any()), second: "b")).wasCalled()
  }
  
  func testClassMultipleParameterMethod_failsStubbingHeterogenous() throws {
    shouldFail {
      given(self.classMock.method(first: "a", second: any())).willReturn("foo")
    }
    shouldFail {
      given(self.classMock.method(first: any(), second: "b")).willReturn("foo")
    }
  }
  
  func testClassMultipleParameterMethod_failsVerificationHeterogenous() throws {
    shouldFail {
      verify(self.classMock.method(first: "a", second: any())).wasNeverCalled()
    }
    shouldFail {
      verify(self.classMock.method(first: any(), second: "b")).wasNeverCalled()
    }
  }
  
  
  // MARK: - Throwing
  
  func testThrowNSError() throws {
    given(try classMock.throwingMethod())
      .willThrow(NSError(domain: "co.bird.mockingbird.error", code: 1, userInfo: nil))
    XCTAssertThrowsError(try classMock.throwingMethod(), "Mock should throw", { error in
      XCTAssertEqual((error as NSError).domain, "co.bird.mockingbird.error")
      XCTAssertEqual((error as NSError).code, 1)
    })
    verify(try classMock.throwingMethod()).wasCalled()
  }
  
  func testThrowSwiftErrorStruct() throws {
    struct FakeError: LocalizedError {
      let errorDescription: String? = "foobar"
    }
    given(try classMock.throwingMethod()).willThrow(FakeError())
    XCTAssertThrowsError(try classMock.throwingMethod(), "Mock should throw", { error in
      XCTAssertEqual(error.localizedDescription, "foobar")
    })
    verify(try classMock.throwingMethod()).wasCalled()
  }
  
  func testThrowSwiftErrorClass() throws {
    class FakeError: LocalizedError {
      let errorDescription: String? = "foobar"
    }
    given(try classMock.throwingMethod()).willThrow(FakeError())
    XCTAssertThrowsError(try classMock.throwingMethod(), "Mock should throw", { error in
      XCTAssertEqual(error.localizedDescription, "foobar")
    })
    verify(try classMock.throwingMethod()).wasCalled()
  }
  
  func testThrowFromClosure() throws {
    struct FakeError: LocalizedError {
      let errorDescription: String? = "foobar"
    }
    given(try classMock.throwingMethod()).will { throw FakeError() }
    XCTAssertThrowsError(try classMock.throwingMethod(), "Mock should throw", { error in
      XCTAssertEqual(error.localizedDescription, "foobar")
    })
    verify(try classMock.throwingMethod()).wasCalled()
  }
  
  func testThrowingOnNonThrowingMethod() throws {
    struct FakeError: Error {}
    given(classMock.trivialMethod()).willThrow(FakeError())
    classMock.trivialMethod()
    verify(classMock.trivialMethod()).wasCalled()
  }
  
  func testSubclass() throws {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 2
    given(subclassMock.method(valueType: any())).will { (val: Bool) in
      expectation.fulfill()
      return val
    }
    XCTAssertTrue(subclassMock.method(valueType: true))
    XCTAssertFalse(subclassMock.method(valueType: false))
    verify(subclassMock.method(valueType: true)).wasCalled()
    verify(subclassMock.method(valueType: false)).wasCalled()
    verify(subclassMock.method(valueType: any())).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
}
