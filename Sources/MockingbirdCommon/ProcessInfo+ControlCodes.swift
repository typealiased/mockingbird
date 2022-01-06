import Foundation

public extension ProcessInfo {
  static func supportsControlCodes(output: UnsafeMutablePointer<FILE>) -> Bool {
    return isatty(fileno(output)) != 0
      // Standard convention to indicate a terminal with limited capabilities.
      && processInfo.environment["TERM"] != "dumb"
  }
}
