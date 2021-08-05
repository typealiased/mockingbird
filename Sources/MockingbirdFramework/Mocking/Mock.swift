//
//  Mock.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/25/21.
//

import Foundation

/// All generated mocks conform to this protocol.
public protocol Mock: AnyObject {
  /// Runtime metdata about the mock instance.
  var mockingbirdContext: Context { get }
}

/// Used to store invocations on static or class scoped methods.
public class StaticMock: Mock {
  /// Runtime metdata about the mock instance.
  public let mockingbirdContext = Context()
}

/// Stores information about generated mocks.
public struct MockMetadata {
  let dictionary: [String: Any]
  init(_ dictionary: [String: Any] = [:]) {
    self.dictionary = dictionary
  }
}
