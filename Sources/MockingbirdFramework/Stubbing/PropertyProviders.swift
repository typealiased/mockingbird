import Foundation

/// Stubs a variable getter to return the last value received by the setter.
///
/// Getters can be stubbed to automatically save and return values.
/// with property getters to automatically save and return values.
///
/// ```swift
/// given(bird.name).willReturn(lastSetValue(initial: ""))
/// print(bird.name)  // Prints ""
/// bird.name = "Ryan"
/// print(bird.name)  // Prints "Ryan"
/// ```
///
/// - Parameter initial: The initial value to return.
public func lastSetValue<DeclarationType: PropertyGetterDeclaration, InvocationType, ReturnType>(
  initial: ReturnType
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  var currentValue = initial
  let implementation: () -> ReturnType = { return currentValue }
  let callback = { (stub: StubbingContext.Stub, context: Context) in
    guard let setterInvocation = stub.invocation.toSetter() else { return }
    let setterImplementation = { (newValue: ReturnType) -> Void in
      currentValue = newValue
    }
    _ = context.stubbing.swizzle(setterInvocation, with: { setterImplementation })
  }
  return ImplementationProvider(implementation: implementation, callback: callback)
}
