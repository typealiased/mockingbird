import Foundation
import PathKit

public enum PlistBuddy {
  public static func printValue(key: String, plist: Path) throws -> String {
    let (value, _) = try Subprocess("/usr/libexec/PlistBuddy", [
      "-c", "Print :\(key)",
      plist.string,
    ]).runWithOutput()
    return value.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
