//
//  InvocationForwarding.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/25/21.
//

import Foundation

// TODO: Docs
/// Intermediary object for 
public struct ForwardingContext {
  let target: ProxyContext.Target
}

// TODO: Docs
public func forward<T>(to object: T) -> ForwardingContext {
  return ForwardingContext(target: .object(object))
}

// TODO: Docs
public func forwardToSuper() -> ForwardingContext {
  return ForwardingContext(target: .super)
}

public extension Mock {
  // TODO: Docs
  @discardableResult
  func forwarding<T>(to object: T) -> Self {
    mockingbirdContext.proxy.addTarget(.object(object))
    return self
  }
  
  // TODO: Docs
  @discardableResult
  func forwardingToSuper() -> Self {
    mockingbirdContext.proxy.addTarget(.super)
    return self
  }
}
