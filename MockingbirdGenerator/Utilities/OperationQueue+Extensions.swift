//
//  OperationQueue+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/19/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

public extension OperationQueue {
  static func createForActiveProcessors() -> OperationQueue {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
    return queue
  }
}
