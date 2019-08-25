//
//  Synchronized.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

public class Synchronized<T> {
  private var internalValue: T
  public var value: T {
    get {
      lock.wait()
      defer { lock.signal() }
      return internalValue
    }
    
    set {
      lock.wait()
      defer { lock.signal() }
      internalValue = newValue
    }
  }
  private let lock = DispatchSemaphore(value: 1)
  
  public init(_ value: T) {
    self.internalValue = value
  }
  
  public func update(_ block: (inout T) throws -> Void) rethrows {
    lock.wait()
    defer { lock.signal() }
    try block(&internalValue)
  }
}
