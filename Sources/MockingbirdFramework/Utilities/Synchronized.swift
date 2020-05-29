//
//  Synchronized.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class Synchronized<T> {
  private(set) var unsafeValue: T
  var value: T {
    get {
      var value: T!
      queue.sync { value = unsafeValue }
      return value
    }
    set {
      queue.sync { unsafeValue = newValue }
    }
  }
  private let queue = DispatchQueue(label: "co.bird.mockingbird.synchronized")
  
  init(_ value: T) {
    self.unsafeValue = value
  }
  
  func update(_ block: (inout T) throws -> Void) rethrows {
    try queue.sync { try block(&unsafeValue) }
  }
  
  func read<R>(_ block: (T) throws -> R) rethrows -> R {
    var value: R!
    try queue.sync { value = try block(unsafeValue) }
    return value
  }
}
