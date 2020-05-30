//
//  UndefinedArgumentLabelsStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableUndefinedArgumentLabels {
  func method(_ param1: @escaping @autoclosure () -> Bool,
              _ param2: @escaping @autoclosure () -> String,
              _ someParam: @escaping @autoclosure () -> Int,
              _ param3: @escaping @autoclosure () -> Bool)
    -> Mockable<FunctionDeclaration, (Bool, String, Int, Bool) -> Bool, Bool>
}
extension UndefinedArgumentLabelsMock: StubbableUndefinedArgumentLabels {}

