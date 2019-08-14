//
//  Synchronized.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class Synchronized<T> {
  private(set) var value: T
  private let lock = DispatchSemaphore(value: 1)
  
  init(_ value: T) {
    self.value = value
  }
  
  func update(_ block: (inout T) throws -> Void) rethrows {
    lock.wait()
    defer { lock.signal() }
    try block(&value)
  }
}
