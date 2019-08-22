//
//  VariadicParametersVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableVariadicProtocol {
  func variadicMethod(objects: @escaping @autoclosure () -> [String],
                      param2: @escaping @autoclosure () -> Int) -> Mockable<Void>
  func variadicMethod(objects: @escaping @autoclosure () -> [Bool],
                      param2: @escaping @autoclosure () -> Int) -> Mockable<Void>
  func variadicMethodAsFinalParam(param1: @escaping @autoclosure () -> Int,
                                  objects: @escaping @autoclosure () -> [String]) -> Mockable<Void>
  func variadicReturningMethod(objects: @escaping @autoclosure () -> [Bool],
                               param2: @escaping @autoclosure () -> Int) -> Mockable<Bool>
}
extension VariadicProtocolMock: VerifiableVariadicProtocol {}

private protocol VerifiableVariadicClass {
  func variadicMethod(objects: @escaping @autoclosure () -> [String],
                      param2: @escaping @autoclosure () -> Int) -> Mockable<Void>
  func variadicMethod(objects: @escaping @autoclosure () -> [Bool],
                      param2: @escaping @autoclosure () -> Int) -> Mockable<Void>
  func variadicMethodAsFinalParam(param1: @escaping @autoclosure () -> Int,
                                  objects: @escaping @autoclosure () -> [String]) -> Mockable<Void>
  func variadicReturningMethod(objects: @escaping @autoclosure () -> [Bool],
                               param2: @escaping @autoclosure () -> Int) -> Mockable<Bool>
}
extension VariadicClassMock: VerifiableVariadicClass {}
