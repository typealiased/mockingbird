//
//  InoutParametersVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableInoutProtocol {
  func parameterizedMethod(object: @escaping @autoclosure () -> String) -> Mockable<Void>
}
extension InoutProtocolMock: VerifiableInoutProtocol {}

private protocol VerifiableInoutClass {
  func parameterizedMethod(object: @escaping @autoclosure () -> String) -> Mockable<Void>
}
extension InoutClassMock: VerifiableInoutClass {}
