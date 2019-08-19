//
//  Utilities.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/14/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

func time<T>(_ name: String = "Unnamed task", _ block: () throws -> T) rethrows -> T {
  #if DEBUG
  let start = mach_absolute_time()
  let returnValue = try block()
  print("\(name) - Took \(round(Double(mach_absolute_time() - start) / 10000.0) / 100.0) ms")
  return returnValue
  #else
  return try block()
  #endif
}
