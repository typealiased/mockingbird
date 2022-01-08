import Foundation

/// Provides implementation functions used to stub behavior and return values.
public struct ImplementationProvider<DeclarationType: Declaration, InvocationType, ReturnType> {
  private let createImplementation: () -> Any?
  private let callback: ((StubbingContext.Stub, Context) -> Void)?
  
  /// Create an implementation provider with an optional callback.
  ///
  /// - Parameter implementationCreator: A closure returning an implementation when evaluated.
  public init(implementationCreator: @escaping () -> Any?) {
    self.init(implementationCreator: implementationCreator, callback: nil)
  }
  
  /// Create an implementation provider with an optional callback.
  ///
  /// - Parameters:
  ///   - implementationCreator: A closure returning an implementation when evaluated.
  ///   - callback: Called when the provider is added to a mock.
  init(implementationCreator: @escaping () -> Any?,
       callback: ((StubbingContext.Stub, Context) -> Void)? = nil) {
    self.createImplementation = implementationCreator
    self.callback = callback
  }
  
  /// Convenience for creating an implementation provider only providing a single implementation.
  ///
  /// - Parameters:
  ///   - implementation: A single closure implementation returned each time.
  ///   - availability: A closure returning whether an implementation can be created.
  ///   - callback: Called when the provider is added to a mock.
  init(implementation: Any,
       availability: @escaping () -> Bool = { return true },
       callback: ((StubbingContext.Stub, Context) -> Void)? = nil) {
    self.init(implementationCreator: {
      guard availability() else { return nil }
      return implementation
    }, callback: callback)
  }
  
  func provide() -> Any? {
    return createImplementation()
  }
  
  func didAddStub<DeclarationType: Declaration>(
    _ stub: StubbingContext.Stub,
    context: Context,
    manager: StubbingManager<DeclarationType, InvocationType, ReturnType>
  ) {
    guard let callback = self.callback else { return }
    callback(stub, context)
  }
}
