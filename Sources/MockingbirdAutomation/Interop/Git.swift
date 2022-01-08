import Foundation
import PathKit

public enum Git {
  public static func getHEAD(short: Bool = false, repository: Path) throws -> String {
    var options: [String] = []
    if short { options.append("--short") }
    let (rev, _) = try Subprocess("git", ["rev-parse", "HEAD"] + options,
                                  workingDirectory: repository).runWithStringOutput()
    return rev.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
