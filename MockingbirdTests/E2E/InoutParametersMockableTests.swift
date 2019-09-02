//
//  InoutParametersMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableInoutProtocol: InoutProtocol {}
extension InoutProtocolMock: MockableInoutProtocol {}

private protocol MockableInoutClass {
  func parameterizedMethod(object: inout String)
}
extension InoutClassMock: MockableInoutClass {}
