//
//  ProxyContext.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

/// Stores potential targets that can handle forwarded invocations from mocked calls.
struct ProxyContext {
  enum Target {
    case `super`
    case object(Any)
  }
  
  class TargetBox {
    fileprivate(set) var target: Target
    init(_ target: Target) {
      self.target = target
    }
  }
  
  struct Route {
    let invocation: Invocation
    let target: TargetBox
  }
  
  /// Targets that apply to all invocations.
  private let globalTargets = Synchronized<[TargetBox]>([])
  /// Targets specific to an invocation, mapped by selector name for convenience.
  private let routes = Synchronized<[String: [Route]]>([:])
  
  /// Returns available proxy targets in descending priority.
  func targets(for invocation: Invocation) -> [TargetBox] {
    let globalTargets: [TargetBox] = globalTargets.value.reversed()
    guard let routeTarget = route(for: invocation)?.target else { return globalTargets }
    return [routeTarget] + globalTargets
  }
  
  func route(for invocation: Invocation) -> Route? {
    return routes.read({ $0[invocation.selectorName] })?
      .last(where: { $0.invocation.isEqual(to: invocation) })
  }
  
  func addTarget(_ target: Target, for invocation: Invocation? = nil) {
    let box = TargetBox(target)
    guard let invocation = invocation else {
      globalTargets.update { $0.append(box) }
      return
    }
    let route = Route(invocation: invocation, target: box)
    routes.update { $0[invocation.selectorName, default: []].append(route) }
  }
  
  /// Store the result of mutating invocations for value type targets.
  func updateTarget<T>(_ target: inout T, in box: TargetBox) {
    globalTargets.update { _ in
      routes.update { _ in
        box.target = .object(target)
      }
    }
  }
  
  func clearTargets() {
    globalTargets.update { $0.removeAll() }
    routes.update { $0.removeAll() }
  }
}

public extension NSObjectProtocol {
  // TODO: Docs
  func forwarding(to target: Any?) {
    // TODO
  }
}
