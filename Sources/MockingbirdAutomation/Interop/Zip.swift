import Foundation
import PathKit

public enum Zip {
  public static func deflate(input: Path, output: Path) throws {
    try Subprocess("zip", [
      "-r", // Recursive
      "-X", // No extra file attributes e.g. '_MACOSX'
      output.absolute().string,
      input.lastComponent,
    ], workingDirectory: input.parent()).run()
  }
}
