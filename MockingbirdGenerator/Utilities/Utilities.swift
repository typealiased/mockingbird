//
//  Utilities.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/14/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import os.log

public struct TimingOptions: OptionSet {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let printToConsole = TimingOptions(rawValue: 1 << 0)
  public static let storeSignposts = TimingOptions(rawValue: 1 << 1)
  
  public static let standard: TimingOptions = [.printToConsole, .storeSignposts]
  public static let quiet: TimingOptions = [.storeSignposts]
}

@inlinable
public func time<T>(_ signpostType: SignpostType,
                    options: TimingOptions = .standard,
                    _ block: () throws -> T) rethrows -> T {
  if #available(OSX 10.14, *) {
    let storeSignposts = options.contains(.storeSignposts)
    
    let signpost: Signpost?
    if storeSignposts {
      signpost = OSLog.beginSignpost(signpostType)
    } else {
      signpost = nil
    }
    
    let start = mach_absolute_time()
    let returnValue = try block()
    
    #if DEBUG
    if options.contains(.printToConsole) {
      let delta = round(Double(mach_absolute_time() - start) / 10000.0) / 100.0
      print("\(signpostType.name) - Took \(delta) ms")
    }
    #endif
    
    if let signpost = signpost { OSLog.endSignpost(signpost) }
    return returnValue
  } else {
    return try block()
  }
}
