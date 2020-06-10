//
//  SubscriptTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/18/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class SubscriptTests: BaseTestCase {
  
  var protocolMock: SubscriptedProtocolMock!
  var protocolInstance: SubscriptedProtocol { return protocolMock }
  
  var classMock: SubscriptedClassMock!
  var classInstance: SubscriptedClass { return classMock }
  
  override func setUp() {
    protocolMock = mock(SubscriptedProtocol.self)
    classMock = mock(SubscriptedClass.self)
  }
  
  // MARK: - Protocol mock
  
  // MARK: Getter
  
  func testSubscriptProtocol_handlesBasicSingleParameterGetter() {
    given(protocolMock.getSubscript(42)) ~> "bar"
    given(protocolMock.getSubscript(42)) ~> true
    given(protocolMock.getSubscript("foo")) ~> "bar"
    given(protocolMock.getSubscript(42)) ~> 99
    
    XCTAssertEqual(protocolInstance[42], "bar")
    XCTAssertEqual(protocolInstance[42], true)
    XCTAssertEqual(protocolInstance["foo"], "bar")
    XCTAssertEqual(protocolInstance[42], 99)
    
    verify(protocolMock.getSubscript(42)).returning(String.self).wasCalled()
    verify(protocolMock.getSubscript(42)).returning(Bool.self).wasCalled()
    verify(protocolMock.getSubscript("foo")).returning(String.self).wasCalled()
    verify(protocolMock.getSubscript(42)).returning(Int.self).wasCalled()
  }
  
  func testSubscriptProtocol_handlesMultipleParameterGetter() {
    given(protocolMock.getSubscript(42, 99)) ~> "bar"
    given(protocolMock.getSubscript("foo", "bar")) ~> "hello"
    
    XCTAssertEqual(protocolInstance[42, 99], "bar")
    XCTAssertEqual(protocolInstance["foo", "bar"], "hello")
    
    verify(protocolMock.getSubscript(42, 99)).returning(String.self).wasCalled()
    verify(protocolMock.getSubscript("foo", "bar")).returning(String.self).wasCalled()
  }
  
  func testSubscriptProtocol_handlesGenericGetter() {
    enum IndexType { case foo, bar }
    given(protocolMock.getSubscript(IndexType.foo)) ~> IndexType.bar
    XCTAssertEqual(protocolInstance[IndexType.foo], IndexType.bar)
    verify(protocolMock.getSubscript(IndexType.foo)).returning(IndexType.self).wasCalled()
  }
  
  // MARK: Setter
  
  func testSubscriptProtocol_handlesBasicSingleParameterSetter() {
    var protocolInstance: SubscriptedProtocol = protocolMock // Allow subscript mutations
    var callCount = 0
    
    given(protocolMock.setSubscript(42, newValue: "bar")) ~> { _, _ in callCount += 1 }
    given(protocolMock.setSubscript(42, newValue: true)) ~> { _, _ in callCount += 1 }
    given(protocolMock.setSubscript("foo", newValue: "bar")) ~> { _, _ in callCount += 1 }
    
    protocolInstance[42] = "bar"
    protocolInstance[42] = true
    protocolInstance["foo"] = "bar"
    
    verify(protocolMock.setSubscript(42, newValue: "bar")).wasCalled()
    verify(protocolMock.setSubscript(42, newValue: true)).wasCalled()
    verify(protocolMock.setSubscript("foo", newValue: "bar")).wasCalled()
    
    XCTAssertEqual(callCount, 3)
  }
  
  func testSubscriptProtocol_handlesMultipleParameterSetter() {
    var protocolInstance: SubscriptedProtocol = protocolMock // Allow subscript mutations
    var callCount = 0
    
    given(protocolMock.setSubscript(42, 99, newValue: "bar")) ~> { _, _, _ in callCount += 1 }
    given(protocolMock.setSubscript("foo", "bar", newValue: "hello")) ~> { _, _ in callCount += 1 }
    
    protocolInstance[42, 99] = "bar"
    protocolInstance["foo", "bar"] = "hello"
    
    verify(protocolMock.setSubscript(42, 99, newValue: "bar")).wasCalled()
    verify(protocolMock.setSubscript("foo", "bar", newValue: "hello")).wasCalled()
    
    XCTAssertEqual(callCount, 2)
  }
  
  func testSubscriptProtocol_handlesGenericSetter() {
    enum IndexType { case foo, bar }
    var protocolInstance: SubscriptedProtocol = protocolMock // Allow subscript mutations
    var callCount = 0
    
    given(protocolMock.setSubscript(IndexType.foo, newValue: IndexType.bar)) ~> { _, _ in
      callCount += 1
    }
    protocolInstance[IndexType.foo] = IndexType.bar
    verify(protocolMock.setSubscript(IndexType.foo, newValue: IndexType.bar)).wasCalled()
    
    XCTAssertEqual(callCount, 1)
  }
  
  
  // MARK: - Class mock
  
  func testSubscriptClass_handlesBasicSingleParameterCalls() {
    given(classMock.getSubscript(42)) ~> "bar"
    given(classMock.getSubscript(42)) ~> true
    given(classMock.getSubscript("foo")) ~> "bar"
    given(classMock.getSubscript(42)) ~> 99
    
    XCTAssertEqual(classInstance[42], "bar")
    XCTAssertEqual(classInstance[42], true)
    XCTAssertEqual(classInstance["foo"], "bar")
    XCTAssertEqual(classInstance[42], 99)
    
    verify(classMock.getSubscript(42)).returning(String.self).wasCalled()
    verify(classMock.getSubscript(42)).returning(Bool.self).wasCalled()
    verify(classMock.getSubscript("foo")).returning(String.self).wasCalled()
    verify(classMock.getSubscript(42)).returning(Int.self).wasCalled()
  }
  
  func testSubscriptClass_handlesMultipleParameterCalls() {
    given(classMock.getSubscript(42, 99)) ~> "bar"
    given(classMock.getSubscript("foo", "bar")) ~> "hello"
    
    XCTAssertEqual(classInstance[42, 99], "bar")
    XCTAssertEqual(classInstance["foo", "bar"], "hello")
    
    verify(classMock.getSubscript(42, 99)).returning(String.self).wasCalled()
    verify(classMock.getSubscript("foo", "bar")).returning(String.self).wasCalled()
  }
  
  func testSubscriptClass_handlesGenericCalls() {
    enum IndexType { case foo, bar }
    given(classMock.getSubscript(IndexType.foo)) ~> IndexType.bar
    XCTAssertEqual(classInstance[IndexType.foo], IndexType.bar)
    verify(classMock.getSubscript(IndexType.foo)).returning(IndexType.self).wasCalled()
  }
  
  // MARK: Setter
  
  func testSubscriptClass_handlesBasicSingleParameterSetter() {
    var callCount = 0
    
    given(classMock.setSubscript(42, newValue: "bar")) ~> { _, _ in callCount += 1 }
    given(classMock.setSubscript(42, newValue: true)) ~> { _, _ in callCount += 1 }
    given(classMock.setSubscript("foo", newValue: "bar")) ~> { _, _ in callCount += 1 }
    
    classInstance[42] = "bar"
    classInstance[42] = true
    classInstance["foo"] = "bar"
    
    verify(classMock.setSubscript(42, newValue: "bar")).wasCalled()
    verify(classMock.setSubscript(42, newValue: true)).wasCalled()
    verify(classMock.setSubscript("foo", newValue: "bar")).wasCalled()
    
    XCTAssertEqual(callCount, 3)
  }
  
  func testSubscriptClass_handlesMultipleParameterSetter() {
    var callCount = 0
    
    given(classMock.setSubscript(42, 99, newValue: "bar")) ~> { _, _, _ in callCount += 1 }
    given(classMock.setSubscript("foo", "bar", newValue: "hello")) ~> { _, _ in callCount += 1 }
    
    classInstance[42, 99] = "bar"
    classInstance["foo", "bar"] = "hello"
    
    verify(classMock.setSubscript(42, 99, newValue: "bar")).wasCalled()
    verify(classMock.setSubscript("foo", "bar", newValue: "hello")).wasCalled()
    
    XCTAssertEqual(callCount, 2)
  }
  
  func testSubscriptClass_handlesGenericSetter() {
    enum IndexType { case foo, bar }
    var callCount = 0
    
    given(classMock.setSubscript(IndexType.foo, newValue: IndexType.bar)) ~> { _, _ in
      callCount += 1
    }
    classInstance[IndexType.foo] = IndexType.bar
    verify(classMock.setSubscript(IndexType.foo, newValue: IndexType.bar)).wasCalled()
    
    XCTAssertEqual(callCount, 1)
  }
}
