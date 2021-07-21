//
//  DynamicStubbingManager.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/20/21.
//

import Foundation

/// An intermediate object used for stubbing Objective-C declarations returned by `given`.
///
/// Stubbed implementations are type erased to allow Swift to apply arguments with minimal type
/// information. See `StubbingContext+ObjCReturnValue` for more context.
public class DynamicStubbingManager<ReturnType>:
  StubbingManager<AnyDeclaration, Any?, ReturnType> {
  
  /// Stub a mocked method or property by returning a single value.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform.
  ///
  ///     given(bird.doMethod()).willReturn(someValue)
  ///     given(bird.property).willReturn(someValue)
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
  override public func willReturn(_ value: ReturnType) -> Self {
    return add(implementation: { () -> Any? in return value as Any? })
  }
  
  /// Stub a mocked method that throws with an error.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform. Methods that throw or
  /// rethrow errors can be stubbed with a throwable object.
  ///
  ///     struct BirdError: Error {}
  ///     given(bird.throwingMethod()).willThrow(BirdError())
  ///
  /// - Note: Methods overloaded by return type should chain `returning` with `willThrow` to
  /// disambiguate the mocked declaration.
  ///
  /// - Warning: It’s undefined behavior to stub throwing an error on a dynamically mocked method
  /// that does not actually throw.
  ///
  /// - Parameter error: A stubbed error object to throw.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willThrow(_ error: Error) -> Self {
    return add(implementation: { () throws -> Any? in throw error })
  }
  
  
  // MARK: - Non-throwing closures
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  ///     given(bird.canChirp(volume: any()))
  ///       .will { volume in
  ///         return volume < 42
  ///       }
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping () -> ReturnType
  ) -> Self {
    return add(implementation: { implementation() as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3, $4) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3, $4, $5) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    return add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9) as Any? })
  }
  
  
  // MARK: - Throwing closures
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  ///     given(bird.canChirp(volume: any()))
  ///       .will { volume in
  ///         return volume < 42
  ///       }
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping () throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation() as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3, $4) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3, $4, $5) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3, $4, $5, $6) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3, $4, $5, $6, $7) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3, $4, $5, $6, $7, $8) as Any? })
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
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      throws -> ReturnType
  ) -> Self {
    return add(implementation: { try implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9) as Any? })
  }
}
