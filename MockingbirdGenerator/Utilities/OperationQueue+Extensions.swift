//
//  OperationQueue+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/19/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

public extension OperationQueue {
  @inlinable
  static func createForActiveProcessors() -> OperationQueue {
    let queue = OperationQueue()
    #if DEBUG
    queue.maxConcurrentOperationCount = 1
    #else
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
    #endif
    return queue
  }
}
