import Foundation

public func logInfo(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  log(items, separator: separator, terminator: terminator, output: stdout)
}

public func logWarning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  var prefix = "warning:"
  if ProcessInfo.supportsControlCodes(output: stderr) { prefix.format(.yellow, .bold) }
  log([prefix] + items, separator: separator, terminator: terminator, output: stderr)
}

public func logError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  var prefix = "error:"
  if ProcessInfo.supportsControlCodes(output: stderr) { prefix.format(.red, .bold) }
  log([prefix] + items, separator: separator, terminator: terminator, output: stderr)
}

public func log(_ items: [Any],
                separator: String = " ",
                terminator: String = "\n",
                output: UnsafeMutablePointer<FILE>) {
  let stringItems = items.map({ item -> String in
    if let stringItem = item as? String { return stringItem }
    return String(describing: item)
  })
  let message = stringItems.joined(separator: separator) + terminator
  fputs(message, output)
  fflush(output)
}
