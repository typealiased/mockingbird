import Foundation
import MockingbirdCommon

/// A tiny cross-platform, OS compatible replacement for `OperationQueue` and Swift concurrency.
public class ActionGraph {
  private let queue = DispatchQueue(label: "co.bird.mockingbird.ActionGraph",
                                    attributes: .concurrent)
  
  struct Action: CustomStringConvertible {
    let id: ObjectIdentifier
    let runnable: Runnable
    let priority: DispatchQoS
    var description: String { "\(runnable) @ \(priority.qosClass)" }
    init(runnable: Runnable, priority: DispatchQoS) {
      self.id = ObjectIdentifier(runnable)
      self.runnable = runnable
      self.priority = priority
    }
  }
  
  struct Graph {
    var actions: [ObjectIdentifier: Action] = [:]
    var edges: [ObjectIdentifier: Set<ObjectIdentifier>] = [:] // action : [dependency]
    var rEdges: [ObjectIdentifier: Set<ObjectIdentifier>] = [:] // action : [dependant]
  }
  let graph: Synchronized<Graph> = Synchronized(Graph())
  
  public init() {}
  
  /// Schedule an action non-preemptively.
  public func register(_ runnable: Runnable, dependencies: [Runnable] = []) {
    dependencies.forEach({ register($0) })
    register(runnable, dependencies: dependencies, priority: .default)
  }
  
  public func register(_ runnables: [Runnable]) {
    runnables.forEach({ register($0) })
  }
  
  private func register(_ runnable: Runnable, dependencies: [Runnable], priority: DispatchQoS) {
    graph.update { graph in
      let action = Action(runnable: runnable, priority: priority)
      dependencies.forEach({ dependency in
        let dependencyId = ObjectIdentifier(dependency)
        graph.edges[action.id, default: []].insert(dependencyId)
        graph.rEdges[dependencyId, default: []].insert(action.id)
      })
      graph.actions[action.id] = action
    }
  }
  
  private func scheduleAction(_ action: Action) {
    globalGroup.enter()
    queue.async {
      do {
        try action.runnable.run(context: self)
      } catch {
        log("Operation '\(self)' failed with error '\(error)'", type: .error)
      }
      self.didRunAction(action)
      self.globalGroup.leave()
    }
  }
  
  private let observers: Synchronized<[ObjectIdentifier: [DispatchGroup]]> = Synchronized([:])
  private func didRunAction(_ action: Action) {
    graph.update { graph in
      graph.rEdges
        .removeValue(forKey: action.id)?
        .forEach({ dependantId in
          graph.edges[dependantId]?.remove(action.id)
          guard let dependencies = graph.edges[dependantId], dependencies.isEmpty,
                let dependant = graph.actions[dependantId] else { return }
          graph.actions.removeValue(forKey: dependantId)
          scheduleAction(dependant)
        })
    }
    observers.update { observers in
      observers.removeValue(forKey: action.id)?.forEach({ $0.leave() })
    }
  }
  
  private var globalGroup = DispatchGroup()
  public func waitForAll() {
    globalGroup.wait()
  }
  
  /// Runs all actions.
  public func run() {
    graph.update { graph in
      graph.actions.values
        .filter({ graph.edges[$0.id]?.isEmpty ?? true })
        .forEach({ action in
          graph.actions.removeValue(forKey: action.id)
          scheduleAction(action)
        })
    }
  }
}

extension ActionGraph: RunnableContext {
  public func registerChild(_ child: Runnable, dependencies: [Runnable] = []) {
    dependencies.forEach({ registerChild($0) })
    register(child, dependencies: dependencies, priority: .userInitiated)
  }
  
  public func registerChildren(_ children: [Runnable]) {
    children.forEach({ registerChild($0) })
  }
  
  /// Runs a specific set of actions and waits for their completion.
  public func runAndWait(for children: [Runnable]) {
    let dispatchGroup = DispatchGroup()
    graph.update { graph in
      let childIds = Set(children.flatMap({
        subgraph(of: graph, root: ObjectIdentifier($0))
      }))
      observers.update { observers in
        childIds.forEach({ id in
          dispatchGroup.enter()
          observers[id, default: []].append(dispatchGroup)
          guard graph.edges[id]?.isEmpty ?? true,
                let action = graph.actions.removeValue(forKey: id) else { return }
          scheduleAction(action)
        })
      }
    }
    dispatchGroup.wait()
  }
  
  /// Returns the node plus all transitive dependencies.
  private func subgraph(of graph: Graph, root id: ObjectIdentifier) -> [ObjectIdentifier] {
    guard let dependencies = graph.edges[id] else { return [id] }
    return dependencies.reduce(into: [id]) { result, id in
      result.append(contentsOf: subgraph(of: graph, root: id))
    }
  }
}
