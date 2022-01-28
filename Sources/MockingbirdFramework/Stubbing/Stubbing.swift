import Dispatch
import Foundation
import XCTest

/// Stub a declaration to return a value or perform an operation.
///
/// Stubbing allows you to define custom behavior for mocks to perform.
///
/// ```swift
/// protocol Bird {
///   var name: String { get }
///   func chirp(at volume: Int) throws -> Bool
/// }
///
/// given(bird.name).willReturn("Ryan")
/// given(bird.chirp(at: 42)).willThrow(BirdError())
/// given(bird.chirp(at: any())).will { volume in
///   return volume < 42
/// }
/// ```
///
/// This is equivalent to the shorthand syntax using the stubbing operator `~>`.
///
/// ```swift
/// given(bird.name) ~> "Ryan"
/// given(bird.chirp(at: 42)) ~> { throw BirdError() }
/// given(bird.chirp(at: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// Properties can have stubs on both their getters and setters.
///
/// ```swift
/// given(bird.name).willReturn("Ryan")
/// given(bird.name = any()).will {
///   print("Hello \($0)")
/// }
///
/// print(bird.name)        // Prints "Ryan"
/// bird.name = "Sterling"  // Prints "Hello Sterling"
/// ```
///
/// This is equivalent to using the synthesized getter and setter methods.
///
/// ```swift
/// given(bird.getName()).willReturn("Ryan")
/// given(bird.setName(any())).will {
///   print("Hello \($0)")
/// }
///
/// print(bird.name)        // Prints "Ryan"
/// bird.name = "Sterling"  // Prints "Hello Sterling"
/// ```
///
/// - Parameter declaration: A stubbable declaration.
public func given<DeclarationType: Declaration, InvocationType, ReturnType>(
  _ declaration: Mockable<DeclarationType, InvocationType, ReturnType>
) -> StaticStubbingManager<DeclarationType, InvocationType, ReturnType> {
  return StaticStubbingManager(invocation: declaration.invocation,
                               context: declaration.context)
}

/// Stub a Swift declaration to return a value or perform an operation.
///
/// This overload is used to help debug typing errors by disambiguating Swift method declarations
/// from Objective-C or property declarations.
///
/// - Parameter declaration: A stubbable Swift declaration.
public func givenSwift<DeclarationType: Declaration, InvocationType, ReturnType>(
  _ declaration: Mockable<DeclarationType, InvocationType, ReturnType>
) -> StaticStubbingManager<DeclarationType, InvocationType, ReturnType> {
  return given(declaration)
}

/// Overload to catch Swift typing errors.
///
/// Stubbing a Swift method with incorrect parameter or return types is not always caught by the
/// compiler due to the generic version of `given` for Objective-C and property declarations. This
/// overload ensures that stubs with mismatched types are surfaced as a compile-time warning.
///
/// - Parameter declaration: A stubbable Swift declaration.
@available(*, deprecated, renamed: "givenSwift",
           message: "Unable to infer types for this stub; switch to 'givenSwift' to disambiguate")
public func given<T: AnyMockable>(_ declaration: T) -> DynamicStubbingManager<Never> {
  fatalError("Incorrect parameter or return types")
}

