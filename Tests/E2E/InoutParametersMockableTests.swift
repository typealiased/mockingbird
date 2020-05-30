//
//  InoutParametersMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableInoutProtocol: InoutProtocol, Mock {}
extension InoutProtocolMock: MockableInoutProtocol {}

private protocol MockableInoutClass: Mock {
  func parameterizedMethod(object: inout String)
}
extension InoutClassMock: MockableInoutClass {}
