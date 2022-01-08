import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableInoutProtocol: InoutProtocol, Mock {}
extension InoutProtocolMock: MockableInoutProtocol {}

private protocol MockableInoutClass: Mock {
  func parameterizedMethod(object: inout String)
}
extension InoutClassMock: MockableInoutClass {}
