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
    static let recorderKey = "co.bird.mockingbird.InvocationRecorder"
  }
  
  private(set) var value: InvocationRecord?
  private(set) var facadeValues = [UInt: Any?]()
  private(set) var argumentIndex: UInt?
  
  @objc public let mode: Mode
  @objc public let thread: Thread
  let semaphore: DispatchSemaphore
  
  init(mode: Mode, block: @escaping () -> Any?) {
    self.mode = mode
    let semaphore = DispatchSemaphore(value: 0)
    self.semaphore = semaphore
    self.thread = Thread.init {
      NotificationCenter.default.addObserver(forName: NSNotification.Name.NSThreadWillExit,
                                             object: nil,
                                             queue: nil) { _ in semaphore.signal() }
      _ = block()
    }
  }
  
  func recordInvocation(_ invocation: Invocation, context: Context) {
    value = InvocationRecord(invocation: invocation, context: context)
    Thread.exit()
  }
  
  @objc public func recordInvocation(_ invocation: ObjCInvocation, context: Context) {
    recordInvocation(invocation as Invocation, context: context)
  }
  
  func recordArgumentIndex(_ argumentIndex: UInt) {
    self.argumentIndex = argumentIndex
  }
  
  func recordFacadeValue(_ facadeValue: Any?, at argumentIndex: UInt) {
    facadeValues[argumentIndex] = facadeValue
  }
  
  @objc public func getFacadeValue(at argumentIndex: UInt) -> Any? {
    return facadeValues[argumentIndex] ?? nil
  }
  
  // MARK: DispatchQueue utils
  
  @objc public static func startRecording(mode: Mode,
                                          block: @escaping () -> Any?) -> InvocationRecorder {
    let recorder = InvocationRecorder(mode: mode, block: block)
    recorder.thread.threadDictionary[Constants.recorderKey] = recorder
    recorder.thread.start()
    return recorder
  }
  
  @objc public static var sharedRecorder: InvocationRecorder? {
    return Thread.current.threadDictionary[Constants.recorderKey] as? InvocationRecorder
  }
}
