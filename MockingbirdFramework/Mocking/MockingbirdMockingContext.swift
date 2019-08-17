//
//  MockingbirdMockingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Logs invocations observed by generated mocks.
public class MockingbirdMockingContext {
  private(set) var invocations = Synchronized<[String: [MockingbirdInvocation]]>([:])
  func didInvoke(_ invocation: MockingbirdInvocation) {
    invocations.value[invocation.selectorName, default: []].append(invocation)
    
    let observersCopy = observers.value[invocation.selectorName]
    observersCopy?.forEach({ observer in
      guard observer.handle(invocation, mockingContext: self) else { return }
      observers.update { $0[invocation.selectorName]?.remove(observer) }
    })
  }

  func invocations(for selectorName: String) -> [MockingbirdInvocation] {
    return invocations.value[selectorName] ?? []
  }

  func clearInvocations() {
    invocations.update { $0.removeAll() }
  }
  
  private(set) var observers = Synchronized<[String: Set<MockingbirdInvocationObserver>]>([:])
  func addObserver(_ observer: MockingbirdInvocationObserver, for selectorName: String) {
    observers.update { $0[selectorName, default: []].insert(observer) }
  }
}

struct MockingbirdInvocationObserver: Hashable, Equatable {
  init(_ handler: @escaping (MockingbirdInvocation, MockingbirdMockingContext) -> Bool) {
    self.handler = handler
  }
  
  /// Attempts to handle an invocation, returning `true` if successful.
  let handler: (MockingbirdInvocation, MockingbirdMockingContext) -> Bool
  func handle(_ invocation: MockingbirdInvocation,
              mockingContext: MockingbirdMockingContext) -> Bool {
    return handler(invocation, mockingContext)
  }
  
  private let identifier = UUID()
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
  
  static func == (lhs: MockingbirdInvocationObserver, rhs: MockingbirdInvocationObserver) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
