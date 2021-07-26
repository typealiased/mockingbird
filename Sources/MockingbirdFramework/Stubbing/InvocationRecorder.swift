//
//  InvocationRecorder.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/18/21.
//

import Foundation

struct InvocationRecord {
  let invocation: Invocation
  let context: Context
}

/// Records invocations for stubbing and verification.
@objc(MKBInvocationRecorder) public class InvocationRecorder: NSObject {
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
    case error(String)
  }
  private(set) var result: Result? {
    didSet {
      MKBThrowException(Constants.resultSentinel)
    }
  }
  
  private(set) var facadeValues = [Int: Any?]()
  private(set) var argumentIndex: Int?
  
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
  
  func recordError(_ message: String) {
    result = .error(message)
  }
  
  func recordArgumentIndex(_ index: Int) {
    self.argumentIndex = index
  }
  
  func recordFacadeValue(_ facadeValue: Any?, at argumentIndex: Int) {
    facadeValues[argumentIndex] = facadeValue
  }
  
  @objc public func getFacadeValue(at argumentIndex: Int) -> Any? {
    return facadeValues[argumentIndex] ?? nil
  }
  
  // MARK: DispatchQueue utils
  
  @objc public static var sharedRecorder: InvocationRecorder? {
    return DispatchQueue.getSpecific(key: Constants.recorderKey)
  }
}
