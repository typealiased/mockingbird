//
//  MockingbirdMockingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Logs invocations observed by generated mocks.
public class MockingContext {
  private(set) var invocations = Synchronized<[String: [Invocation]]>([:])
  func didInvoke(_ invocation: Invocation) {
    invocations.value[invocation.selectorName, default: []].append(invocation)
    
    let observersCopy = observers.value[invocation.selectorName]
    observersCopy?.forEach({ observer in
      guard observer.handle(invocation, mockingContext: self) else { return }
      observers.update { $0[invocation.selectorName]?.remove(observer) }
    })
  }

  func invocations(for selectorName: String) -> [Invocation] {
    return invocations.value[selectorName] ?? []
  }

  func clearInvocations() {
    invocations.update { $0.removeAll() }
  }
  
  private(set) var observers = Synchronized<[String: Set<InvocationObserver>]>([:])
  func addObserver(_ observer: InvocationObserver, for selectorName: String) {
    // New observers receive all past invocations for the given `selectorName`.
    if let invocations = invocations.value[selectorName] {
      for invocation in invocations {
        if observer.handle(invocation, mockingContext: self) { return } // Don't add this observer.
      }
    }
    observers.update { $0[selectorName, default: []].insert(observer) }
  }
}

struct InvocationObserver: Hashable, Equatable {
  init(_ handler: @escaping (Invocation, MockingContext) -> Bool) {
    self.handler = handler
  }
  
  /// Attempts to handle an invocation, returning `true` if successful.
  let handler: (Invocation, MockingContext) -> Bool
  func handle(_ invocation: Invocation, mockingContext: MockingContext) -> Bool {
    return handler(invocation, mockingContext)
  }
  
  private let identifier = UUID()
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: InvocationObserver, rhs: InvocationObserver) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
