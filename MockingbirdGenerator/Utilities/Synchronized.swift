//
//  Synchronized.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

public class Synchronized<T> {
  private(set) public var unsafeValue: T
  public var value: T {
    get {
      lock.lock()
      defer { lock.unlock() }
      return unsafeValue
    }
    
    set {
      lock.lock()
      defer { lock.unlock() }
      unsafeValue = newValue
    }
  }
  private let lock = NSLock()
  
  public init(_ value: T) {
    self.unsafeValue = value
  }
  
  public func update(_ block: (inout T) throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try block(&unsafeValue)
  }
}
