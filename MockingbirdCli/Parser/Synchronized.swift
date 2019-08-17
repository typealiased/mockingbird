//
//  Synchronized.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class Synchronized<T> {
  private var internalValue: T
  var value: T {
    lock.wait()
    defer { lock.signal() }
    return internalValue
  }
  private let lock = DispatchSemaphore(value: 1)
  
  init(_ value: T) {
    self.internalValue = value
  }
  
  func update(_ block: (inout T) throws -> Void) rethrows {
    lock.wait()
    defer { lock.signal() }
    try block(&internalValue)
  }
}
