//
//  Stubbing.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Dispatch
import Foundation
import XCTest

/// Stub one or more declarations to return a value or perform an operation.
///
/// Stubbing allows you to define custom behavior for mocks to perform.
///
///     given(bird.canChirp()).willReturn(true)
///     given(bird.canChirp()).willThrow(BirdError())
///     given(bird.canChirp(volume: any())).will { volume in
///       return volume < 42
///     }
///
/// This is equivalent to the shorthand syntax using the stubbing operator `~>`.
///
///     given(bird.canChirp()) ~> true
///     given(bird.canChirp()) ~> { throw BirdError() }
///     given(bird.canChirp(volume: any())) ~> { volume in
///       return volume < 42
///     }
///
/// Properties can be stubbed with their getter and setter methods.
///
///     given(bird.getName()).willReturn("Ryan")
///     given(bird.setName(any())).will { print($0) }
///
/// - Parameter declarations: One or more stubbable declarations.
public func given<DeclarationType: Declaration, InvocationType, ReturnType>(
  _ declarations: Mockable<DeclarationType, InvocationType, ReturnType>...
) -> StubbingManager<DeclarationType, InvocationType, ReturnType> {
  return StubbingManager(from: declarations)
}

/// An intermediate object used for stubbing declarations returned by `given`.
public class StubbingManager<DeclarationType: Declaration, InvocationType, ReturnType> {
  var implementationProviders =
    [(provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>,
      transition: TransitionStrategy)]()
  var currentProviderIndex = 0 {
    didSet { implementationsProvidedCount = 0 }
  }
  var implementationsProvidedCount = 0
  var stubs = [(stub: StubbingContext.Stub, context: StubbingContext)]()
  
  /// When to use the next chained implementation provider.
  public enum TransitionStrategy {
    /// Go to the next provider after providing a certain number of implementations.
    ///
    /// This transition strategy is particularly useful for non-finite value providers such as
    /// `sequence` and `loopingSequence`.
    ///
    ///     given(bird.getName())
    ///       .willReturn(loopingSequence(of: "Ryan", "Sterling"), transition: .after(3))
    ///       .willReturn("Andrew")
    ///
    ///     print(bird.name)  // Prints "Ryan"
    ///     print(bird.name)  // Prints "Sterling"
    ///     print(bird.name)  // Prints "Ryan"
    ///     print(bird.name)  // Prints "Andrew"
    case after(_ times: Int)
    
    /// Use the current provider until it provides a `nil` implementation.
    ///
    /// This transition strategy should be used for finite value providers like `finiteSequence`
    /// that are `nil` terminated to indicate an invalidated state.
    ///
    ///     given(bird.getName())
    ///       .willReturn(finiteSequence(of: "Ryan", "Sterling"), transition: .onFirstNil)
    ///       .willReturn("Andrew")
    ///
    ///     print(bird.name)  // Prints "Ryan"
    ///     print(bird.name)  // Prints "Sterling"
    ///     print(bird.name)  // Prints "Andrew"
    case onFirstNil
  }
  
  init(from declarations: [Mockable<DeclarationType, InvocationType, ReturnType>]) {
    declarations.forEach({ declaration in
      let context = declaration.mock.stubbingContext
      let stub = context.swizzle(declaration.invocation) { return self.getCurrentImplementation() }
      self.stubs.append((stub, context))
    })
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
  func add(implementation: Any,
           callback: ((StubbingContext.Stub, StubbingContext) -> Void)? = nil) {
    add(provider: ImplementationProvider(implementation: implementation, callback: callback),
        transition: .after(1))
  }

  /// Swizzle type-erased stub implementation providers onto stubbing contexts.
  func add(provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>,
           transition: TransitionStrategy,
           callback: ((StubbingContext.Stub, StubbingContext) -> Void)? = nil) {
    implementationProviders.append((provider, transition))
    stubs.forEach({ provider.didAddStub($0.stub, context: $0.context, manager: self) })
  }
  
  /// Stub a mocked method or property by returning a single value.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform.
  ///
  ///     given(bird.doMethod()).willReturn(someValue)
  ///     given(bird.getProperty()).willReturn(someValue)
  ///
  /// Match exact or wildcard argument values when stubbing methods with parameters. Stubs added
  /// later have a higher precedence, so add stubs with specific matchers last.
  ///
  ///     given(bird.canChirp(volume: any())).willReturn(true)     // Any volume
  ///     given(bird.canChirp(volume: notNil())).willReturn(true)  // Any non-nil volume
  ///     given(bird.canChirp(volume: 10)).willReturn(true)        // Volume = 10
  ///
  /// - Parameter value: A stubbed value to return.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willReturn(_ value: ReturnType) -> Self {
    add(implementation: { return value })
    return self
  }
  
