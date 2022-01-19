import Foundation
import XCTest

/// Stores stubbed implementations used by mocks.
@objc(MKBStubbingContext) public class StubbingContext: NSObject {
  struct Stub {
    let invocation: Invocation
    let implementationProvider: () -> Any
  }
  var stubs = Synchronized<[String: [Stub]]>([:])
  var defaultValueProvider = Synchronized<ValueProvider>(ValueProvider())
  
  func swizzle(_ invocation: Invocation,
               with implementationProvider: @escaping () -> Any) -> Stub {
    let stub = Stub(invocation: invocation, implementationProvider: implementationProvider)
    stubs.update { $0[invocation.selectorName, default: []].append(stub) }
    return stub
  }
  
  func failTest(for invocation: Invocation, at sourceLocation: SourceLocation? = nil) -> Never {
    let stubbedSelectorNames = stubs.read({ Array($0.keys) }).sorted()
    let stackTrace = StackTrace(from: Thread.callStackSymbols)
    let error = TestFailure.missingStubbedImplementation(invocation: invocation,
                                                         stubbedSelectorNames: stubbedSelectorNames,
                                                         stackTrace: stackTrace)
    if let sourceLocation = sourceLocation {
      FailTest("\(error)", isFatal: true, file: sourceLocation.file, line: sourceLocation.line)
    } else {
      FailTest("\(error)", isFatal: true)
    }
    
    fatalError("This should never run")
  }
  
  @objc public func failTest(for invocation: ObjCInvocation) -> Never {
    return failTest(for: invocation as Invocation)
  }

  func implementation(for invocation: Invocation) -> Any? {
    return stubs.read({ $0[invocation.selectorName] })?
      .last(where: { $0.invocation.isEqual(to: invocation) })?
      .implementationProvider()
  }
  
  func clearStubs() {
    stubs.update { $0.removeAll() }
  }
}
