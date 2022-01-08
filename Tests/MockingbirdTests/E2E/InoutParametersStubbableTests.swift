import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableInoutProtocol {
  func parameterizedMethod(object: @autoclosure () -> String)
    -> Mockable<FunctionDeclaration, (inout String) -> Void, Void>
}
extension InoutProtocolMock: StubbableInoutProtocol {}

private protocol StubbableInoutClass {
  func parameterizedMethod(object: @autoclosure () -> String)
    -> Mockable<FunctionDeclaration, (inout String) -> Void, Void>
}
extension InoutClassMock: StubbableInoutClass {}
