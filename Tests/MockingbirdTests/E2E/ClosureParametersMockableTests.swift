import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableClosureParametersProtocol: ClosureParametersProtocol, Mock {}
extension ClosureParametersProtocolMock: MockableClosureParametersProtocol {}
