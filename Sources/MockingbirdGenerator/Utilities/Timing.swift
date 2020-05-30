//
//  Utilities.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/14/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import os.log

@inlinable
public func time<T>(_ signpostType: SignpostType, _ block: () throws -> T) rethrows -> T {
  #if PROFILE
  var signpost: Signpost!
  if #available(OSX 10.14, *) {
    signpost = OSLog.beginSignpost(signpostType)
  }
  #endif
  
  let start = mach_absolute_time()
  let returnValue = try block()
  
  #if !(PROFILE)
  let delta = round(Double(mach_absolute_time() - start) / 10000.0) / 100.0
  log("\(signpostType.name) - Took \(delta) ms")
  #endif
  
  #if PROFILE
  if #available(OSX 10.14, *) {
    OSLog.endSignpost(signpost)
  }
  #endif
  return returnValue
}
