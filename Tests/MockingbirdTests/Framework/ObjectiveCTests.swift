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
  @objc dynamic func throwing() throws {}
  @objc dynamic public func trivial() {}
  
  @objc dynamic var name: String = ""
}

public class MyObjCTestSubclass: MyObjCTestClass {}

class ObjectiveCTests: BaseTestCase {
  
  var centralManagerMock: CBCentralManager!
  var delegateMock: CBCentralManagerDelegate!
  var peripheralMock: CBPeripheral!
  var testMock: MyObjCTestClass!
  var subclassMock: MyObjCTestSubclass!
  
  override func setUpWithError() throws {
    self.centralManagerMock = mock(CBCentralManager.self)
    self.delegateMock = mock(CBCentralManagerDelegate.self)
    self.peripheralMock = mock(CBPeripheral.self)
    self.testMock = mock(MyObjCTestClass.self)
    self.subclassMock = mock(MyObjCTestSubclass.self)
  }
  
  func testPrimitives() throws {
//    given(self.testMock.trivial()).willReturn()
    given(
      self.testMock.echo(val: firstArg(any()))
    ).will { (val: Bool) in
      return val
    }
    XCTAssertTrue(testMock.echo(val: true))
    XCTAssertFalse(testMock.echo(val: false))
    verify(self.testMock.echo(val: true)).wasCalled()
    verify(self.testMock.echo(val: false)).wasCalled()
    
    given(self.testMock.prim(val: firstArg(any()))).will { (val: String) in
      return val.uppercased()
    }
    XCTAssertEqual(testMock.prim(val: "hello, world"), "HELLO, WORLD")
    verify(self.testMock.prim(val: firstArg(any()))).wasCalled()
    
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
    ).will { (peripheral: CBPeripheral) in
      print("Hello world! \(peripheral.identifier.uuidString)")
    }
    
    centralManagerMock.cancelPeripheralConnection(peripheralMock)
    
    verify(self.centralManagerMock.cancelPeripheralConnection(any())).wasCalled()
    verify(self.centralManagerMock.cancelPeripheralConnection(self.peripheralMock)).wasCalled()
    
    let peripheralCaptor = ArgumentCaptor<CBPeripheral>()
    verify(self.centralManagerMock.cancelPeripheralConnection(peripheralCaptor.any())).wasCalled()
    XCTAssertEqual(peripheralCaptor.value?.name, "foobar")
  }
  
  func testPropertySetter() throws {
    given(self.testMock.name = firstArg(any())).will { (name: String) in
      print("Set name to \(name)")
    }
    testMock.name = "foo"
    verify(self.testMock.name = "foo").wasCalled()
  }
  
  func testThrowNSError() throws {
    given(try self.testMock.throwing())
      .willThrow(NSError(domain: "co.bird.mockingbird.error", code: 1, userInfo: nil))
    XCTAssertThrowsError(try testMock.throwing(), "Mock should throw", { error in
      XCTAssertEqual((error as NSError).domain, "co.bird.mockingbird.error")
      XCTAssertEqual((error as NSError).code, 1)
    })
    verify(try self.testMock.throwing()).wasCalled()
  }
  
  func testThrowSwiftErrorStruct() throws {
    struct FakeError: LocalizedError {
      let errorDescription: String? = "foobar"
    }
    given(try self.testMock.throwing()).willThrow(FakeError())
    XCTAssertThrowsError(try testMock.throwing(), "Mock should throw", { error in
      XCTAssertEqual(error.localizedDescription, "foobar")
    })
    verify(try self.testMock.throwing()).wasCalled()
  }
  
  func testThrowSwiftErrorClass() throws {
    class FakeError: LocalizedError {
      let errorDescription: String? = "foobar"
    }
    given(try self.testMock.throwing()).willThrow(FakeError())
    XCTAssertThrowsError(try testMock.throwing(), "Mock should throw", { error in
      XCTAssertEqual(error.localizedDescription, "foobar")
    })
    verify(try self.testMock.throwing()).wasCalled()
  }
  
  func testThrowFromClosure() throws {
    struct FakeError: LocalizedError {
      let errorDescription: String? = "foobar"
    }
    given(try self.testMock.throwing()).will { throw FakeError() }
    XCTAssertThrowsError(try testMock.throwing(), "Mock should throw", { error in
      XCTAssertEqual(error.localizedDescription, "foobar")
    })
    verify(try self.testMock.throwing()).wasCalled()
  }
  
  func testThrowingOnNonThrowingMethod() throws {
    struct FakeError: Error {}
    given(self.testMock.trivial()).willThrow(FakeError())
    testMock.trivial()
    verify(self.testMock.trivial()).wasCalled()
  }
  
  func testSubclass() throws {
    given(self.subclassMock.echo(val: firstArg(any()))).will { (val: Bool) in
      return val
    }
    XCTAssertTrue(subclassMock.echo(val: true))
    XCTAssertFalse(subclassMock.echo(val: false))
    verify(self.subclassMock.echo(val: firstArg(any()))).wasCalled(twice)
  }
  
  func testObjectComparison() throws {
    given(self.centralManagerMock.delegate).willReturn(delegateMock)
    XCTAssertTrue(centralManagerMock.delegate === delegateMock)
  }
  
}
