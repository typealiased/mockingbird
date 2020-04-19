//
//  AmbiguousSynthesizedMembersTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/18/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class AmbiguousSyntheiszedMembersTests: BaseTestCase {
  
  var concreteMock: AmbiguousSynthesizedMembersMock!
  var concreteInstance: AmbiguousSynthesizedMembers { return concreteMock }
  
  override func setUp() {
    concreteMock = mock(AmbiguousSynthesizedMembers.self)
  }
  
  func testSubscriptGetterConflict_disambiguatesSubscript() {
    givenSubscript(concreteMock.getSubscript("foo")) ~> "bar"
    XCTAssertEqual(concreteInstance["foo"], "bar")
    verifySubscript(concreteMock.getSubscript("foo")).wasCalled()
  }
  
  func testSubscriptGetterConflict_disambiguatesMethod() {
    givenMethod(concreteMock.getSubscript("foo")) ~> "bar"
    XCTAssertEqual(concreteInstance.getSubscript("foo"), "bar")
    verifyMethod(concreteMock.getSubscript("foo")).wasCalled()
  }
  
  func testSubscriptSetterConflict_disambiguatesSubscript() {
    var concreteInstance: AmbiguousSynthesizedMembers = concreteMock
    var callCount = 0
    givenSubscript(concreteMock.setSubscript("foo", newValue: "bar")) ~> { _, _ in callCount += 1 }
    concreteInstance["foo"] = "bar"
    verifySubscript(concreteMock.setSubscript("foo", newValue: "bar")).wasCalled()
    XCTAssertEqual(callCount, 1)
  }
  
  func testSubscriptSetterConflict_disambiguatesMethod() {
    var callCount = 0
    givenMethod(concreteMock.setSubscript("foo", newValue: "bar")) ~> { _, _ in callCount += 1 }
    concreteInstance.setSubscript("foo", newValue: "bar")
    verifyMethod(concreteMock.setSubscript("foo", newValue: "bar")).wasCalled()
    XCTAssertEqual(callCount, 1)
  }
  
  func testPropertyGetterConflict_disambiguatesProperty() {
    givenProperty(concreteMock.getProperty()) ~> "bar"
    XCTAssertEqual(concreteInstance.property, "bar")
    verifyProperty(concreteMock.getProperty()).wasCalled()
  }
  
  func testPropertyGetterConflict_disambiguatesMethod() {
    givenMethod(concreteMock.getProperty()) ~> "bar"
    XCTAssertEqual(concreteInstance.getProperty(), "bar")
    verifyMethod(concreteMock.getProperty()).wasCalled()
  }
  
  func testPropertySetterConflict_disambiguatesProperty() {
    var concreteInstance: AmbiguousSynthesizedMembers = concreteMock
    var callCount = 0
    givenProperty(concreteMock.setProperty("bar")) ~> { _ in callCount += 1 }
    concreteInstance.property = "bar"
    verifyProperty(concreteMock.setProperty("bar")).wasCalled()
    XCTAssertEqual(callCount, 1)
  }
  
  func testPropertySetterConflict_disambiguatesMethod() {
    var callCount = 0
    givenMethod(concreteMock.setProperty("bar")) ~> { _ in callCount += 1 }
    concreteInstance.setProperty("bar")
    verifyMethod(concreteMock.setProperty("bar")).wasCalled()
    XCTAssertEqual(callCount, 1)
  }
}
