//
//  GenericStaticMockContext.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/23/21.
//

import Foundation

/// Resolves runtime generic type names to a `StaticMock` instance.
///
/// Swift does not support static members inside generic types by default. A
/// `GenericStaticMockContext` provides a type and thread safe way for a generic type to access its
/// static mock instance.
class GenericStaticMockContext {
  private let mocks = Synchronized<[String: StaticMock]>([:])
  func resolveTypeNames(_ typeNames: [String]) -> StaticMock {
    let identifier: String = typeNames.joined(separator: ",")
    return mocks.update { mocks in
      if let mock = mocks[identifier] {
        return mock
      } else {
        let mock = StaticMock()
        mocks[identifier] = mock
        return mock
      }
    }
  }
}
