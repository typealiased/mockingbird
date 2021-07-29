//
//  ObjectiveCTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/17/21.
//

import CoreBluetooth
import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

@objc public class MinimalObjCClass: Foundation.NSObject {
  @objc dynamic func method(valueType: Bool) -> Bool { fatalError() }
  @objc dynamic func method(bridgedType: String) -> String { fatalError() }
  @objc dynamic func method(referenceType: MinimalObjCClass) -> MinimalObjCClass { fatalError() }
  
  @objc dynamic func throwingMethod() throws {}
  @objc dynamic public func trivialMethod() {}
  
  @objc dynamic var valueTypeProperty = false
  @objc dynamic var bridgedTypeProperty = ""
  @objc dynamic var referenceTypeProperty = MinimalObjCClass()
}

public class MinimalObjCSubclass: MinimalObjCClass {}

class ObjectiveCTests: BaseTestCase {
  
  var centralManagerMock: CBCentralManager!
  var delegateMock: CBCentralManagerDelegate!
  var peripheralMock: CBPeripheral!
  
  var classMock: MinimalObjCClass!
  var subclassMock: MinimalObjCSubclass!
  
  override func setUpWithError() throws {
    self.centralManagerMock = mock(CBCentralManager.self)
    self.delegateMock = mock(CBCentralManagerDelegate.self)
    self.peripheralMock = mock(CBPeripheral.self)
    self.classMock = mock(MinimalObjCClass.self)
    self.subclassMock = mock(MinimalObjCSubclass.self)
  }
  
  
  // MARK: - Swift
  
  // MARK: Primitive types
  
  func testClassPrimitivePropertyGetter() throws {
    given(classMock.valueTypeProperty).willReturn(true)
    XCTAssertTrue(classMock.valueTypeProperty)
    verify(classMock.valueTypeProperty).wasCalled()
  }
  func testClassPrimitivePropertyGetter_stubbingOperator() throws {
    given(classMock.valueTypeProperty) ~> true
    XCTAssertTrue(classMock.valueTypeProperty)
    verify(classMock.valueTypeProperty).wasCalled()
  }
  
  func testClassPrimitivePropertySetter() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = true).will { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = true).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassPrimitivePropertySetter_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = true) ~> { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = true).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testClassPrimitivePropertySetterMatchesWildcard() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = firstArg(any())).will { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = firstArg(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassPrimitivePropertySetterMatchesWildcard_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.valueTypeProperty = firstArg(any())) ~> { (newValue: Bool) in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    classMock.valueTypeProperty = true
    verify(classMock.valueTypeProperty = firstArg(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  // MARK: Bridged
  
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
    given(classMock.bridgedTypeProperty = firstArg(any())).will { (newValue: String) in
      XCTAssertEqual(newValue, "Ryan")
      expectation.fulfill()
    }
    classMock.bridgedTypeProperty = "Ryan"
    verify(classMock.bridgedTypeProperty = firstArg(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testClassBridgedPropertySetterMatchesWildcard_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(classMock.bridgedTypeProperty = firstArg(any())) ~> { (newValue: String) in
      XCTAssertEqual(newValue, "Ryan")
      expectation.fulfill()
    }
    classMock.bridgedTypeProperty = "Ryan"
    verify(classMock.bridgedTypeProperty = firstArg(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
    
//    given(classMock.trivial()).willReturn()
//    given(
//      classMock.echo(val: firstArg(any()))
//    ).will { (val: Bool) in
//      return val
//    }
//    XCTAssertTrue(testMock.echo(val: true))
//    XCTAssertFalse(testMock.echo(val: false))
//    verify(classMock.echo(val: true)).wasCalled()
//    verify(classMock.echo(val: false)).wasCalled()
//    
//    given(classMock.prim(val: firstArg(any()))).will { (val: String) in
//      return val.uppercased()
//    }
//    XCTAssertEqual(testMock.prim(val: "hello, world"), "HELLO, WORLD")
//    verify(classMock.prim(val: firstArg(any()))).wasCalled()
//    
//    given(classMock.prim(val: "foobar")).willReturn("barfoo")
//    XCTAssertEqual(testMock.prim(val: "foobar"), "barfoo")
//    verify(classMock.prim(val: "foobar")).wasCalled()
//  }
//  
//  func testExample() throws {
//    given(self.peripheralMock.identifier)
//      .willReturn(UUID(uuidString: "BA6C41BD-E803-4527-A91A-9951ADC57CBF"))
//    given(self.peripheralMock.name).willReturn("foobar")
//    
//    XCTAssertEqual(peripheralMock.identifier, UUID(uuidString: "BA6C41BD-E803-4527-A91A-9951ADC57CBF"))
//    XCTAssertEqual(peripheralMock.name, "foobar")
//    
//    verify(self.peripheralMock.identifier).wasCalled()
//    verify(self.peripheralMock.name).wasCalled()
//    
//    given(
//      self.centralManagerMock.cancelPeripheralConnection(
//        any(where: { $0.identifier.uuidString == "BA6C41BD-E803-4527-A91A-9951ADC57CBF" })
//      )
//    ).will { (peripheral: CBPeripheral) in
//      print("Hello world! \(peripheral.identifier.uuidString)")
//    }
//    
//    centralManagerMock.cancelPeripheralConnection(peripheralMock)
//    
//    verify(self.centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
//    verify(self.centralManagerMock.cancelPeripheralConnection(self.peripheralMock)).wasCalled()
//    
//    let peripheralCaptor = ArgumentCaptor<CBPeripheral>()
//    verify(self.centralManagerMock.cancelPeripheralConnection(peripheralCaptor.any())).wasCalled()
//    XCTAssertEqual(peripheralCaptor.value?.name, "foobar")
//  }
  
  
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
    given(subclassMock.method(valueType: firstArg(any()))).will { (val: Bool) in
      expectation.fulfill()
      return val
    }
    XCTAssertTrue(subclassMock.method(valueType: true))
    XCTAssertFalse(subclassMock.method(valueType: false))
    verify(subclassMock.method(valueType: true)).wasCalled()
    verify(subclassMock.method(valueType: false)).wasCalled()
    verify(subclassMock.method(valueType: firstArg(any()))).wasCalled(twice)
    wait(for: [expectation], timeout: 2)
  }
  
  func testObjectComparison() throws {
    given(self.centralManagerMock.delegate).willReturn(delegateMock)
    XCTAssertTrue(centralManagerMock.delegate === delegateMock)
  }
  
}
