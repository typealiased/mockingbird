//
//  Mock.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// All generated mocks conform to this protocol.
public protocol Mock {
  var mockingContext: MockingContext { get }
  var stubbingContext: StubbingContext { get }
}

public class StaticMock: Mock {
  public let mockingContext = MockingContext()
  public let stubbingContext = StubbingContext()
}

internal protocol RunnableScope {
  var uuid: UUID { get }
  func run() -> Any?
}

public struct Mockable<T> {}
