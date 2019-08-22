//
//  VariadicParametersMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableVariadicProtocol {
  func variadicMethod(objects: String ..., param2: Int)
  func variadicMethod(objects: Bool..., param2: Int)
  func variadicMethodAsFinalParam(param1: Int, objects: String ...)
  func variadicReturningMethod(objects: Bool..., param2: Int) -> Bool
}
extension VariadicProtocolMock: MockableVariadicProtocol {}

private protocol MockableVariadicClass {
  func variadicMethod(objects: String ..., param2: Int)
  func variadicMethod(objects: Bool..., param2: Int)
  func variadicMethodAsFinalParam(param1: Int, objects: String ...)
  func variadicReturningMethod(objects: Bool..., param2: Int) -> Bool
}
extension VariadicClassMock: MockableVariadicClass {}
