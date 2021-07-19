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

class ObjectiveCTests: BaseTestCase {
  
  var centralManagerMock: CBCentralManager!
  var delegateMock: CBCentralManagerDelegate!
  var peripheralMock: CBPeripheral!
  
  class DelegateMock: Foundation.NSObject, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      print("wtf")
    }
  }
  
  override func setUpWithError() throws {
    self.centralManagerMock = mock(CBCentralManager.self)
    self.delegateMock = mock(CBCentralManagerDelegate.self)
    self.peripheralMock = mock(CBPeripheral.self)
  }
  
  func testExample() throws {
    let uuid = UUID(uuidString: "BA6C41BD-E803-4527-A91A-9951ADC57CBF")
    given(self.peripheralMock.identifier).willReturn(uuid)
    given(
      self.centralManagerMock.cancelPeripheralConnection(
        any(where: { $0.identifier == uuid })
//        self.peripheralMock
      )
    ).will {
      let peripheral = $0 as! CBPeripheral
      print("Hello world! \(peripheral.identifier.uuidString)")
    }
    print("foo")
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    print("bar")
    
    verify(self.centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
  }
  
  func testObjectComparison() throws {
    given(self.centralManagerMock.delegate).willReturn(delegateMock)
    XCTAssertTrue(centralManagerMock.delegate === delegateMock)
  }
  
}
