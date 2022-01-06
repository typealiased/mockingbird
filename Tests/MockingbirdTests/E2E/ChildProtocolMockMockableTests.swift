import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

private protocol MockableChildProtocol: ParentProtocol, Mock {}
extension ChildProtocolMock: MockableChildProtocol {}
