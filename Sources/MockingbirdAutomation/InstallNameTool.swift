import Foundation
import PathKit

public enum InstallNameTool {
  public enum RpathToken: String {
    case executablePath = "@executable_path"
    case loaderPath = "@loader_path"
  }
  
  public static func deleteRpath(_ rpath: String, binary: Path) throws {
    try Subprocess("xcrun", [
      "install_name_tool",
      "-delete_rpath", rpath,
      binary.string,
    ]).runWithOutput()
  }
  
  public static func addRpath(_ rpath: String, binary: Path) throws {
    try Subprocess("xcrun", [
      "install_name_tool",
      "-add_rpath", rpath,
      binary.string,
    ]).runWithOutput()
  }
}