/// Stub an Objective-C or property declaration to return a value or perform an operation.
///
/// Stubbing allows you to define custom behavior for mocks to perform.
///
/// ```swift
/// given(bird.canChirp()).willReturn(true)
/// given(bird.canChirp()).willThrow(BirdError())
/// given(bird.canChirp(volume: any())).will { volume in
///   return volume as Int < 42
/// }
/// ```
///
/// This is equivalent to the shorthand syntax using the stubbing operator `~>`.
///
/// ```swift
/// given(bird.canChirp()) ~> true
/// given(bird.canChirp()) ~> { throw BirdError() }
/// given(bird.canChirp(volume: any()) ~> { volume in
///   return volume as Int < 42
/// }
/// ```
///
/// Properties can have stubs on both their getters and setters.
///
/// ```swift
/// given(bird.name).willReturn("Ryan")
/// given(bird.name = any()).will { (name: String) in
///   print("Hello \(name)")
/// }
///
/// print(bird.name)        // Prints "Ryan"
/// bird.name = "Sterling"  // Prints "Hello Sterling"
/// ```
///
/// - Parameter declaration: A stubbable declaration.
@_disfavoredOverload
public func given<ReturnType>(
  _ declaration: @autoclosure () throws -> ReturnType
) -> DynamicStubbingManager<ReturnType> {
  let recorder = InvocationRecorder(mode: .stubbing).startRecording(block: {
    /// `EXC_BAD_ACCESS` usually happens when mocking a Swift type that inherits from `NSObject`.
    ///   - Make sure that the Swift type has a generated mock, e.g. `SomeTypeMock` exists.
    ///   - If you actually do want to use Obj-C dynamic mocking with a Swift type, the method must
    ///     be annotated with both `@objc` and `dynamic`, e.g. `@objc dynamic func someMethod()`.
    ///   - If this is happening on a pure Obj-C type, please file a bug report with the stack
    ///     trace: https://github.com/birdrides/mockingbird/issues/new/choose
    _ = try? declaration()
  })
  switch recorder.result {
  case .value(let record):
    return DynamicStubbingManager(invocation: record.invocation, context: record.context)
  case .error(let error):
    preconditionFailure(FailTest("\(error)", isFatal: true))
  case .none:
    preconditionFailure(FailTest("\(TestFailure.unmockableExpression)", isFatal: true))
  }
}

/// An intermediate object used for stubbing Swift declarations returned by `given`.
public class StaticStubbingManager<DeclarationType: Declaration, InvocationType, ReturnType>:
StubbingManager<DeclarationType, InvocationType, ReturnType> {}

/// An intermediate object used for stubbing declarations returned by `given`.
public class StubbingManager<DeclarationType: Declaration, InvocationType, ReturnType> {
  let context: Context
  let invocation: Invocation
  
  var implementationProviders =
    [(provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>,
      transition: TransitionStrategy)]()
  var currentProviderIndex = 0 {
    didSet { implementationsProvidedCount = 0 }
  }
  var implementationsProvidedCount = 0
  var stubs = [(stub: StubbingContext.Stub, context: Context)]()
  
  var isAsync: Bool {
    return DeclarationType.self == AsyncFunctionDeclaration.self || DeclarationType.self == ThrowingAsyncFunctionDeclaration.self
  }
  
  var isThrowing: Bool {
    return DeclarationType.self == ThrowingFunctionDeclaration.self || DeclarationType.self == ThrowingAsyncFunctionDeclaration.self
  }
  
  /// When to use the next chained implementation provider.
  public enum TransitionStrategy {
    /// Go to the next provider after providing a certain number of implementations.
    ///
    /// This transition strategy is particularly useful for non-finite value providers such as
    /// `sequence` and `loopingSequence`.
    ///
    /// ```swift
    /// given(bird.name)
    ///   .willReturn(loopingSequence(of: "Ryan", "Sterling"), transition: .after(3))
    ///   .willReturn("Andrew")
    ///
    /// print(bird.name)  // Prints "Ryan"
    /// print(bird.name)  // Prints "Sterling"
    /// print(bird.name)  // Prints "Ryan"
    /// print(bird.name)  // Prints "Andrew"
    /// ```
    case after(_ times: Int)
    
    /// Use the current provider until it provides a `nil` implementation.
    ///
    /// This transition strategy should be used for finite value providers like `finiteSequence`
    /// that are `nil` terminated to indicate an invalidated state.
    ///
    /// ```swift
    /// given(bird.name)
    ///   .willReturn(finiteSequence(of: "Ryan", "Sterling"), transition: .onFirstNil)
    ///   .willReturn("Andrew")
    ///
    /// print(bird.name)  // Prints "Ryan"
    /// print(bird.name)  // Prints "Sterling"
    /// print(bird.name)  // Prints "Andrew"
    /// ```
    case onFirstNil
  }
  
  init(invocation: Invocation, context: Context) {
    self.context = context
    self.invocation = invocation
    let stub = context.stubbing.swizzle(invocation) { self.getCurrentImplementation() as Any }
    self.stubs.append((stub, context))
  }
  
