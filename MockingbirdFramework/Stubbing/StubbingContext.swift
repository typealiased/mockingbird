//
//  StubbingContext.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation
import XCTest

/// Holds stubbed invocation implementations used by stubs.
public class StubbingContext {
  struct Stub {
    let invocation: Invocation
    let implementationProvider: (() -> Any)?
  }
  var stubs = Synchronized<[String: [Stub]]>([:])
  var defaultValueProvider = ValueProvider()
  var sourceLocation: SourceLocation?
  
  func swizzle(_ invocation: Invocation, with implementationProvider: (() -> Any)?) -> Stub {
    let stub = Stub(invocation: invocation, implementationProvider: implementationProvider)
    stubs.update { $0[invocation.selectorName, default: []].append(stub) }
    return stub
  }
  
  func failTest(for invocation: Invocation) -> String {
    let error = TestFailure.missingStubbedImplementation(invocation: invocation)
    if let sourceLocation = sourceLocation {
      MKBFail("\(error)", isFatal: true, file: sourceLocation.file, line: sourceLocation.line)
    } else {
      MKBFail("\(error)", isFatal: true)
    }
    // Usually test execution has stopped by this point, but unfortunately there's no workaround for
    // invocations called on background threads.
    fatalError("Missing stubbed implementation for \(invocation)")
  }

  func implementation(for invocation: Invocation) -> Any? {
    return stubs.read({ $0[invocation.selectorName] })?
      .last(where: { $0.invocation == invocation })?
      .implementationProvider?()
  }

  func clearStubs() {
    stubs.update { $0.removeAll() }
  }
}
