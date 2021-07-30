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
  
  
  // MARK: - Invocation forwarding
  
  func testForwardGetterInvocation() throws {
    let uid = "BA6C41BD-E803-4527-A91A-9951ADC57CBF"
    let target = mock(CBPeripheral.self)
    given(target.identifier).willReturn(UUID(uuidString: uid))
    
    given(peripheralMock.identifier).willForward(to: target)
    XCTAssertEqual(peripheralMock.identifier, UUID(uuidString: uid))
    
    verify(peripheralMock.identifier).wasCalled()
    verify(target.identifier).wasCalled()
  }
  func testForwardGetterInvocation_stubbingOperator() throws {
    let uid = "BA6C41BD-E803-4527-A91A-9951ADC57CBF"
    let target = mock(CBPeripheral.self)
    given(target.identifier) ~> UUID(uuidString: uid)
    
    given(peripheralMock.identifier) ~> forward(to: target)
    XCTAssertEqual(peripheralMock.identifier, UUID(uuidString: uid))
    
    verify(peripheralMock.identifier).wasCalled()
    verify(target.identifier).wasCalled()
  }
  
  func testForwardMethodInvocation() throws {
    let expectation = XCTestExpectation()
    let target = mock(CBCentralManager.self)
    given(target.cancelPeripheralConnection(any())).will { expectation.fulfill() }
    
    given(centralManagerMock.cancelPeripheralConnection(any())).willForward(to: target)
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    
    verify(centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
    verify(target.cancelPeripheralConnection(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  func testForwardMethodInvocation_stubbingOperator() throws {
    let expectation = XCTestExpectation()
    let target = mock(CBCentralManager.self)
    given(target.cancelPeripheralConnection(any())) ~> { expectation.fulfill() }
    
    given(centralManagerMock.cancelPeripheralConnection(any())) ~> forward(to: target)
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    
    verify(centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
    verify(target.cancelPeripheralConnection(any())).wasCalled()
    wait(for: [expectation], timeout: 2)
  }
  
  
  // MARK: - Mock resetting
  
  func testResetEntireContext() throws {
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    verify(centralManagerMock.cancelPeripheralConnection(peripheralMock)).wasCalled()
    reset(centralManagerMock)
    verify(centralManagerMock.cancelPeripheralConnection(peripheralMock)).wasNeverCalled()
  }
  
  func testClearInvocations() throws {
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    verify(centralManagerMock.cancelPeripheralConnection(peripheralMock)).wasCalled()
    clearInvocations(on: centralManagerMock)
    verify(centralManagerMock.cancelPeripheralConnection(peripheralMock)).wasNeverCalled()
  }
  
  func testClearStubs() throws {
    given(centralManagerMock.isScanning).willReturn(true)
    XCTAssertTrue(centralManagerMock.isScanning)
    clearStubs(on: centralManagerMock)
    shouldFail {
      _ = self.centralManagerMock.isScanning
    }
  }
}
