import Foundation

/// This is a hack to get strongly-typed stubbing/verification parameters. The goal is to have
/// `ArgumentMatcher` "conform" to any reference or value type so that it's possible to pass both
/// an actual concrete instance of a type OR a matcher. This provides better compile-time
/// guarantees and autocompletion compared to conforming all parameter types to a common protocol.
///
/// It goes without saying that this should probably never be done in production.
private class ResolutionContext {
  enum Constants {
    static let contextKey = DispatchSpecificKey<ResolutionContext>()
    static let resultSentinel = NSException(
      name: NSExceptionName(rawValue: "co.bird.mockingbird.ResolutionContext.result"),
      reason: nil,
      userInfo: nil)
  }
  
  class Result {
    var value: Any? {
      didSet {
        MKBThrowException(Constants.resultSentinel)
      }
    }
  }
  let result = Result()
  
  private static let sharedQueue = DispatchQueue(label: "co.bird.mockingbird.ResolutionContext")
  
  static var sharedContext: ResolutionContext? {
    return DispatchQueue.getSpecific(key: Constants.contextKey)
  }
  
  func resolveTypeFacade<T>(_ block: () -> T) -> Any? {
    return Self.sharedQueue.sync {
      _ = MKBTryBlock {
        Self.sharedQueue.setSpecific(key: Constants.contextKey, value: self)
        result.value = block() // Returns the real value if not an argument matcher.
      }
      Self.sharedQueue.setSpecific(key: Constants.contextKey, value: nil)
      return result.value
    }
  }
}

func unsafeFakeValue<T>() -> T {
  return UnsafeMutableRawPointer
    .allocate(byteCount: 512, alignment: MemoryLayout<Int8>.alignment)
    .bindMemory(to: T.self, capacity: 1)
    .pointee
}

func fakePrimitiveValue<T>() -> T {
  if let value = ValueProvider.standardProvider.provideValue(for: T.self) {
    return value
  }
  // Fall back to returning a buffer of ample size. This can break for bridged primitive types.
  return unsafeFakeValue()
}

/// Wraps a value into any type `T` when resolved inside of a `ResolutionContext<T>`.
func createTypeFacade<T>(_ value: Any?) -> T {
  if let context = ResolutionContext.sharedContext {
    context.result.value = value
    fatalError("This should never run")
  }
  
  guard let recorder = InvocationRecorder.sharedRecorder else {
    preconditionFailure("Invalid resolution thread context state")
  }
  
  if let argumentIndex = recorder.argumentIndex {
    recorder.recordFacadeValue(value, at: argumentIndex)
  } else {
    let error = TestFailure.missingExplicitArgumentPosition(matcher: value as? ArgumentMatcher)
    recorder.recordUnindexedFacadeValue(value, error: error)
  }
  
  // This is actually an invocation recording context, but the type is not mockable in Obj-C.
  return fakePrimitiveValue()
}

/// Wraps a value into an Obj-C object `T` when resolved inside of a `ResolutionContext<T>`.
func createTypeFacade<T: NSObjectProtocol>(_ value: Any?) -> T {
  if let context = ResolutionContext.sharedContext {
    context.result.value = value
    fatalError("This should never run")
  }

  guard InvocationRecorder.sharedRecorder != nil else {
    preconditionFailure("Invalid resolution thread context state")
  }
  // This is actually an invocation recording context.
  return MKBTypeFacade(mock: MKBMock(T.self), object: value as Any).fixupType()
}

/// Resolve `parameter` when `T` is _not_ known to be `Equatable`.
func resolve<T>(_ parameter: () -> T) -> ArgumentMatcher {
  let resolvedValue = ResolutionContext().resolveTypeFacade(parameter)
  if let matcher = resolvedValue as? ArgumentMatcher { return matcher }
  if let boxedValue = resolveObjCTypeFacade(resolvedValue) { return boxedValue }
  if let typedValue = resolvedValue as? T { return ArgumentMatcher(typedValue) }
  return ArgumentMatcher(resolvedValue)
}

/// Resolve `parameter` when `T` is known to be `Equatable`.
func resolve<T: Equatable>(_ parameter: () -> T) -> ArgumentMatcher {
  let resolvedValue = ResolutionContext().resolveTypeFacade(parameter)
  if let matcher = resolvedValue as? ArgumentMatcher { return matcher }
  if let boxedValue = resolveObjCTypeFacade(resolvedValue) { return boxedValue }
  if let typedValue = resolvedValue as? T { return ArgumentMatcher(typedValue) }
  return ArgumentMatcher(resolvedValue)
}

/// Resolve `parameter` when the closure returns an `ArgumentMatcher`.
func resolve(_ parameter: @escaping () -> ArgumentMatcher) -> ArgumentMatcher {
  return parameter()
}

/// Check whether this is an Objective-C type facade and try to unbox the value.
private func resolveObjCTypeFacade(_ value: Any?) -> ArgumentMatcher? {
  let objectValue = value as AnyObject
  if objectValue.responds(to: Selector(("mkb_isTypeFacade"))) {
    let boxedObject = objectValue.perform(Selector(("mkb_boxedObject")))?.takeRetainedValue()
    if let matcher = boxedObject as? ArgumentMatcher {
      return ArgumentMatcher(matcher)
    } else {
      return ArgumentMatcher(boxedObject)
    }
  }
  return nil
}
