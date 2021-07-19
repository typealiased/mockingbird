//
//  InvocationRecorder.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/18/21.
//

import Foundation

struct InvocationRecord {
  let invocation: Invocation
  let mockingContext: MockingContext
  let stubbingContext: StubbingContext
}

/// Records invocations for stubbing and verification.
@objc(MKBInvocationRecorder) public class InvocationRecorder: NSObject {
  @objc(MKBInvocationRecorderMode) public enum Mode: UInt {
    case none = 0
    case stubbing
    case verifying
  }
  
  enum Constants {
    static let recorderKey = "co.bird.mockingbird.invocation-recorder"
  }
  
  private(set) var value: InvocationRecord?
  
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
  
  @objc public func record(invocation: ObjCInvocation,
                           mockingContext: MockingContext,
                           stubbingContext: StubbingContext) {
    self.value = InvocationRecord(invocation: invocation,
                                  mockingContext: mockingContext,
                                  stubbingContext: stubbingContext)
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
