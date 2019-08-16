//
//  MockingbirdMockingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Logs invocations observed by generated mocks.
public class MockingbirdMockingContext {
  var invocations = [String: [MockingbirdInvocation]]()
  func didInvoke(_ invocation: MockingbirdInvocation) {
    invocations[invocation.selectorName, default: []].append(invocation)
  }

  func invocations(for selectorName: String) -> [MockingbirdInvocation] {
    return invocations[selectorName] ?? []
  }

  func clearInvocations() { invocations.removeAll() }
}
