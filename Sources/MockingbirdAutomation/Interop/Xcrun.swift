import Foundation

public enum Xcrun {
  /// Returns a command an list of arguments based on the availability of xcrun.
  public static func createCommand(from arguments: [String]) throws -> (command: String,
                                                                        arguments: [String]) {
    let exitCode = try Subprocess("command", ["-v", "xcrun"]).runWithExitCode()
    if exitCode == 0 {
      return ("xcrun", arguments)
    } else if let command = arguments.first {
      return (command, Array(arguments.dropFirst()))
    } else {
      return ("", [])
    }
  }
}
