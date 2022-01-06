import Foundation

/// Stores potential targets that can handle forwarded invocations from mocked calls.
@objc(MKBProxyContext) public class ProxyContext: NSObject {
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
    let global: [TargetBox] = globalTargets.value.reversed()
    let scoped: [TargetBox] = routes(for: invocation).map({ $0.target }).reversed()
    return scoped + global
  }
  
  /// Returns available proxy targets in descending priority, type erased for Obj-C interop.
  @objc public func targets(for invocation: ObjCInvocation) -> [Any] {
    return targets(for: invocation as Invocation).compactMap({ box in
      switch box.target {
      case .super: return nil // Obj-C mocks don't subclass the mocked type.
      case .object(let target): return target
      }
    })
  }
  
  func routes(for invocation: Invocation) -> [Route] {
    guard let routes = routes.read({ $0[invocation.selectorName] }) else { return [] }
    return routes.filter({ $0.invocation.isEqual(to: invocation) })
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
