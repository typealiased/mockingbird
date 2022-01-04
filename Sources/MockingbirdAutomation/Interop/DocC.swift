import Foundation
import PathKit

public enum DocC {
  static func getEnvironment(
    _ baseEnvironment: [String: String] = ProcessInfo.processInfo.environment,
    renderer: Path?
  ) -> [String: String] {
    var environment = baseEnvironment
    if let renderer = renderer {
      environment["DOCC_HTML_DIR"] = renderer.string
    }
    return environment
  }
  
  public static func preview(bundle: Path,
                             symbolGraph: Path,
                             renderer: Path? = nil) throws {
    try Subprocess("xcrun", [
      "docc",
      "preview", bundle.string,
      "--additional-symbol-graph-dir", symbolGraph.string,
    ], environment: getEnvironment(renderer: renderer)).run()
  }
  
  public static func convert(bundle: Path,
                             symbolGraph: Path,
                             renderer: Path? = nil,
                             output: Path) throws {
    try Subprocess("xcrun", [
      "docc",
      "convert", bundle.string,
      "--additional-symbol-graph-dir", symbolGraph.string,
      "--output-dir", output.string,
    ], environment: getEnvironment(renderer: renderer)).run()
  }
}
