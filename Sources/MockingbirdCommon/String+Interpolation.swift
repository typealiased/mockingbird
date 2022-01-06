import Foundation

public extension String.StringInterpolation {
  mutating func appendInterpolation(singleQuoted str: String) {
    appendLiteral("'\(str)'")
  }
  
  mutating func appendInterpolation(doubleQuoted str: String) {
    appendLiteral("\"\(str)\"")
  }
  
  mutating func appendInterpolation(backticked str: String) {
    appendLiteral("`\(str)`")
  }
  
  mutating func appendInterpolation(parenthetical str: String) {
    appendLiteral("(\(str))")
  }
  
  mutating func appendInterpolation(separated str: [String], separator: String = ", ") {
    appendLiteral(str.joined(separator: separator))
  }
  
  mutating func appendInterpolation(padded str: String, count: Int = 0) {
    let padding = String(repeating: " ", count: count)
    appendLiteral(padding + str + padding)
  }
}
