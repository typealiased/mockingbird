//
//  Context+Proxy.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

extension Context: Proxy {
  func recordInvocation(_ invocation: Invocation) {
    guard let recorder = InvocationRecorder.sharedRecorder else { return }
    switch recorder.mode {
    case .none: return
    case .stubbing, .verifying: recorder.recordInvocation(invocation, context: self)
    }
  }
  
  func handleInvocation<R>(_ invocation: SwiftInvocation,
                           test: (Any?) -> Bool,
                           call: (Any?) throws -> R) rethrows -> R {
    recordInvocation(invocation)
    
    let implementation = stubbing.implementation(for: invocation) // Explicitly stubbed
    if test(implementation) {
      return try call(implementation)
    }
    
    for (index, target) in proxy.targets.value.enumerated() {
      guard let implementation = { () -> Any? in
        switch target {
        case .superclass: return invocation.context.super
        case .object(let object):
          guard let invocationProxy = invocation.context.proxy else { return nil }
          let (function, target) = invocationProxy(object)
          proxy.updateTarget(.object(target), at: index) // Manual inout
          return function
        }
      }() else { continue }
      
      guard test(implementation) else { continue }
      return try call(implementation)
    }
    
    if let value = stubbing.defaultValueProvider.value.provideValue(for: R.self) {
      return value
    }
    
    fatalError(stubbing.failTest(for: invocation, at: sourceLocation))
  }
  
  // MARK: - Non-throwing
  
  func forwardSwiftInvocation<R>(
    _ invocation: SwiftInvocation
  ) -> R {
    return mocking.didInvoke(invocation) {
      handleInvocation(
        invocation,
        test: { $0 is () -> R },
        call: { ($0 as! () -> R)() }
      )
    }
  }
  
  func forwardSwiftInvocation<P0,R>(
    _ invocation: SwiftInvocation,
    p0: P0.Type = P0.self
  ) -> R {
    return mocking.didInvoke(invocation) {
      handleInvocation(
        invocation,
        test: { $0 is (P0) -> R || $0 is () -> R },
        call: {
          if let implementation = $0 as? () -> R { return implementation() }
          return ($0 as! (P0) -> R)(
            invocation.arguments[0] as! P0
          )
        }
      )
    }
  }
  
  func forwardSwiftInvocation<P0,P1,R>(
    _ invocation: SwiftInvocation,
    p0: P0.Type = P0.self,
    p1: P1.Type = P1.self
  ) -> R {
    return mocking.didInvoke(invocation) {
      handleInvocation(
        invocation,
        test: { $0 is (P0,P1) -> R || $0 is () -> R },
        call: {
          if let implementation = $0 as? () -> R { return implementation() }
          return ($0 as! (P0,P1) -> R)(
            invocation.arguments[0] as! P0,
            invocation.arguments[1] as! P1
          )
        }
      )
    }
  }
  
  func forwardSwiftInvocation<P0,P1,P2,R>(
    _ invocation: SwiftInvocation,
    p0: P0.Type = P0.self,
    p1: P1.Type = P1.self,
    p2: P2.Type = P2.self
  ) -> R {
    return mocking.didInvoke(invocation) {
      handleInvocation(
        invocation,
        test: { $0 is (P0,P1,P2) -> R || $0 is () -> R },
        call: {
          if let implementation = $0 as? () -> R { return implementation() }
          return ($0 as! (P0,P1,P2) -> R)(
            invocation.arguments[0] as! P0,
            invocation.arguments[1] as! P1,
            invocation.arguments[2] as! P2
          )
        }
      )
    }
  }
  
  // MARK: - Throwing
  
  func forwardThrowingSwiftInvocation<R>(
    _ invocation: SwiftInvocation
  ) throws -> R {
    return try mocking.didInvoke(invocation) {
      try handleInvocation(
        invocation,
        test: { $0 is () throws -> R },
        call: { try ($0 as! () throws -> R)() }
      )
    }
  }
  
  func forwardThrowingSwiftInvocation<P0,R>(
    _ invocation: SwiftInvocation,
    p0: P0.Type = P0.self
  ) throws -> R {
    return try mocking.didInvoke(invocation) {
      try handleInvocation(
        invocation,
        test: { $0 is (P0) throws -> R || $0 is () throws -> R
        },
        call: {
          if let implementation = $0 as? () throws -> R { return try implementation() }
          return try ($0 as! (P0) throws -> R)(
            invocation.arguments[0] as! P0
          )
        }
      )
    }
  }
  
  func forwardThrowingSwiftInvocation<P0,P1,R>(
    _ invocation: SwiftInvocation,
    p0: P0.Type = P0.self,
    p1: P1.Type = P1.self
  ) throws -> R {
    return try mocking.didInvoke(invocation) {
      try handleInvocation(
        invocation,
        test: { $0 is (P0,P1) throws -> R || $0 is () throws -> R },
        call: {
          if let implementation = $0 as? () throws -> R { return try implementation() }
          return try ($0 as! (P0,P1) throws -> R)(
            invocation.arguments[0] as! P0,
            invocation.arguments[1] as! P1
          )
        }
      )
    }
  }
  
  func forwardThrowingSwiftInvocation<P0,P1,P2,R>(
    _ invocation: SwiftInvocation,
    p0: P0.Type = P0.self,
    p1: P1.Type = P1.self,
    p2: P2.Type = P2.self
  ) throws -> R {
    return try mocking.didInvoke(invocation) {
      try handleInvocation(
        invocation,
        test: { $0 is (P0,P1,P2) throws -> R || $0 is () throws -> R },
        call: {
          if let implementation = $0 as? () throws -> R { return try implementation() }
          return try ($0 as! (P0,P1,P2) throws -> R)(
            invocation.arguments[0] as! P0,
            invocation.arguments[1] as! P1,
            invocation.arguments[2] as! P2
          )
        }
      )
    }
  }
  
  // TODO: Dynamically codegen higher order invocation forwarders per mock file.
  
}
