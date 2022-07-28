import Foundation
import Mockingbird
@testable import MockingbirdTestsHost
import XCTest

#if swift(>=5.5.2)
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
    given(await asyncProtocol.asyncMethod()).willReturn()
    let _: Void = await asyncProtocolInstance.asyncMethod()
    verify(await asyncProtocol.asyncMethod()).returning(Void.self).wasCalled()
  }
  
  func testStubAsyncMethod_returnsValue() async {
    given(await asyncProtocol.asyncMethod()) ~> true
    
    let result: Bool = await asyncProtocolInstance.asyncMethod()

    XCTAssertEqual(result, true)
      verify(await asyncProtocol.asyncMethod()).returning(Bool.self).wasCalled()
  }
  
  func testStubAsyncMethodWithParameter_returnsValue() async {
    given(await asyncProtocol.asyncMethod(parameter: any())) ~> 2
    
    let result: Int = await asyncProtocolInstance.asyncMethod(parameter: "parameter")

    XCTAssertEqual(result, 2)
    verify(await asyncProtocol.asyncMethod(parameter: "parameter")).wasCalled()
  }
  
  func testStubAsyncThrowingMethod_returnsValue() async throws {
    given(await asyncProtocol.asyncThrowingMethod()) ~> 1
    
    let result: Int = try await asyncProtocolInstance.asyncThrowingMethod()

    XCTAssertEqual(result, 1)
      verify(await asyncProtocol.asyncThrowingMethod()).returning(Int.self).wasCalled()
  }
  
  func testStubAsyncThrowingMethod_throwsError() async throws {
      given(await asyncProtocol.asyncThrowingMethod()).returning(Int.self).willThrow(FakeError())
      await XCTAssertThrowsAsyncError(try await asyncProtocolInstance.asyncThrowingMethod() as Int)
      verify(await asyncProtocol.asyncThrowingMethod()).returning(Int.self).wasCalled()
  }
  
  func testStubAsyncClosureMethod() async throws {
    given(await asyncProtocol.asyncMethod(block: any())).willReturn()
    await asyncProtocolInstance.asyncMethod(block: { true })
    verify(await asyncProtocol.asyncMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_returnsValue() async throws {
    given(await asyncProtocol.asyncThrowingMethod(block: any())) ~> true
    
    let result: Bool = try await asyncProtocolInstance.asyncThrowingMethod(block: { false })

    XCTAssertTrue(result)
    verify(await asyncProtocol.asyncThrowingMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_throwsError() async throws {
    given(await asyncProtocol.asyncThrowingMethod(block: any())) ~> { _ in throw FakeError() }
    await XCTAssertThrowsAsyncError(try await asyncProtocolInstance.asyncThrowingMethod(block: { true }))
    verify(await asyncProtocol.asyncThrowingMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_returnsValueFromBlock() async throws {
    given(await asyncProtocol.asyncThrowingMethod(block: any())) ~> { try await $0() }
    
    let result: Bool = try await asyncProtocolInstance.asyncThrowingMethod(block: { true })

    XCTAssertTrue(result)
    verify(await asyncProtocol.asyncThrowingMethod(block: any())).wasCalled()
  }
  
  func testStubAsyncClosureThrowingMethod_throwsErrorFromBlock() async throws {
    given(await asyncProtocol.asyncThrowingMethod(block: any())) ~> { try await $0() }
    await XCTAssertThrowsAsyncError(try await asyncProtocolInstance.asyncThrowingMethod(block: { throw FakeError() }))
    verify(await asyncProtocol.asyncThrowingMethod(block: any())).wasCalled()
  }
  
}
#endif
