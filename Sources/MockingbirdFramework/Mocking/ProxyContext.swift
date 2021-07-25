//
//  ProxyContext.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

/// Stores potential targets that can handle forwarded invocations from mocked calls.
public struct ProxyContext {
  public enum Target {
    case `super`
    case object(Any)
  }
  
  private let targets = Synchronized<[Target]>([])
  
  /// Returns available proxy targets in insertion order (ascending priority).
  /// - Parameter additionalTarget: Convenience to append an optional proxy target.
  func targets(with additionalTarget: Any? = nil) -> [Target] {
    guard let target = additionalTarget as? Target else { return targets.value }
    return targets.value + [target]
  }
  
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
