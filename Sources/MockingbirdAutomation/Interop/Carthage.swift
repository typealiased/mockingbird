import Foundation
import PathKit

public enum Carthage {
  public enum Platform: String {
    case iOS = "iOS"
    case macOS = "macOS"
    case tvOS = "tvOS"
    case watchOS = "watchOS"
    case all = "all"
  }
  
  public static func update(platform: Platform = .all, project: Path) throws {
    try Subprocess("carthage", [
      "update",
      "--platform", platform.rawValue,
      "--use-xcframeworks",
      "--verbose",
    ], workingDirectory: project.parent()).run()
  }
  
  public static func build(platform: Platform = .all, project: Path) throws {
    try Subprocess("carthage", [
      "build",
      "--platform", platform.rawValue,
      "--use-xcframeworks",
      "--no-skip-current",
      "--cache-builds",
      "--verbose",
    ], workingDirectory: project.parent()).run()
  }
}
