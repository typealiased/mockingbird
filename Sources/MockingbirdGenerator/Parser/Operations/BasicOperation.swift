import Foundation

public class BasicOperation: Operation {
  override public var isAsynchronous: Bool { return false }
  override public var isConcurrent: Bool { return true }
  
  private(set) public var error: Error?
  
  private(set) var _isFinished: Bool = false
  override public var isFinished: Bool {
    set {
      willChangeValue(forKey: "isFinished")
      _isFinished = newValue
      didChangeValue(forKey: "isFinished")
    }
    get { return _isFinished }
  }
  
  private(set) var _isExecuting: Bool = false
  override public var isExecuting: Bool {
    set {
      willChangeValue(forKey: "isExecuting")
      _isExecuting = newValue
      didChangeValue(forKey: "isExecuting")
    }
    get { return _isExecuting }
  }
  
  func run() throws {}
  
  override public func start() {
    guard !isCancelled else { return }
    isExecuting = true
    do {
      try run()
    } catch {
      self.error = error
      log("Operation '\(self)' failed with error '\(error)'", type: .error)
    }
    isExecuting = false
    isFinished = true
  }
}
