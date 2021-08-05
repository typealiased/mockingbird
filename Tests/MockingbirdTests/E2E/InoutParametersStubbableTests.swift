//
//  InoutParametersStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableInoutProtocol {
  func parameterizedMethod(object: @autoclosure () -> String)
    -> Mockable<FunctionDeclaration, (inout String) -> Void, Void>
}
extension InoutProtocolMock: StubbableInoutProtocol {}

private protocol StubbableInoutClass {
  func parameterizedMethod(object: @autoclosure () -> String)
    -> Mockable<FunctionDeclaration, (inout String) -> Void, Void>
}
extension InoutClassMock: StubbableInoutClass {}
