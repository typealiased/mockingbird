import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableUndefinedArgumentLabels {
  func method(_ param1: @autoclosure () -> Bool,
              _ param2: @autoclosure () -> String,
              _ someParam: @autoclosure () -> Int,
              _ param3: @autoclosure () -> Bool)
    -> Mockable<FunctionDeclaration, (Bool, String, Int, Bool) -> Bool, Bool>
}
extension UndefinedArgumentLabelsMock: StubbableUndefinedArgumentLabels {}

