import Foundation
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableThrowingProtocol: ThrowingProtocol {}
extension ThrowingProtocolMock: MockableThrowingProtocol {}

private protocol MockableRethrowingProtocol: RethrowingProtocol {}
extension RethrowingProtocolMock: MockableRethrowingProtocol {}
