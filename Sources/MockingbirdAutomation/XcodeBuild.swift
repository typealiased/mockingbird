import Foundation
import MockingbirdCommon
import PathKit

public enum XcodeBuild {
  public enum Project {
    case project(path: Path)
    case workspace(path: Path)
    var path: Path {
      switch self {
      case .project(let path),
           .workspace(let path):
        return path
      }
    }
    var optionName: String {
      switch self {
      case .project: return "project"
      case .workspace: return "workspace"
      }
    }
    public init?(path: Path) {
      switch path.extension {
      case "xcodeproj": self = .project(path: path)
      case "xcworkspace": self = .workspace(path: path)
      default: return nil
      }
    }
  }
  
  public enum Target {
    case target(name: String)
    case scheme(name: String)
    public var name: String {
      switch self {
      case .target(let name),
           .scheme(let name):
        return name
      }
    }
    var optionName: String {
      switch self {
      case .target: return "target"
      case .scheme: return "scheme"
      }
    }
  }
  
  public enum Constants {
    public static let tmpBuildPath = Path("/tmp/Mockingbird.dst")
  }
  
  public static func test(target: Target,
                          project: Project,
                          deviceUUID: UUID,
                          buildPath: Path = Constants.tmpBuildPath) throws {
    try Subprocess("xcrun", [
      "xcodebuild",
      "test",
      "DSTROOT=\(doubleQuoted: buildPath.absolute().string)",
      "-\(target.optionName)", target.name,
      "-\(project.optionName)", project.path.absolute().string,
      "-destination", "platform=iOS Simulator,id=\(deviceUUID.uuidString)",
    ]).runWithOutput()
  }
  
  public static func resolvePackageDependencies(project: Project) throws {
    try Subprocess("xcrun", [
      "xcodebuild",
      "-resolvePackageDependencies",
      "-\(project.optionName)", project.path.absolute().string,
    ]).runWithOutput()
  }
}
