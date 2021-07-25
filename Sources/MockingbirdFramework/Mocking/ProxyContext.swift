//
//  ProxyContext.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

struct ProxyContext {
  enum Target {
    case superclass
    case object(Any)
  }
  
  let targets = Synchronized<[Target]>([])
  
  func addTarget(_ target: Target) {
    targets.update { $0.append(target) }
  }
  
  func updateTarget<T>(_ target: inout T, at index: Int) {
    targets.update { $0[index] = .object(target) }
  }
  
  func clearTargets() {
    targets.update { $0.removeAll() }
  }
}

public extension NSObjectProtocol {
  // TODO: Docs
  func forward(to target: Any?) {
    // TODO
  }
}
