//
//  DefaultArgumentValuesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableDefaultArgumentValuesProtocol: DefaultArgumentValuesProtocol {}
extension DefaultArgumentValuesProtocolMock: MockableDefaultArgumentValuesProtocol {}

private protocol MockableDefaultArgumentValuesClass {
  func method(param1: String, param2: [MockingbirdTestsHost.NSObject])
}
extension DefaultArgumentValuesClassMock: MockableDefaultArgumentValuesClass {}
