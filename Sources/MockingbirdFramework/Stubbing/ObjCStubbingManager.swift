//
//  ObjCStubbingManager.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/20/21.
//

import Foundation

/// An intermediate object used for stubbing Objective-C declarations returned by `given`.
public class ObjCStubbingManager<ReturnType, DeclarationType: Declaration>:
  StubbingManager<DeclarationType, Any?, ReturnType> {
  
  // Stubbed implementations are type erased to allow Swift to apply arguments with minimal type
  // information. See `StubbingContext+ObjCReturnValue`.
  
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
    add(implementation: { () -> Any? in return value as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func willThrow(_ error: Error) -> Self {
    add(implementation: { () throws -> Any? in throw error })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping () -> ReturnType
  ) -> Self {
    add(implementation: { implementation() as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) as Any? })
    return self
  }
  
  // TODO: Docs
  @discardableResult
  public func will(
    _ implementation: @escaping (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?)
      -> ReturnType
  ) -> Self {
    add(implementation: { implementation($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) as Any? })
    return self
  }
}
