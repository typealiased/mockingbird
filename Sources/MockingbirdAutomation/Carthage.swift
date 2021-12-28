import Foundation
import PathKit

public struct Carthage {
  public enum Platform: String {
    case iOS = "ios"
    case macOS = "macos"
    case all = "all"
  }
  
  public static func update(platform: Platform = .all, project: Path) throws {
    try Subprocess("carthage", [
      "update",
      "--platform", platform.rawValue,
      "--use-xcframeworks",
      "--verbose"
    ], workingDirectory: project.parent()).runWithOutput()
  }
}
