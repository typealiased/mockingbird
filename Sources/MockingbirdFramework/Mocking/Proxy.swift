//
//  Proxy.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

protocol Proxy {
  func forwardSwiftInvocation<R>(_ invocation: SwiftInvocation) -> R
  func forwardSwiftInvocation<P0,R>(_ invocation: SwiftInvocation, p0: P0.Type) -> R
  func forwardSwiftInvocation<P0,P1,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type) -> R
  func forwardSwiftInvocation<P0,P1,P2,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,P4,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,P4,P5,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,P7,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type, p7: P7.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,P7,P8,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type, p7: P7.Type, p8: P8.Type) -> R
//  func forwardSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type, p7: P7.Type, p8: P8.Type, p9: P9.Type) -> R
  
  func forwardThrowingSwiftInvocation<R>(_ invocation: SwiftInvocation) throws -> R
  func forwardThrowingSwiftInvocation<P0,R>(_ invocation: SwiftInvocation, p0: P0.Type) throws -> R
  func forwardThrowingSwiftInvocation<P0,P1,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type) throws -> R
  func forwardThrowingSwiftInvocation<P0,P1,P2,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type) throws -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type) -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,P4,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type) -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,P4,P5,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type) -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type) -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,P7,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type, p7: P7.Type) -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,P7,P8,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type, p7: P7.Type, p8: P8.Type) -> R
//  func forwardThrowingSwiftInvocation<P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,R>(_ invocation: SwiftInvocation, p0: P0.Type, p1: P1.Type, p2: P2.Type, p3: P3.Type, p4: P4.Type, p5: P5.Type, p6: P6.Type, p7: P7.Type, p8: P8.Type, p9: P9.Type) -> R
  
  // TODO: Dynamically codegen higher order invocation forwarders per mock file.
}
