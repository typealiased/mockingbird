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
  
  public enum Destination {
    case iOSSimulator(deviceUUID: UUID)
    case macOS
    public var platform: String {
      switch self {
      case .iOSSimulator: return "iOS Simulator"
      case .macOS: return "OS X"
      }
    }
    public var optionValue: String {
      switch self {
      case .iOSSimulator(let deviceUUID): return "platform=\(platform),id=\(deviceUUID)"
      case .macOS: return "platform=\(platform)"
      }
    }
  }
  
  public enum Constants {
    public static let tmpBuildPath = Path("/tmp/Mockingbird.dst")
  }
  
  public static func test(target: Target,
                          project: Project,
                          destination: Destination,
                          buildPath: Path = Constants.tmpBuildPath) throws {
    try Subprocess("xcrun", [
      "xcodebuild",
      "test",
      "DSTROOT=\(doubleQuoted: buildPath.absolute().string)",
      "-\(target.optionName)", target.name,
      "-\(project.optionName)", project.path.absolute().string,
      "-destination", destination.optionValue,
    ]).runWithOutput()
  }
  
  public static func clean(target: Target,
                           project: Project,
                           buildPath: Path = Constants.tmpBuildPath) throws {
    try Subprocess("xcrun", [
      "xcodebuild",
      "clean",
      "DSTROOT=\(doubleQuoted: buildPath.absolute().string)",
      "-\(target.optionName)", target.name,
      "-\(project.optionName)", project.path.absolute().string,
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
