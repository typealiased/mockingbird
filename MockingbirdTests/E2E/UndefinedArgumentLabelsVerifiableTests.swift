//
//  UndefinedArgumentLabelsVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableUndefinedArgumentLabels {
  func method(_ param1: @escaping @autoclosure () -> Bool,
              _ param2: @escaping @autoclosure () -> String,
              _ someParam: @escaping @autoclosure () -> Int,
              _ param3: @escaping @autoclosure () -> Bool) -> Mockable<Bool>
}
extension UndefinedArgumentLabelsMock: VerifiableUndefinedArgumentLabels {}

