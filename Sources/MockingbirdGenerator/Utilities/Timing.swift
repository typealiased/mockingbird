import Foundation
#if os(macOS)
import os.log
#endif

@inlinable
public func time<T>(_ signpostType: SignpostType, _ block: () throws -> T) rethrows -> T {
  #if PROFILE && os(macOS)
  var signpost: Signpost!
  if #available(OSX 10.14, *) {
    signpost = beginSignpost(signpostType)
  }
  #else
  let start = ProcessInfo.processInfo.systemUptime
  #endif
  
  let returnValue = try block()
  
  #if PROFILE && os(macOS)
  if #available(OSX 10.14, *) {
    endSignpost(signpost)
  }
  #else
  let delta = round(Double(ProcessInfo.processInfo.systemUptime - start) * 1000 * 100) / 100
  log("\(signpostType.name) - Took \(delta) ms")
  #endif
  return returnValue
}
