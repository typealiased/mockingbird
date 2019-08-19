//
//  BasicOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/8/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class BasicOperation: Operation {
  override var isAsynchronous: Bool { return false }
  override var isConcurrent: Bool { return true }
  
  private(set) var _isFinished: Bool = false
  override var isFinished: Bool {
    set {
      willChangeValue(forKey: "isFinished")
      _isFinished = newValue
      didChangeValue(forKey: "isFinished")
    }
    get { return _isFinished }
  }
  
  private(set) var _isExecuting: Bool = false
  override var isExecuting: Bool {
    set {
      willChangeValue(forKey: "isExecuting")
      _isExecuting = newValue
      didChangeValue(forKey: "isExecuting")
    }
    get { return _isExecuting }
  }
  
  func run() {}
  
  override func start() {
    guard !isCancelled else { return }
    isExecuting = true
    run()
    isExecuting = false
    isFinished = true
  }
}
