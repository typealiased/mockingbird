import Foundation

/// References a line of code in a file.
public struct SourceLocation {
  let file: StaticString
  let line: UInt
  let column: UInt
  init(_ file: StaticString, _ line: UInt, _ column: UInt = 0) {
    self.file = file
    self.line = line
    self.column = column
  }
}
