import Foundation
import PathKit

public struct SwiftPackage {
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
  
  public static func update(package: Path) throws {
    try Subprocess("xcrun", ["swift", "package", "update"],
                   workingDirectory: package.parent()).runWithOutput()
  }
  
  public static func test(productName: String? = nil, package: Path) throws {
    let testProductArguments: [String] = {
      guard let name = productName else { return [] }
      return ["--test-product", name]
    }()
    try Subprocess("xcrun", ["swift", "test"] + testProductArguments,
                   workingDirectory: package.parent()).runWithOutput()
  }
  
  public static func build(target: BuildTarget,
                           configuration: BuildConfiguration = .debug,
                           buildOptions: [String] = [],
                           environment: [String: String] = ProcessInfo.processInfo.environment,
                           package: Path) throws {
    try Subprocess(
      "xcrun", [
        "swift",
        "build",
        "--\(target.optionName)", target.name,
        "--configuration", configuration.rawValue,
      ] + buildOptions,
      environment: environment,
      workingDirectory: package.parent()).runWithOutput()
  }
}
