//
//  DefaultArgumentValuesVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableDefaultArgumentValuesProtocol {
  func method(param1: @escaping @autoclosure () -> String,
              param2: @escaping @autoclosure () -> [MockingbirdTestsHost.NSObject])
    -> Mockable<Void>
}
extension DefaultArgumentValuesProtocolMock: VerifiableDefaultArgumentValuesProtocol {}

private protocol VerifiableDefaultArgumentValuesClass {
  func method(param1: @escaping @autoclosure () -> String,
              param2: @escaping @autoclosure () -> [MockingbirdTestsHost.NSObject])
    -> Mockable<Void>
}
extension DefaultArgumentValuesClassMock: VerifiableDefaultArgumentValuesClass {}
