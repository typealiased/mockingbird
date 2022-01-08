import Foundation

public extension String {
  /// Control codes for formatting strings displayed in a TTY.
  enum ControlCode: String {
    // MARK: Colors
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"
    case black = "\u{001B}[30m"
    case grey = "\u{001B}[30;1m"
    
    // MARK: Misc
    case bold = "\u{001B}[1m"
    case removeFormatting = "\u{001B}[0m"
  }
  
  mutating func format(_ controlCodes: ControlCode...) {
    self = formatted(controlCodes)
  }
  
  func formatted(_ controlCodes: ControlCode...) -> String {
    return formatted(controlCodes)
  }
  
  private func formatted(_ controlCodes: [ControlCode]) -> String {
    let combinedCodes = controlCodes.map({ $0.rawValue }).joined(separator: "")
    return combinedCodes + self + ControlCode.removeFormatting.rawValue
  }
}