  func getCurrentImplementation() -> Any? {
    while true {
      guard let current = self.implementationProviders.get(self.currentProviderIndex) else {
        return nil
      }
      
      let implementation = current.provider.provide()
      self.implementationsProvidedCount += 1
      
      // Check whether there are providers after this one.
      guard self.currentProviderIndex < self.implementationProviders.count-1 else {
        return implementation
      }
      
      let shouldTransition: Bool
      let shouldSkipValue: Bool
      
      switch current.transition {
      case .after(let times):
        shouldTransition = self.implementationsProvidedCount >= times
        shouldSkipValue = self.implementationsProvidedCount > times
      case .onFirstNil:
        shouldTransition = implementation == nil
        shouldSkipValue = shouldTransition
      }
      
      if shouldTransition {
        self.currentProviderIndex += 1
      }
      
      guard !shouldSkipValue else { continue }
      return implementation
    }
  }
  
  /// Convenience method to wrap stub implementations into an implementation provider.
  @discardableResult
  func addImplementation(_ implementation: Any,
                         callback: ((StubbingContext.Stub, Context) -> Void)? = nil) -> Self {
    return addProvider(ImplementationProvider(implementation: implementation, callback: callback),
                       transition: .after(1))
  }

  /// Swizzle type-erased stub implementation providers onto stubbing contexts.
  @discardableResult
  func addProvider(_ provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>,
                   transition: TransitionStrategy,
                   callback: ((StubbingContext.Stub, Context) -> Void)? = nil) -> Self {
    implementationProviders.append((provider, transition))
    stubs.forEach({ provider.didAddStub($0.stub, context: $0.context, manager: self) })
    return self
  }
  
  /// Stub a mocked method or property by returning a single value.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform.
  ///
  /// ```swift
  /// given(bird.doMethod()).willReturn(someValue)
  /// given(bird.property).willReturn(someValue)
  /// ```
  ///
  /// You can match exact or wildcard argument values when stubbing.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any())).willReturn(true)     // Any volume
  /// given(bird.canChirp(volume: notNil())).willReturn(true)  // Any non-nil volume
  /// given(bird.canChirp(volume: 10)).willReturn(true)        // Volume = 10
  /// ```
  ///
  /// It’s possible to add multiple stubs to a single method or property. Stubs are checked in
  /// reverse order, so add stubs with specific matchers last.
  ///
  /// ```swift
  /// given(bird.chirp(volume: 42)).willReturn(true)      // #2
  /// given(bird.chirp(volume: any())).willReturn(false)  // #1
  /// print(bird.chirp(volume: 42))  // Prints "false"
  /// ```
  ///
  /// - Parameter value: A stubbed value to return.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willReturn(_ value: ReturnType) -> Self {
#if swift(>=5.5.2)
    if isAsync {
      if isThrowing {
        return addImplementation({ () async throws in value })
      } else {
        return addImplementation({ () async in value })
      }
    }
#endif
    return addImplementation({ value })
  }
  
  /// Stub a mocked method or property with an implementation provider.
  ///
  /// There are several preset implementation providers such as `lastSetValue`, which can be used
  /// with property getters to automatically save and return values.
  ///
  /// ```swift
  /// given(bird.name).willReturn(lastSetValue(initial: ""))
  /// print(bird.name)  // Prints ""
  /// bird.name = "Ryan"
  /// print(bird.name)  // Prints "Ryan"
  /// ```
  ///
  /// Implementation providers usually return multiple values, so when using chained stubbing it's
  /// necessary to specify a transition strategy that defines when to go to the next stub.
  ///
  /// ```swift
  /// given(bird.name)
  ///   .willReturn(lastSetValue(initial: ""), transition: .after(2))
  ///   .willReturn("Sterling")
  ///
  /// print(bird.name)  // Prints ""
  /// bird.name = "Ryan"
  /// print(bird.name)  // Prints "Ryan"
  /// print(bird.name)  // Prints "Sterling"
  /// ```
  ///
  /// - Parameters:
  ///   - provider: An implementation provider that creates closure implementation stubs.
  ///   - transition: When to use the next implementation provider in the list.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willReturn(
    _ provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>,
    transition: TransitionStrategy = .onFirstNil
  ) -> Self {
    return addProvider(provider, transition: transition)
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// Stubs are type safe and work with inout and closure parameter types.
  ///
  /// ```swift
  /// protocol Bird {
  ///   func send(_ message: inout String)
  ///   func fly(callback: (Result) -> Void)
  /// }
  ///
  /// // Inout parameter type
  /// var message = "Hello!"
  /// given(bird.send(message: any())).will { message in
  ///   message = message.uppercased()
  /// }
  /// bird.send(&message)
  /// print(message)   // Prints "HELLO!"
  ///
  /// // Closure parameter type
  /// given(bird.fly(callback: any())).will { callback in
  ///   callback(.success)
  /// }
  /// bird.fly(callback: { result in
  ///   print(result)  // Prints Result.success
  /// })
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(_ implementation: InvocationType) -> Self {
    return addImplementation(implementation)
  }
  
  @discardableResult
  func addForwardingTarget(_ target: ProxyContext.Target) -> Self {
    context.proxy.addTarget(target, for: invocation)
    return self
  }
}

