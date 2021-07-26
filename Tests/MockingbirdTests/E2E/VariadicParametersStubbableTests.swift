//
//  VariadicParametersStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableVariadicProtocol {
  func variadicMethod(objects: @autoclosure () -> [String],
                      param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, ([String], Int) -> Void, Void>
  func variadicMethod(objects: @autoclosure () -> [Bool],
                      param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, ([Bool], Int) -> Void, Void>
  func variadicMethodAsFinalParam(param1: @autoclosure () -> Int,
                                  objects: @autoclosure () -> [String])
    -> Mockable<FunctionDeclaration, (Int, [String]) -> Void, Void>
  func variadicReturningMethod(objects: @autoclosure () -> [Bool],
                               param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, ([Bool], Int) -> Bool, Bool>
}
extension VariadicProtocolMock: StubbableVariadicProtocol {}

private protocol StubbableVariadicClass {
  func variadicMethod(objects: @autoclosure () -> [String],
                      param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, ([String], Int) -> Void, Void>
  func variadicMethod(objects: @autoclosure () -> [Bool],
                      param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, ([Bool], Int) -> Void, Void>
  func variadicMethodAsFinalParam(param1: @autoclosure () -> Int,
                                  objects: @autoclosure () -> [String])
    -> Mockable<FunctionDeclaration, (Int, [String]) -> Void, Void>
  func variadicReturningMethod(objects: @autoclosure () -> [Bool],
                               param2: @autoclosure () -> Int)
    -> Mockable<FunctionDeclaration, ([Bool], Int) -> Bool, Bool>
}
extension VariadicClassMock: StubbableVariadicClass {}
