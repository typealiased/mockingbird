//
//  Context.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

/// All generated mocks conform to this protocol.
public protocol Mock: AnyObject {
  /// Runtime metdata about the mock instance.
  var mockingbirdContext: Context { get }
}

/// Used to store invocations on static or class scoped methods.
public class StaticMock: Mock {
  /// Runtime metdata about the mock instance.
  public let mockingbirdContext = Context()
}

/// Stores information about generated mocks.
public struct MockMetadata {
  let dictionary: [String: Any]
  init(_ dictionary: [String: Any] = [:]) {
    self.dictionary = dictionary
  }
}

@objc(MKBContext) public class Context: NSObject {
  /// Information about received invocations.
  @objc public let mocking: MockingContext
  /// Implementations for stubbing behaviors.
  @objc public let stubbing: StubbingContext
  /// Invocation handler chain.
  let proxy: ProxyContext
  /// Static metadata about the mock created at generation time.
  let metadata: MockMetadata
  /// Where the mock was initialized, set after initialization for class mocks.
  var sourceLocation: SourceLocation?
  
  init(mocking: MockingContext = MockingContext(),
       stubbing: StubbingContext = StubbingContext(),
       proxy: ProxyContext = ProxyContext(),
       metadata: MockMetadata = MockMetadata(),
       sourceLocation: SourceLocation? = nil) {
    self.mocking = mocking
    self.stubbing = stubbing
    self.proxy = proxy
    self.metadata = metadata
    self.sourceLocation = sourceLocation
  }
  
  convenience init(_ metadataDictionary: [String: String]) {
    self.init(metadata: MockMetadata(metadataDictionary))
  }
  
  @objc public override init() {
    self.mocking = MockingContext()
    self.stubbing = StubbingContext()
    self.proxy = ProxyContext()
    self.metadata = MockMetadata()
    self.sourceLocation = nil
  }
  
  func recordInvocation(_ invocation: Invocation) {
    guard let recorder = InvocationRecorder.sharedRecorder else { return }
    switch recorder.mode {
    case .none: return
    case .stubbing, .verifying: recorder.recordInvocation(invocation, context: self)
    }
  }
}

extension NSObjectProtocol {
  var mockingbirdContext: Context? {
    let contextGetterSelector = Selector(("mockingbirdContext"))
    guard responds(to: contextGetterSelector) else { return nil }
    return perform(contextGetterSelector).takeUnretainedValue() as? Context
  }
}
