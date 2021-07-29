//
//  ObjectiveCTests.swift
//  MockingbirdTests
//
//  Created by typealias on 7/28/21.
//

import CoreBluetooth
import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class ObjectiveCTests: BaseTestCase {
  
  var centralManagerMock: CBCentralManager!
  var delegateMock: CBCentralManagerDelegate!
  var peripheralMock: CBPeripheral!
  
  override func setUpWithError() throws {
    self.centralManagerMock = mock(CBCentralManager.self)
    self.delegateMock = mock(CBCentralManagerDelegate.self)
    self.peripheralMock = mock(CBPeripheral.self)
  }
  
  func testReferenceTypePropertyGetterEquatable() throws {
    let uid = "BA6C41BD-E803-4527-A91A-9951ADC57CBF"
    given(peripheralMock.identifier).willReturn(UUID(uuidString: uid))
    XCTAssertEqual(peripheralMock.identifier, UUID(uuidString: uid))
    verify(peripheralMock.identifier).wasCalled()
  }
  func testReferenceTypePropertyGetterEquatable_stubbingOperator() throws {
    let uid = "BA6C41BD-E803-4527-A91A-9951ADC57CBF"
    given(peripheralMock.identifier) ~> UUID(uuidString: uid)
    XCTAssertEqual(peripheralMock.identifier, UUID(uuidString: uid))
    verify(peripheralMock.identifier).wasCalled()
  }
  
  func testReferenceTypePropertyGetterIdentical() throws {
    given(self.centralManagerMock.delegate).willReturn(delegateMock)
    XCTAssertTrue(centralManagerMock.delegate === delegateMock)
  }
  func testReferenceTypePropertyGetterIdentical_stubbingOperator() throws {
    given(self.centralManagerMock.delegate) ~> self.delegateMock
    XCTAssertTrue(centralManagerMock.delegate === delegateMock)
  }
  
  func testBridgedTypePropertyGetter() throws {
    given(peripheralMock.name).willReturn("Ryan")
    XCTAssertEqual(peripheralMock.name, "Ryan")
    verify(peripheralMock.name).wasCalled()
  }
  func testBridgedTypePropertyGetter_stubbingOperator() throws {
    given(peripheralMock.name) ~> "Ryan"
    XCTAssertEqual(peripheralMock.name, "Ryan")
    verify(peripheralMock.name).wasCalled()
  }

  func testMethodWithExactMatching() throws {
    let expectation = XCTestExpectation()
    given(centralManagerMock.cancelPeripheralConnection(peripheralMock)).will {
      (peripheral: CBPeripheral) in
      XCTAssertEqual(peripheral, self.peripheralMock)
      expectation.fulfill()
    }
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    verify(self.centralManagerMock.cancelPeripheralConnection(peripheralMock)).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testMethodWithExactMatching_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(centralManagerMock.cancelPeripheralConnection(peripheralMock)) ~> {
      (peripheral: CBPeripheral) in
      XCTAssertEqual(peripheral, self.peripheralMock)
      expectation.fulfill()
    }
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    verify(self.centralManagerMock.cancelPeripheralConnection(peripheralMock)).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testMethodWithWildcardMatching() throws {
    let expectation = XCTestExpectation()
    given(centralManagerMock.cancelPeripheralConnection(any())).will {
      (peripheral: CBPeripheral) in
      XCTAssertEqual(peripheral, self.peripheralMock)
      expectation.fulfill()
    }
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    verify(self.centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testMethodWithWildcardMatching_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    given(centralManagerMock.cancelPeripheralConnection(any())) ~> {
      (peripheral: CBPeripheral) in
      XCTAssertEqual(peripheral, self.peripheralMock)
      expectation.fulfill()
    }
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    verify(self.centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  func testMethodArgumentCaptor() throws {
    let uid = "BA6C41BD-E803-4527-A91A-9951ADC57CBF"
    given(peripheralMock.identifier).willReturn(UUID(uuidString: uid))
    
    let expectation = XCTestExpectation()
    given(centralManagerMock.cancelPeripheralConnection(any())).will {
      (peripheral: CBPeripheral) in
      XCTAssertEqual(peripheral, self.peripheralMock)
      expectation.fulfill()
    }
    
    centralManagerMock.cancelPeripheralConnection(peripheralMock)

    let peripheralCaptor = ArgumentCaptor<CBPeripheral>()
    verify(centralManagerMock.cancelPeripheralConnection(peripheralCaptor.any())).wasCalled()
    XCTAssertEqual(peripheralCaptor.value?.identifier, UUID(uuidString: uid))
    wait(for: [expectation], timeout: 2)
  }
  func testMethodArgumentCaptor_stubbingOperator() throws {
    let uid = "BA6C41BD-E803-4527-A91A-9951ADC57CBF"
    given(peripheralMock.identifier) ~> UUID(uuidString: uid)
    
    let expectation = XCTestExpectation()
    given(centralManagerMock.cancelPeripheralConnection(any())) ~> {
      (peripheral: CBPeripheral) in
      XCTAssertEqual(peripheral, self.peripheralMock)
      expectation.fulfill()
    }
    
    centralManagerMock.cancelPeripheralConnection(peripheralMock)

    let peripheralCaptor = ArgumentCaptor<CBPeripheral>()
    verify(centralManagerMock.cancelPeripheralConnection(peripheralCaptor.any())).wasCalled()
    XCTAssertEqual(peripheralCaptor.value?.identifier, UUID(uuidString: uid))
    wait(for: [expectation], timeout: 2)
  }
}
