import Foundation

struct InvocationRecord {
  let invocation: Invocation
  let context: Context
}

/// Records invocations for stubbing and verification.
@objc(MKBInvocationRecorder) public class InvocationRecorder: NSObject {
  
  /// Used to attribute declarations to stubbing and verification calls in tests.
  @objc(MKBInvocationRecorderMode) public enum Mode: UInt {
    case none = 0
    case stubbing
    case verifying
  }
  
  enum Constants {
    static let recorderKey = DispatchSpecificKey<InvocationRecorder>()
    static let resultSentinel = NSException(
      name: NSExceptionName(rawValue: "co.bird.mockingbird.InvocationRecorder.result"),
      reason: nil,
      userInfo: nil)
  }
  
  enum Result {
    case value(InvocationRecord)
    case error(TestFailure)
  }
  private(set) var result: Result? {
    didSet {
      MKBThrowException(Constants.resultSentinel)
    }
  }
  
  private(set) var facadeValues = [Int: Any?]()
  private(set) var argumentIndex: Int?
  
  /// Gracefully handle invocations with only a single argument by deferring errors until later.
  private(set) var unindexedFacadeValues = [(value: Any?, pendingError: TestFailure)]()
  
  @objc public let mode: Mode
  private static let sharedQueue = DispatchQueue(label: "co.bird.mockingbird.InvocationRecorder")
  
  init(mode: Mode) {
    self.mode = mode
  }
  
  func startRecording(block: () -> Void) -> Self {
    Self.sharedQueue.sync {
      _ = MKBTryBlock {
        Self.sharedQueue.setSpecific(key: Constants.recorderKey, value: self)
        block()
      }
      Self.sharedQueue.setSpecific(key: Constants.recorderKey, value: nil)
    }
    return self
  }
  
  func recordInvocation(_ invocation: Invocation, context: Context) {
    result = .value(InvocationRecord(invocation: invocation, context: context))
  }
  
  @objc public func recordInvocation(_ invocation: ObjCInvocation, context: Context) {
    recordInvocation(invocation as Invocation, context: context)
  }
  
  func recordError(_ error: TestFailure) -> Never {
    result = .error(error)
    fatalError("This should never run")
  }
  
  func recordArgumentIndex(_ index: Int) {
    argumentIndex = index
  }
  
  func recordFacadeValue(_ facadeValue: Any?, at index: Int) {
    facadeValues[index] = facadeValue
    argumentIndex = nil
  }
  
  func recordUnindexedFacadeValue(_ facadeValue: Any?, error: TestFailure) {
    unindexedFacadeValues.append((facadeValue, error))
  }
  
  @objc public func getFacadeValue(at argumentIndex: Int, argumentsCount: Int) -> Any? {
    // Indexes can only be inferred when the argument matching is homogenous.
    // For example, arguments [any(), any()] and [1, 2] could be inferred, but [1, any()] could not.
    if let indexedFacadeValue = facadeValues[argumentIndex] {
      return indexedFacadeValue
    } else if let unindexedFacadeValue = unindexedFacadeValues.get(argumentIndex)?.value,
              argumentsCount == unindexedFacadeValues.count {
      return unindexedFacadeValue
    } else if let error = unindexedFacadeValues.last?.pendingError {
      recordError(error)
    } else {
      return nil // Shouldn't be possible to reach this branch.
    }
  }
  
  // MARK: DispatchQueue utils
  
  /// The global invocation recorder instance.
  @objc public static var sharedRecorder: InvocationRecorder? {
    return DispatchQueue.getSpecific(key: Constants.recorderKey)
  }
}