extension StubbingManager where DeclarationType == ThrowingFunctionDeclaration {
  /// Stub a mocked method that throws with an error.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform. Methods that throw or
  /// rethrow errors can be stubbed with a throwable object.
  ///
  /// ```swift
  /// struct BirdError: Error {}
  /// given(bird.throwingMethod()).willThrow(BirdError())
  /// ```
  ///
  /// - Note: Methods overloaded by return type should chain `returning` with `willThrow` to
  /// disambiguate the mocked declaration.
  ///
  /// - Parameter error: A stubbed error object to throw.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willThrow(_ error: Error) -> Self {
    return addImplementation({ () throws -> ReturnType in throw error })
  }
  
  /// Disambiguate throwing methods overloaded by return type.
  ///
  /// Declarations for methods overloaded by return type and stubbed with `willThrow` cannot use
  /// type inference and should be disambiguated.
  ///
  /// ```swift
  /// protocol Bird {
  ///   func fetchMessage<T>() throws -> T    // Overloaded generically
  ///   func fetchMessage() throws -> String  // Overloaded explicitly
  ///   func fetchMessage() throws -> Data
  /// }
  ///
  /// given(bird.fetchMessage())
  ///   .returning(String.self)
  ///   .willThrow(BirdError())
  /// ```
  ///
  /// - Parameter type: The return type of the declaration to stub.
  public func returning(_ type: ReturnType.Type = ReturnType.self) -> Self {
    return self
  }
}

extension StubbingManager where ReturnType == Void {
  /// Stub a mocked method or property that returns `Void`.
  ///
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform.
  ///
  /// ```swift
  /// given(bird.doVoidMethod()).willReturn()
  /// given(bird.setProperty(any())).willReturn()
  /// ```
  ///
  /// - Note: Methods returning `Void` do not need to be explicitly stubbed.
  ///
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willReturn() -> Self {
    return addImplementation({ return () })
  }
}

// MARK: - Stubbing operator

/// The stubbing operator is used to bind an implementation to an intermediary `Stub` object.
infix operator ~>

/// Stub a mocked method or property by returning a single value.
///
/// Stubbing allows you to define custom behavior for mocks to perform.
///
/// ```swift
/// given(bird.doMethod()) ~> someValue
/// given(bird.property) ~> someValue
/// ```
///
/// You can match exact or wildcard argument values when stubbing.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> true     // Any volume
/// given(bird.canChirp(volume: notNil())) ~> true  // Any non-nil volume
/// given(bird.canChirp(volume: 10)) ~> true        // Volume = 10
/// ```
///
/// It’s possible to add multiple stubs to a single method or property. Stubs are checked in
/// reverse order, so add stubs with specific matchers last.
///
/// ```swift
/// given(bird.chirp(volume: 42)) ~> true      // #2
/// given(bird.chirp(volume: any())) ~> false  // #1
/// print(bird.chirp(volume: 42))  // Prints "false"
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A stubbed value to return.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StaticStubbingManager<DeclarationType, InvocationType, ReturnType>,
  implementation: @escaping @autoclosure () -> ReturnType
) {
#if swift(>=5.5.2)
  if manager.isAsync {
    if manager.isThrowing {
      manager.addImplementation({ () async throws in implementation() })
    } else {
      manager.addImplementation({ () async in implementation() })
    }
    return
  }
#endif
  manager.addImplementation({ implementation() })
}

