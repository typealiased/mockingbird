import Foundation
import PathKit

public enum SwiftPackage {
  public enum BuildTarget {
    case target(name: String)
    case product(name: String)
    var name: String {
      switch self {
      case .target(let name),
           .product(let name):
        return name
      }
    }
    var optionName: String {
      switch self {
      case .target: return "target"
      case .product: return "product"
      }
    }
  }
  
  public enum BuildConfiguration: String {
    case debug = "debug"
    case release = "release"
  }
  
  /// Only for the main Mockingbird package manifest.
  public enum PackageConfiguration {
    case libraries
    case executables
    func getEnvironment(
      _ baseEnvironment: [String: String] = ProcessInfo.processInfo.environment
    ) -> [String: String] {
      var processEnvironment = baseEnvironment
      processEnvironment["MKB_BUILD_EXECUTABLES"] = {
        switch self {
        case .libraries: return "0"
        case .executables: return "1"
        }
      }()
      return processEnvironment
    }
  }
  
  public static func update(package: Path,
                            environment: [String: String] = ProcessInfo.processInfo.environment,
                            packageConfiguration: PackageConfiguration? = nil) throws {
    try Subprocess("xcrun", ["swift", "package", "update"],
                   environment: packageConfiguration?.getEnvironment(environment) ?? environment,
                   workingDirectory: package.parent()).run()
  }
  
  public static func test(productName: String? = nil,
                          environment: [String: String] = ProcessInfo.processInfo.environment,
                          packageConfiguration: PackageConfiguration? = nil,
                          package: Path) throws {
    let testProductArguments: [String] = {
      guard let name = productName else { return [] }
      return ["--test-product", name]
    }()
    try Subprocess("xcrun", ["swift", "test"] + testProductArguments,
                   environment: packageConfiguration?.getEnvironment(environment) ?? environment,
                   workingDirectory: package.parent()).run()
  }
  
  public static func build(target: BuildTarget,
                           configuration: BuildConfiguration = .debug,
                           environment: [String: String] = ProcessInfo.processInfo.environment,
                           packageConfiguration: PackageConfiguration? = nil,
                           package: Path) throws -> Path {
    let buildArguments = [
      "swift",
      "build",
      "--\(target.optionName)", target.name,
      "--configuration", configuration.rawValue,
    ]
    let environment = packageConfiguration?.getEnvironment(environment) ?? environment
    try Subprocess("xcrun", buildArguments + ["--verbose"],
                   environment: environment,
                   workingDirectory: package.parent()).run()
    let (binPath, _) = try Subprocess("xcrun", buildArguments + ["--show-bin-path"],
                                      environment: environment,
                                      workingDirectory: package.parent()).runWithStringOutput()
    return Path(binPath.trimmingCharacters(in: .whitespacesAndNewlines)) + "mockingbird"
  }
  
  public static func emitSymbolGraph(
    target: BuildTarget,
    environment: [String: String] = ProcessInfo.processInfo.environment,
    packageConfiguration: PackageConfiguration? = nil,
    output: Path,
    package: Path
  ) throws {
    let environment = packageConfiguration?.getEnvironment(environment) ?? environment
    try Subprocess("xcrun", [
      "swift",
      "build",
      "--\(target.optionName)", target.name,
      "-Xswiftc", "-emit-symbol-graph",
      "-Xswiftc", "-emit-symbol-graph-dir", "-Xswiftc", output.string,
    ], environment: environment, workingDirectory: package.parent()).run()
  }
}
