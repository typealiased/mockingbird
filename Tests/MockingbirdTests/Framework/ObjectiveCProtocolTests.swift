import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class ObjectiveCProtocolTests: BaseTestCase {
  
  var protocolMock: ObjCProtocolMock!
  var protocolInstance: ObjCProtocol { protocolMock }
  
  var protocolFake = ObjCProtocolFake()
  
  class ObjCProtocolFake: Foundation.NSObject, ObjCProtocol {
    func trivial() {}
    func parameterizedReturning(param: String) -> Bool { true }
    
    var property: Bool { true }
    var readwriteProperty: Bool = true
    
    func optionalTrivial() {}
    func optionalParameterizedReturning(param: String) -> Bool { true }
    
    var optionalProperty: Bool { true }
    var optionalReadwriteProperty: Bool = true
    
    subscript(param: Int) -> Bool {
      get { true }
      set {}
    }
  }
  
  override func setUpWithError() throws {
    self.protocolMock = mock(ObjCProtocol.self).initialize()
  }
  
  
  // MARK: - Resetting
  
  func testResetMock() {
    protocolInstance.trivial()
    reset(protocolMock)
    verify(protocolMock.trivial()).wasNeverCalled()
  }
  
  func testClearStubs() {
    given(protocolInstance.parameterizedReturning(param: any())).willReturn(true)
    clearStubs(on: protocolMock)
    shouldFail {
      _ = protocolInstance.parameterizedReturning(param: "foobar")
    }
  }
  
  func testClearInvocations() {
    protocolInstance.trivial()
    clearInvocations(on: protocolMock)
    verify(protocolMock.trivial()).wasNeverCalled()
  }
  
  
  // MARK: - Concrete stubs
  
  func testTrivial() {
    given(protocolMock.trivial()).willReturn()
    protocolInstance.trivial()
    verify(protocolMock.trivial()).wasCalled()
  }
  func testOptionalTrivial() {
    given(protocolMock.optionalTrivial()).willReturn()
    protocolInstance.optionalTrivial?()
    verify(protocolMock.optionalTrivial()).wasCalled()
  }
  
  func testParameterized() {
    given(protocolMock.parameterizedReturning(param: any())).willReturn(true)
    XCTAssertTrue(protocolInstance.parameterizedReturning(param: "foobar"))
    verify(protocolMock.parameterizedReturning(param: any())).wasCalled()
  }
  func testOptionalParameterized() {
    given(protocolMock.optionalParameterizedReturning(param: any())).willReturn(true)
    XCTAssertTrue(protocolInstance.optionalParameterizedReturning?(param: "foobar") ?? false)
    verify(protocolMock.optionalParameterizedReturning(param: any())).wasCalled()
  }
  
  func testPropertyGetter() {
    given(protocolMock.property).willReturn(true)
    XCTAssertTrue(protocolInstance.property)
    verify(protocolMock.property).wasCalled()
  }
  func testOptionalPropertyGetter() {
    given(protocolMock.optionalProperty).willReturn(true)
    XCTAssertTrue(protocolInstance.optionalProperty ?? false)
    verify(protocolMock.optionalProperty).wasCalled()
  }
  
  func testPropertySetter() {
    let expectation = expectation(description: "setter was called")
    given(protocolMock.readwriteProperty = any()).will { (_: Bool) in expectation.fulfill() }
    protocolInstance.readwriteProperty = true
    verify(protocolMock.readwriteProperty = any()).wasCalled()
    waitForExpectations(timeout: 1)
  }
  
  func testOptionalSubscriptGetter() {
    given(protocolMock[any()]).willReturn(true)
    XCTAssertTrue(protocolInstance[1] ?? false)
    verify(protocolMock[any()]).wasCalled()
  }
  
  
  // MARK: - Object partial mock
  
  func testTrivialGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    protocolInstance.trivial()
    verify(protocolMock.trivial()).wasCalled()
  }
  func testTrivialLocalForwarding() {
    given(protocolMock.trivial()).willForward(to: protocolFake)
    protocolInstance.trivial()
    verify(protocolMock.trivial()).wasCalled()
  }
  
  func testParameterizedGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    XCTAssertTrue(protocolInstance.parameterizedReturning(param: "foobar"))
    verify(protocolMock.parameterizedReturning(param: any())).wasCalled()
  }
  func testParameterizedLocalForwarding() {
    given(protocolMock.parameterizedReturning(param: any())).willForward(to: protocolFake)
    XCTAssertTrue(protocolInstance.parameterizedReturning(param: "foobar"))
    verify(protocolMock.parameterizedReturning(param: any())).wasCalled()
  }
  
  func testPropertyGetterGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    XCTAssertTrue(protocolInstance.property)
    verify(protocolMock.property).wasCalled()
  }
  func testPropertyGetterLocalForwarding() {
    given(protocolMock.property).willForward(to: protocolFake)
    XCTAssertTrue(protocolInstance.property)
    verify(protocolMock.property).wasCalled()
  }
  
  func testPropertySetterGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    let instance = protocolMock as ObjCProtocol
    instance.readwriteProperty = true
    verify(protocolMock.readwriteProperty = any()).wasCalled()
  }
  func testPropertySetterLocalForwarding() {
    given(protocolMock.readwriteProperty = any()).willForward(to: protocolFake)
    let instance = protocolMock as ObjCProtocol
    instance.readwriteProperty = true
    verify(protocolMock.readwriteProperty = any()).wasCalled()
  }
  
  // MARK: Optionals
  
  func testOptionalTrivialGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    protocolInstance.optionalTrivial?()
    verify(protocolMock.optionalTrivial()).wasCalled()
  }
  func testOptionalTrivialLocalForwarding() {
    given(protocolMock.optionalTrivial()).willForward(to: protocolFake)
    protocolInstance.optionalTrivial?()
    verify(protocolMock.optionalTrivial()).wasCalled()
  }
  
  func testOptionalParameterizedGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    XCTAssertTrue(protocolInstance.optionalParameterizedReturning?(param: "foobar") ?? false)
    verify(protocolMock.optionalParameterizedReturning(param: any())).wasCalled()
  }
  func testOptionalParameterizedLocalForwarding() {
    given(protocolMock.optionalParameterizedReturning(param: any())).willForward(to: protocolFake)
    XCTAssertTrue(protocolInstance.optionalParameterizedReturning?(param: "foobar") ?? false)
    verify(protocolMock.optionalParameterizedReturning(param: any())).wasCalled()
  }
  
  func testOptionalPropertyGetterGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    XCTAssertTrue(protocolInstance.optionalProperty ?? false)
    verify(protocolMock.optionalProperty).wasCalled()
  }
  func testOptionalPropertyGetterLocalForwarding() {
    given(protocolMock.optionalProperty).willForward(to: protocolFake)
    XCTAssertTrue(protocolInstance.optionalProperty ?? false)
    verify(protocolMock.optionalProperty).wasCalled()
  }
  
  func testOptionalSubscriptGetterGlobalForwarding() {
    protocolMock.forwardCalls(to: protocolFake)
    XCTAssertTrue(protocolInstance[1] ?? false)
    verify(protocolMock[any()]).wasCalled()
  }
  func testOptionalSubscriptGetterLocalForwarding() {
    given(protocolMock[any()]).willForward(to: protocolFake)
    XCTAssertTrue(protocolInstance[1] ?? false)
    verify(protocolMock[any()]).wasCalled()
  }
}
