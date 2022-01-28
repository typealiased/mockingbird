import Foundation

/// Resolves runtime generic type names to a `StaticMock` instance.
///
/// Swift does not support static members inside generic types by default. A
/// `GenericStaticMockContext` provides a type and thread safe way for a generic type to access its
/// static mock context.
class GenericStaticMockContext {
  private let mocks = Synchronized<[String: Context]>([:])
  func resolve(_ typeNames: [String]) -> Context {
    let identifier: String = typeNames.joined(separator: ",")
    return mocks.update { mocks in
      if let mock = mocks[identifier] {
        return mock
      }
      let mock = Context()
      mocks[identifier] = mock
      return mock
    }
  }
}