  /// Stub a mocked method or property with an implementation provider.
  ///
  /// There are several preset implementation providers such as `lastSetValue`, which can be used
  /// with property getters to automatically save and return values.
  ///
  ///     given(bird.getName()).willReturn(lastSetValue(initial: ""))
  ///     print(bird.name)  // Prints ""
  ///     bird.name = "Ryan"
  ///     print(bird.name)  // Prints "Ryan"
  ///
  /// Implementation providers usually return multiple values, so when using chained stubbing it's
  /// necessary to specify a transition strategy that defines when to go to the next stub.
  ///
  ///     given(bird.getName())
  ///       .willReturn(lastSetValue(initial: ""), transition: .after(2))
  ///       .willReturn("Sterling")
  ///
  ///     print(bird.name)  // Prints ""
  ///     bird.name = "Ryan"
  ///     print(bird.name)  // Prints "Ryan"
  ///     print(bird.name)  // Prints "Sterling"
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
    add(provider: provider, transition: transition)
    return self
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  ///     given(bird.canChirp(volume: any()))
  ///       .will { volume in
  ///         return volume < 42
  ///       }
  ///
  /// Stubs are type safe and work with inout and closure parameter types.
  ///
  ///     protocol Bird {
  ///       func send(_ message: inout String)
  ///       func fly(callback: (Result) -> Void)
  ///     }
  ///
  ///     // Inout parameter type
  ///     var message = "Hello!"
  ///     bird.send(&message)
  ///     print(message)   // Prints "HELLO!"
  ///
  ///     // Closure parameter type
  ///     given(bird.fly(callback: any())).will { callback in
  ///       callback(.success)
  ///     }
  ///     bird.fly(callback: { result in
  ///       print(result)  // Prints Result.success
  ///     })
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(_ implementation: InvocationType) -> Self {
    add(implementation: implementation)
    return self
  }
}

extension StubbingManager where DeclarationType == ThrowingFunctionDeclaration {
  /// Stub a mocked method that throws by throwing an error.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform.
  ///
  ///     given(bird.throwingMethod()).willThrow(BirdError())
  ///
  /// - Note: Methods overloaded by return type should chain `returning` with `willThrow` to
  /// disambiguate the mocked declaration.
  ///
  /// - Parameter error: A stubbed error to throw.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willThrow(_ error: Error) -> Self {
    add(implementation: { () throws -> ReturnType in throw error })
    return self
  }
  
  /// Disambiguate throwing methods overloaded by return type.
  ///
  /// Declarations for methods overloaded by return type and stubbed with `willThrow` cannot use
  /// type inference and should be disambiguated.
  ///
  ///     protocol Bird {
  ///       func getMessage<T>() throws -> T    // Overloaded generically
  ///       func getMessage() throws -> String  // Overloaded explicitly
  ///       func getMessage() throws -> Data
  ///     }
  ///
  ///     given(bird.send(any()))
  ///       .returning(String.self)
  ///       .willThrow(BirdError())
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
  ///     given(bird.doVoidMethod()).willReturn()
  ///     given(bird.setProperty(any())).willReturn()
  ///
  /// - Note: Methods returning `Void` do not need to be explicitly stubbed.
  ///
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willReturn() -> Self {
    add(implementation: { return () })
    return self
  }
}

// MARK: - Stubbing operator

/// The stubbing operator is used to bind an implementation to an intermediary `Stub` object.
infix operator ~>

/// Stub a mocked method or property by returning a single value.
///
/// Stubbing allows you to define custom behavior for mocks to perform.
///
///     given(bird.doMethod()) ~> someValue
///     given(bird.getProperty()) ~> someValue
///
/// Match exact or wildcard argument values when stubbing methods with parameters. Stubs added
/// later have a higher precedence, so add stubs with specific matchers last.
///
///     given(bird.canChirp(volume: any())) ~> true     // Any volume
///     given(bird.canChirp(volume: notNil())) ~> true  // Any non-nil volume
///     given(bird.canChirp(volume: 10)) ~> true        // Volume = 10
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A stubbed value to return.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StubbingManager<DeclarationType, InvocationType, ReturnType>,
  implementation: @escaping @autoclosure () -> ReturnType
) {
  manager.add(implementation: implementation)
}

/// Stub a mocked method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
///     given(bird.canChirp(volume: any())) ~> { volume in
///       return volume < 42
///     }
///
/// Stubs are type safe and work with inout and closure parameter types.
///
///     protocol Bird {
///       func send(_ message: inout String)
///       func fly(callback: (Result) -> Void)
///     }
///
///     // Inout parameter type
///     var message = "Hello!"
///     bird.send(&message)
///     print(message)   // Prints "HELLO!"
///
///     // Closure parameter type
///     given(bird.fly(callback: any())).will { callback in
///       callback(.success)
///     }
///     bird.fly(callback: { result in
///       print(result)  // Prints Result.success
///     })
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StubbingManager<DeclarationType, InvocationType, ReturnType>,
  implementation: InvocationType
) {
  manager.add(implementation: implementation)
}

/// Stub a mocked method or property with an implementation provider.
///
/// There are several preset implementation providers such as `lastSetValue`, which can be used
/// with property getters to automatically save and return values.
///
///     given(bird.getName()) ~> lastSetValue(initial: "")
///     print(bird.name)  // Prints ""
///     bird.name = "Ryan"
///     print(bird.name)  // Prints "Ryan"
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - provider: An implementation provider that creates closure implementation stubs.
public func ~> <DeclarationType: Declaration, InvocationType, ReturnType>(
  manager: StubbingManager<DeclarationType, InvocationType, ReturnType>,
  provider: ImplementationProvider<DeclarationType, InvocationType, ReturnType>
) {
  manager.add(provider: provider, transition: .onFirstNil)
}
