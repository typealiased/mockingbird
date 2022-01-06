import Foundation

/// Container for mock state and metadata.
@objc(MKBContext) public class Context: NSObject {
  /// Information about received invocations.
  @objc public let mocking: MockingContext
  /// Implementations for stubbing behaviors.
  @objc public let stubbing: StubbingContext
  /// Invocation handler chain.
  @objc public let proxy: ProxyContext
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
