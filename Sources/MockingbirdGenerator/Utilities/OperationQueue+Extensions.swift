import Foundation

public extension OperationQueue {
  @inlinable
  static func createForActiveProcessors() -> OperationQueue {
    let queue = OperationQueue()
    #if DEBUG
    queue.maxConcurrentOperationCount = 1
    #else
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
    #endif
    return queue
  }
}
