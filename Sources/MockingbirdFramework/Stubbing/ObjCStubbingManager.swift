//
//  ObjCStubbingManager.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/20/21.
//

import Foundation

/// TODO: Docs, Type erasure for Obj-C
public class ObjCStubbingManager<ReturnType>: StubbingManager<AnyObjCDeclaration, Any?, ReturnType> {
  // TODO: Docs
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
