import Foundation

/// Stores invocations received by mocks.
@objc(MKBMockingContext) public class MockingContext: NSObject {
  private(set) var allInvocations = Synchronized<[Invocation]>([])
  private(set) var invocations = Synchronized<[String: [Invocation]]>([:])
  let identifier = UUID()
  
  convenience init(from other: MockingContext) {
    self.init()
    self.allInvocations = other.allInvocations
    self.invocations = other.invocations
  }
  
  /// Invoke a thunk that can throw.
  func didInvoke<T, I: Invocation>(_ invocation: I,
                                   evaluating thunk: (I) throws -> T) rethrows -> T {
    // Ensures that the thunk is evaluated prior to recording the invocation.
    defer { didInvoke(invocation) }
    return try thunk(invocation)
  }
  
  /// Invoke a non-throwing thunk.
  func didInvoke<T, I: Invocation>(_ invocation: I, evaluating thunk: (I) -> T) -> T {
    // Ensures that the thunk is evaluated prior to recording the invocation.
    defer { didInvoke(invocation) }
    return thunk(invocation)
  }
  
#if swift(>=5.5.2)
  /// Invoke an async thunk that can throw.
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func didInvoke<T, I: Invocation>(_ invocation: I,
                                   evaluating thunk: (I) async throws -> T) async rethrows -> T {
    // Ensures that the thunk is evaluated prior to recording the invocation.
    defer { didInvoke(invocation) }
    return try await thunk(invocation)
  }
  
  /// Invoke an async non-throwing thunk.
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func didInvoke<T, I: Invocation>(_ invocation: I, evaluating thunk: (I) async -> T) async -> T {
    // Ensures that the thunk is evaluated prior to recording the invocation.
    defer { didInvoke(invocation) }
    return await thunk(invocation)
  }
#endif
  
  /// Invoke a thunk from Objective-C.
  @objc public func objcDidInvoke(_ invocation: ObjCInvocation,
                                  evaluating thunk: (ObjCInvocation) -> Any?) -> Any? {
    return didInvoke(invocation, evaluating: thunk)
  }
    
  func didInvoke(_ invocation: Invocation) {
    allInvocations.update { $0.append(invocation) }
    invocations.update { $0[invocation.selectorName, default: []].append(invocation) }
    
    let observersCopy = observers.read { $0[invocation.selectorName] }
    observersCopy?.forEach({ observer in
      guard observer.handle(invocation, mockingContext: self) else { return }
      observers.update { $0[invocation.selectorName]?.remove(observer) }
    })
    
    wildcardObservers.update { observers in
      observers = observers.filter({ observer in
        !observer.handle(invocation, mockingContext: self)
      })
    }
  }

  func invocations(with selectorName: String) -> [Invocation] {
    return invocations.read { $0[selectorName] } ?? []
  }

  func clearInvocations() {
    invocations.update { $0.removeAll() }
  }
  
  func removeInvocations(before invocation: Invocation, inclusive: Bool = false) {
    allInvocations.update { allInvocations in
      invocations.update { invocations in
        guard let baseIndex = allInvocations
                .lastIndex(where: { $0.uid <= invocation.uid })?
          .advanced(by: inclusive ? 1 : 0)
          else { return }
        allInvocations.removeFirst(baseIndex)
        invocations = allInvocations.reduce(into: [:]) { (result, invocation) in
          result[invocation.selectorName, default: []].append(invocation)
        }
      }
    }
  }
  
  /// Observers are removed once they successfully handle the invocation.
  private(set) var observers = Synchronized<[String: Set<InvocationObserver>]>([:])
  private(set) var wildcardObservers = Synchronized<[InvocationObserver]>([])
  
  func addObserver(_ observer: InvocationObserver, for selectorName: String) {
    // New observers receive all past invocations for the given `selectorName`.
    let invocations = self.invocations.read({ Array($0[selectorName] ?? []) })
    for invocation in invocations {
      // If it can handle the invocation now, don't let it receive future updates.
      if observer.handle(invocation, mockingContext: self) { return }
    }
    observers.update { $0[selectorName, default: []].insert(observer) }
  }
  
  func addObserver(_ observer: InvocationObserver) {
    for invocation in allInvocations.read({ Array($0) }) {
      if observer.handle(invocation, mockingContext: self) { return }
    }
    wildcardObservers.update { $0.append(observer) }
  }
}

struct InvocationObserver: Hashable, Equatable {
  let identifier: UUID
  
  init(_ handler: @escaping (Invocation, MockingContext) -> Bool, identifier: UUID = UUID()) {
    self.handler = handler
    self.identifier = identifier
  }
  
  /// Attempts to handle an invocation, returning `true` if successful.
  let handler: (Invocation, MockingContext) -> Bool
  func handle(_ invocation: Invocation, mockingContext: MockingContext) -> Bool {
    return handler(invocation, mockingContext)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: InvocationObserver, rhs: InvocationObserver) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
