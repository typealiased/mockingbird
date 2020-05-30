//
//  VariadicParameters.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

protocol VariadicProtocol {
  func variadicMethod(objects: String ..., param2: Int)
  func variadicMethod(objects: Bool..., param2: Int) // Overloaded
  func variadicMethodAsFinalParam(param1: Int, objects: String ...)
  func variadicReturningMethod(objects: Bool..., param2: Int) -> Bool
}

class VariadicClass {
  func variadicMethod(objects: String ..., param2: Int) {}
  func variadicMethod(objects: Bool..., param2: Int) {} // Overloaded
  func variadicMethodAsFinalParam(param1: Int, objects: String ...) {}
  func variadicReturningMethod(objects: Bool..., param2: Int) -> Bool { return true }
}
