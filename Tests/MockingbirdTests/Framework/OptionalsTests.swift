import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

class OptionalsTests: BaseTestCase {
  
  var optionalsMock: OptionalsProtocolMock!
  var optionalsInstance: OptionalsProtocol { optionalsMock }
  
  override func setUpWithError() throws {
    self.optionalsMock = mock(OptionalsProtocol.self)
  }
  
  func testStubNonNilReturnValue() {
    given(optionalsMock.methodWithOptionalReturn()).willReturn(true)
    XCTAssertEqual(optionalsInstance.methodWithOptionalReturn(), true)
    verify(optionalsMock.methodWithOptionalReturn()).wasCalled()
  }
  func testStubNonNilReturnValue_stubbingOperator() {
    given(optionalsMock.methodWithOptionalReturn()) ~> true
    XCTAssertEqual(optionalsInstance.methodWithOptionalReturn(), true)
    verify(optionalsMock.methodWithOptionalReturn()).wasCalled()
  }
  
  func testStubNilReturnValue() {
    given(optionalsMock.methodWithOptionalReturn()).willReturn(nil)
    XCTAssertNil(optionalsInstance.methodWithOptionalReturn())
    verify(optionalsMock.methodWithOptionalReturn()).wasCalled()
  }
  func testStubNilReturnValue_stubbingOperator() {
    given(optionalsMock.methodWithOptionalReturn()) ~> nil
    XCTAssertNil(optionalsInstance.methodWithOptionalReturn())
    verify(optionalsMock.methodWithOptionalReturn()).wasCalled()
  }
    
  func testStubNestedOptionalPropertyWithNilReturnValue() {
    given(optionalsMock.nestedOptionalVariable).willReturn(nil)
    XCTAssertEqual(optionalsInstance.nestedOptionalVariable, nil)
    verify(optionalsMock.nestedOptionalVariable).wasCalled()
  }
  func testStubNestedOptionalPropertyWithNilReturnValue_stubbingOperator() {
    given(optionalsMock.nestedOptionalVariable) ~> nil
    XCTAssertEqual(optionalsInstance.nestedOptionalVariable, nil)
    verify(optionalsMock.nestedOptionalVariable).wasCalled()
  }
  
  func testStubNestedOptionalPropertyWithWrappedNilReturnValue() {
    given(optionalsMock.nestedOptionalVariable).willReturn(Optional<Bool>(nil))
    XCTAssertEqual(optionalsInstance.nestedOptionalVariable, Optional<Bool>(nil))
    verify(optionalsMock.nestedOptionalVariable).wasCalled()
  }
  func testStubNestedOptionalPropertyWithWrappedNilReturnValue_stubbingOperator() {
    given(optionalsMock.nestedOptionalVariable) ~> Optional<Bool>(nil)
    XCTAssertEqual(optionalsInstance.nestedOptionalVariable, Optional<Bool>(nil))
    verify(optionalsMock.nestedOptionalVariable).wasCalled()
  }
  
  func testStubNonNilBridgedReturnValue() {
    given(optionalsMock.methodWithOptionalBridgedReturn()).willReturn("foobar")
    XCTAssertEqual(optionalsInstance.methodWithOptionalBridgedReturn(), "foobar")
    verify(optionalsMock.methodWithOptionalBridgedReturn()).wasCalled()
  }
  func testStubNonNilBridgedReturnValue_stubbingOperator() {
    given(optionalsMock.methodWithOptionalBridgedReturn()) ~> ("foobar" as NSString?)
    XCTAssertEqual(optionalsInstance.methodWithOptionalBridgedReturn(), "foobar")
    verify(optionalsMock.methodWithOptionalBridgedReturn()).wasCalled()
  }
  
  func testStubNilBridgedReturnValue() {
    given(optionalsMock.methodWithOptionalBridgedReturn()).willReturn(nil)
    XCTAssertNil(optionalsInstance.methodWithOptionalBridgedReturn())
    verify(optionalsMock.methodWithOptionalBridgedReturn()).wasCalled()
  }
  func testStubNilBridgedReturnValue_stubbingOperator() {
    given(optionalsMock.methodWithOptionalBridgedReturn()) ~> nil
    XCTAssertNil(optionalsInstance.methodWithOptionalBridgedReturn())
    verify(optionalsMock.methodWithOptionalBridgedReturn()).wasCalled()
  }
  
  func testStubNonNilBridgedProperty() {
    given(optionalsMock.optionalBridgedVariable).willReturn("foobar")
    XCTAssertEqual(optionalsInstance.optionalBridgedVariable, "foobar")
    verify(optionalsMock.optionalBridgedVariable).wasCalled()
  }
  func testStubNonNilBridgedProperty_stubbingOperator() {
    given(optionalsMock.optionalBridgedVariable) ~> "foobar"
    XCTAssertEqual(optionalsInstance.optionalBridgedVariable, "foobar")
    verify(optionalsMock.optionalBridgedVariable).wasCalled()
  }
  
  func testStubNilBridgedProperty() {
    given(optionalsMock.optionalBridgedVariable).willReturn(nil)
    XCTAssertNil(optionalsInstance.optionalBridgedVariable)
    verify(optionalsMock.optionalBridgedVariable).wasCalled()
  }
  func testStubNilBridgedProperty_stubbingOperator() {
    given(optionalsMock.optionalBridgedVariable) ~> nil
    XCTAssertNil(optionalsInstance.optionalBridgedVariable)
    verify(optionalsMock.optionalBridgedVariable).wasCalled()
  }
}
