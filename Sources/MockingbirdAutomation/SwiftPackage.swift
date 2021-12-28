import Foundation
import PathKit

public struct SwiftPackage {
  public static func update(package: Path) throws {
    try Subprocess("xcrun", ["swift", "package", "update"],
                   workingDirectory: package.parent()).runWithOutput()
  }
  
  public static func test(package: Path) throws {
    try Subprocess("xcrun", ["swift", "test"],
                   workingDirectory: package.parent()).runWithOutput()
  }
}