/// Stub a mocked method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// Stubs are type safe and work with inout and closure parameter types.
///
/// ```swift
/// protocol Bird {
///   func send(_ message: inout String)
///   func fly(callback: (Result) -> Void)
/// }
///
/// // Inout parameter type
/// var message = "Hello!"
/// bird.send(&message)
/// print(message)   // Prints "HELLO!"
///
/// // Closure parameter type
/// given(bird.fly(callback: any())).will { callback in
///   callback(.success)
/// }
/// bird.fly(callback: { result in
///   print(result)  // Prints Result.success
/// })
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StaticStubbingManager<DeclarationType, InvocationType, ReturnType>,
  implementation: InvocationType
) {
  manager.addImplementation(implementation)
}

/// Stub a mocked method or property with an implementation provider.
///
/// There are several preset implementation providers such as `lastSetValue`, which can be used
/// with property getters to automatically save and return values.
///
/// ```swift
/// given(bird.name) ~> lastSetValue(initial: "")
/// print(bird.name)  // Prints ""
/// bird.name = "Ryan"
/// print(bird.name)  // Prints "Ryan"
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - provider: An implementation provider that creates closure implementation stubs.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StubbingManager<DeclarationType, InvocationType, ReturnType>,
  provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>
) {
  manager.addProvider(provider, transition: .onFirstNil)
}

/// Stub a mocked method or property by forwarding invocations to a target.
///
/// Use the stubbing operator to bind a specific mocked declaration to a forwarding context.
///
/// ```swift
/// class Crow {
///   let name: String
///   init(name: String) { self.name = name }
/// }
///
/// given(bird.name) ~> forward(to: Crow(name: "Ryan"))
/// print(bird.name)  // Prints "Ryan"
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - forwardingContext: A context that should receive forwarded invocations.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StubbingManager<DeclarationType, InvocationType, ReturnType>,
  forwardingContext: ForwardingContext
) {
  manager.addForwardingTarget(forwardingContext.target)
}

// MARK: Dynamic stubbing compatibility

/// Stub a mocked method or property by returning an implicitly unwrapped optional value.
///
/// Implicitly unwrapped optional stubs cannot be automatically unwrapped by the compiler due to the
/// generic overload of `given` for Objective-C and property declarations. This function allows you
/// to pass an optional in place of the expected non-optional return type to support storing stubs
/// as an implicitly unwrapped variable.
///
/// ```swift
/// let name: String! = "Ryan"
/// given(bird.name) ~> name  // Converted from `String?` to `String`
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A stubbed implicitly unwrapped optional value to return.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StaticStubbingManager<DeclarationType, InvocationType, ReturnType>,
  implementation: @escaping @autoclosure () -> ReturnType?
) {
  manager.addImplementation({ () -> ReturnType in
    guard let value = implementation() else {
      // Ideally this would be a compile-time check.
      preconditionFailure(FailTest("Cannot stub 'nil' for a method with a non-optional return type",
                                   isFatal: true))
    }
    return value
  })
}

/// Stub an optional mocked method or property with a concrete value.
///
/// Concrete value stubs cannot be automatically wrapped to an optional by the compiler due to the
/// generic overload of `given` for Objective-C and property declarations. This function allows you
/// to pass a value in place of an expected optional return type.
///
/// ```swift
/// protocol Bird {
///   var optionalName: String? { get }
/// }
/// given(bird.optionalName) ~> "Ryan"  // Converted from `String` to `String?`
/// ```
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType: AnyOptional>(
  manager: StaticStubbingManager<DeclarationType, InvocationType, ReturnType>,
  implementation: @escaping @autoclosure () -> ReturnType.Wrapped
) {
  manager.addImplementation({ () -> ReturnType in
    // Re-wrap the optional to match the expected implementation type.
    return Optional<ReturnType.Wrapped>(implementation()) as! ReturnType
  })
}

/// Overload to catch Swift typing errors.
///
/// See ``givenSwift(_:)`` for more information.
public func ~> <Implementation>(
  manager: DynamicStubbingManager<Never>,
  implementation: Implementation
) {
    fatalError()
}
