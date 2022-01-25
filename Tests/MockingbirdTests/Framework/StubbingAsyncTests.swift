import Foundation
import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension XCTest {
  func XCTAssertThrowsAsyncError<T: Sendable>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "XCTAssertThrowsAsyncError failed: did not throw an error",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
  ) async {
    do {
      _ = try await expression()
      XCTFail(message(), file: file, line: line)
    } catch {
      errorHandler(error)
    }
  }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class StubbingAsyncTests: BaseTestCase {
  
  struct FakeError: Error {}
  
  var asyncProtocol: AsyncProtocolMock!
  var asyncProtocolInstance: AsyncProtocol { asyncProtocol }
  
  override func setUp() {
    asyncProtocol = mock(AsyncProtocol.self)
  }
  
  func testStubAsyncMethodVoid() async {
    givenAsync(asyncProtocol.asyncMethodVoid()).willReturn()
    await asyncProtocolInstance.asyncMethodVoid()
    verifyAsync(asyncProtocol.asyncMethodVoid()).wasCalled()
  }
  
  func testStubAsyncMethod_returnsValue() async {
    givenAsync(asyncProtocol.asyncMethod()) ~> true
    
    let result: Bool = await asyncProtocolInstance.asyncMethod()

    XCTAssertEqual(result, true)
    verifyAsync(asyncProtocol.asyncMethod()).wasCalled()
  }
  
  func testStubAsyncMethodWithParameter_returnsValue() async {
    givenAsync(asyncProtocol.asyncMethod(parameter: any())) ~> 2
    
    let result: Int = await asyncProtocolInstance.asyncMethod(parameter: "parameter")

    XCTAssertEqual(result, 2)
    verifyAsync(asyncProtocol.asyncMethod(parameter: "parameter")).wasCalled()
  }
  
  func testStubAsyncThrowingMethod_returnsValue() async throws {
    givenAsync(asyncProtocol.asyncThrowingMethod()) ~> 1
    
    let result: Int = try await asyncProtocolInstance.asyncThrowingMethod()

    XCTAssertEqual(result, 1)
    verifyAsync(asyncProtocol.asyncThrowingMethod()).wasCalled()
  }
  
  func testStubAsyncThrowingMethod_throwsError() async throws {
    givenAsync(asyncProtocol.asyncThrowingMethod()) ~> { () throws -> Int in throw FakeError() }
    await XCTAssertThrowsAsyncError(try await asyncProtocolInstance.asyncThrowingMethod())
    verifyAsync(asyncProtocol.asyncThrowingMethod()).wasCalled()
  }
  
  func testStubAsyncClosureMethod() async throws {
    givenAsync(asyncProtocol.asyncClosureMethod(block: any())).willReturn()
    await asyncProtocolInstance.asyncClosureMethod(block: { true })
    verifyAsync(asyncProtocol.asyncClosureMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_returnsValue() async throws {
    givenAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())) ~> true
    
    let result: Bool = try await asyncProtocolInstance.asyncClosureThrowingMethod(block: { false })

    XCTAssertTrue(result)
    verifyAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_throwsError() async throws {
    givenAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())) ~> { _ in throw FakeError() }
    await XCTAssertThrowsAsyncError(try await asyncProtocolInstance.asyncClosureThrowingMethod(block: { true }))
    verifyAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_returnsValueFromBlock() async throws {
    givenAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())) ~> { try await $0() }
    
    let result: Bool = try await asyncProtocolInstance.asyncClosureThrowingMethod(block: { true })

    XCTAssertTrue(result)
    verifyAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_throwsErrorFromBlock() async throws {
    givenAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())) ~> { try await $0() }
    await XCTAssertThrowsAsyncError(try await asyncProtocolInstance.asyncClosureThrowingMethod(block: { throw FakeError() }))
    verifyAsync(asyncProtocol.asyncClosureThrowingMethod(block: any())).wasCalled()
  }
  
}
