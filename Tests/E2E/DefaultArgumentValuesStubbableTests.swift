//
//  DefaultArgumentValuesStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableDefaultArgumentValuesProtocol {
  func method(param1: @escaping @autoclosure () -> String,
              param2: @escaping @autoclosure () -> [MockingbirdTestsHost.NSObject])
  -> Mockable<FunctionDeclaration, (String, [MockingbirdTestsHost.NSObject]) -> Void, Void>
}
extension DefaultArgumentValuesProtocolMock: StubbableDefaultArgumentValuesProtocol {}

private protocol StubbableDefaultArgumentValuesClass {
  func method(param1: @escaping @autoclosure () -> String,
              param2: @escaping @autoclosure () -> [MockingbirdTestsHost.NSObject])
    -> Mockable<FunctionDeclaration, (String, [MockingbirdTestsHost.NSObject]) -> Void, Void>
}
extension DefaultArgumentValuesClassMock: StubbableDefaultArgumentValuesClass {}
