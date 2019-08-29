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
  var mockMetadata: MockMetadata { get }
  var sourceLocation: SourceLocation? { get set }
}

public class StaticMock: Mock {
  public let mockingContext = MockingContext()
  public let stubbingContext = StubbingContext()
  public let mockMetadata = MockMetadata()
  public var sourceLocation: SourceLocation? {
    get { return stubbingContext.sourceLocation }
    set { stubbingContext.sourceLocation = newValue }
  }
}

public struct MockMetadata {
  let dictionary: [String: Any]
  init(_ dictionary: [String: Any] = [:]) {
    self.dictionary = dictionary
  }
}

protocol RunnableScope {
  var uuid: UUID { get }
  func run() -> Any?
}

public struct Mockable<T> {}
