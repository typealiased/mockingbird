import Foundation
import PathKit

public enum CocoaPods {
  public static func install(workspace: Path) throws {
    try Subprocess("pod", ["install"], workingDirectory: workspace.parent()).run()
  }
}
