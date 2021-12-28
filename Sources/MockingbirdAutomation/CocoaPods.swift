import Foundation
import PathKit

public struct CocoaPods {
  public static func install(workspace: Path) throws {
    try Subprocess("pod", ["install"], workingDirectory: workspace.parent()).runWithOutput()
  }
}
