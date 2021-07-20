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

@objc public class MyObjCTestClass: Foundation.NSObject {
  @objc dynamic func echo(val: Bool) -> Bool {
    fatalError()
  }
  @objc dynamic func prim(val: String) -> String {
    fatalError()
  }
  @objc dynamic public func trivial() {}
}

class ObjectiveCTests: BaseTestCase {
  
  var centralManagerMock: CBCentralManager!
  var delegateMock: CBCentralManagerDelegate!
  var peripheralMock: CBPeripheral!
  var testMock: MyObjCTestClass!
  
  override func setUpWithError() throws {
    self.centralManagerMock = mock(CBCentralManager.self)
    self.delegateMock = mock(CBCentralManagerDelegate.self)
    self.peripheralMock = mock(CBPeripheral.self)
    self.testMock = mock(MyObjCTestClass.self)
  }
  
  func testPrimitives() throws {
//    given(self.testMock.trivial()).willReturn()
    given(self.testMock.echo(val: any(at: 0))).will { val in
      return val as! Bool
    }
    XCTAssertTrue(testMock.echo(val: true))
    XCTAssertFalse(testMock.echo(val: false))
    verify(self.testMock.echo(val: true)).wasCalled()
    verify(self.testMock.echo(val: false)).wasCalled()
    
    given(self.testMock.prim(val: any(at: 0))).will { val in
      return (val as! String).uppercased()
    }
    XCTAssertEqual(testMock.prim(val: "hello, world"), "HELLO, WORLD")
    verify(self.testMock.prim(val: any(at: 0))).wasCalled()
    
    given(self.testMock.prim(val: "foobar")).willReturn("barfoo")
    XCTAssertEqual(testMock.prim(val: "foobar"), "barfoo")
    verify(self.testMock.prim(val: "foobar")).wasCalled()
  }
  
  func testExample() throws {
    given(self.peripheralMock.identifier)
      .willReturn(UUID(uuidString: "BA6C41BD-E803-4527-A91A-9951ADC57CBF"))
    given(self.peripheralMock.name).willReturn("foobar")
    
    XCTAssertEqual(peripheralMock.identifier, UUID(uuidString: "BA6C41BD-E803-4527-A91A-9951ADC57CBF"))
    XCTAssertEqual(peripheralMock.name, "foobar")
    
    verify(self.peripheralMock.identifier).wasCalled()
    verify(self.peripheralMock.name).wasCalled()
    
    given(
      self.centralManagerMock.cancelPeripheralConnection(
        any(where: { $0.identifier.uuidString == "BA6C41BD-E803-4527-A91A-9951ADC57CBF" })
      )
    ).will {
      let peripheral = $0 as! CBPeripheral
      print("Hello world! \(peripheral.identifier.uuidString)")
    }
    
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    
    verify(self.centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
    verify(self.centralManagerMock.cancelPeripheralConnection(self.peripheralMock)).wasCalled()
    
    let peripheralCaptor = ArgumentCaptor<CBPeripheral>()
    verify(self.centralManagerMock.cancelPeripheralConnection(peripheralCaptor.any())).wasCalled()
    XCTAssertEqual(peripheralCaptor.value?.name, "foobar")
  }
  
  func testObjectComparison() throws {
    given(self.centralManagerMock.delegate).willReturn(delegateMock)
    XCTAssertTrue(centralManagerMock.delegate === delegateMock)
  }
  
}
