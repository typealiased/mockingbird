import Foundation

public protocol RunnableContext: AnyObject {
  func registerChild(_ child: Runnable, dependencies: [Runnable])
  func registerChildren(_ children: [Runnable])
  func runAndWait(for runnables: [Runnable])
}

extension RunnableContext {
  func registerChild(_ child: Runnable) {
    registerChild(child, dependencies: [])
  }
}

public protocol Runnable: AnyObject, CustomStringConvertible {
  func run(context: RunnableContext) throws
}
