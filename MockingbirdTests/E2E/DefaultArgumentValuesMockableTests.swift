//
//  DefaultArgumentValuesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableDefaultArgumentValuesProtocol: DefaultArgumentValuesProtocol, Mock {}
extension DefaultArgumentValuesProtocolMock: MockableDefaultArgumentValuesProtocol {}

private protocol MockableDefaultArgumentValuesClass: Mock {
  func method(param1: String, param2: [MockingbirdTestsHost.NSObject])
}
extension DefaultArgumentValuesClassMock: MockableDefaultArgumentValuesClass {}
