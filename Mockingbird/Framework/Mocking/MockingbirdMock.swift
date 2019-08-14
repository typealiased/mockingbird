//
//  MockingbirdMock.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// All generated mocks conform to this protocol.
public protocol MockingbirdMock {
  var mockingContext: MockingbirdMockingContext { get }
  var stubbingContext: MockingbirdStubbingContext { get }
}

internal protocol MockingbirdRunnableScope {
  var uuid: UUID { get }
  func run() -> Any?
}

public struct MockingbirdScopedMock {}
