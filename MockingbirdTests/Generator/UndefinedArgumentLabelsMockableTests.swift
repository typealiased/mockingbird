//
//  UndefinedArgumentLabelsMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation
import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableUndefinedArgumentLabels {
  func method(_ param1: Bool, _ param2: String, _ someParam: Int, _ param3: Bool) -> Bool
}
extension UndefinedArgumentLabelsMock: MockableUndefinedArgumentLabels {}
