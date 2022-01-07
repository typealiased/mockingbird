import Foundation
import PathKit

public enum Codesign {  
  public static func sign(binary: Path, identity: String) throws {
    try Subprocess("xcrun", [
      "codesign",
      "--sign", identity,
      "--timestamp",
      "--options", "runtime", // Enable hardened runtime for notarization.
      "--verbose",
      binary.string,
    ]).run()
  }
  
  public static func verify(binary: Path, requirements: Path) throws {
    try Subprocess("xcrun", [
      "codesign",
      "--verify",
      "--test-requirement", requirements.string,
      "--verbose",
      binary.string,
    ]).run()
  }
}
