import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableEmptyProtocol: EmptyProtocol, Mock {}
extension EmptyProtocolMock: MockableEmptyProtocol {}

private protocol MockableEmptyClass: Mock {}
extension EmptyClassMock: MockableEmptyClass {}

private protocol MockableEmptyInheritingProtocol: ChildProtocol, Mock {}
extension EmptyInheritingProtocolMock: MockableEmptyInheritingProtocol {}

private protocol MockableEmptyInheritingClass: Child, Mock {}
extension EmptyInheritingClassMock: MockableEmptyInheritingClass {}
