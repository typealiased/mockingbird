// swift-tools-version:5.2
import PackageDescription
import class Foundation.ProcessInfo

// MARK: - Build flavors
// SwiftUI previews fail when including the `mockingbird` executable target, so builds are kept
// separate and gated by the `MKB_BUILD_TYPE` environment variable.
enum BuildType: Int {
  case framework = 0
  case cli = 1
  case automation = 2
  
  init(_ environment: [String: String]) {
    if let environmentBuildType = environment["MKB_BUILD_TYPE"],
       let rawValue = Int(environmentBuildType),
       let buildType = BuildType(rawValue: rawValue) {
      self = buildType
    } else {
      self = .framework
    }
  }
}
let buildType = BuildType(ProcessInfo.processInfo.environment)

// MARK: - Shared targets
let commonTarget: Target = .target(
  name: "MockingbirdCommon",
  path: "Sources/MockingbirdCommon"
)

// MARK: - Package
let package: Package
switch buildType {
case .framework:
  // MARK: Framework
  package = Package(
    name: "Mockingbird",
    platforms: [
      .macOS(.v10_10),
      .iOS(.v9),
      .tvOS(.v9),
    ],
    products: [
      .library(name: "Mockingbird", targets: ["Mockingbird", "MockingbirdObjC"]),
    ],
    targets: [
      commonTarget,
      .target(
        name: "Mockingbird",
        dependencies: ["MockingbirdBridge", "MockingbirdCommon"],
        path: "Sources/MockingbirdFramework",
        exclude: ["Objective-C"],
        swiftSettings: [.define("MKB_SWIFTPM")],
        linkerSettings: [.linkedFramework("XCTest")]
      ),
      .target(
        name: "MockingbirdObjC",
        dependencies: ["Mockingbird", "MockingbirdBridge"],
        path: "Sources/MockingbirdFramework/Objective-C",
        exclude: ["Bridge"],
        cSettings: [
          .headerSearchPath("./"),
          .define("MKB_SWIFTPM"),
        ]
      ),
      .target(
        name: "MockingbirdBridge",
        path: "Sources/MockingbirdFramework/Objective-C/Bridge",
        cSettings: [
          .headerSearchPath("include"),
          .define("MKB_SWIFTPM"),
        ]
      ),
    ]
  )
  
case .cli:
  // MARK: CLI
  package = Package(
    name: "Mockingbird",
    platforms: [
      .macOS(.v10_15),
    ],
    products: [
      .executable(name: "mockingbird", targets: ["MockingbirdCli"]),
      .library(name: "MockingbirdGenerator", targets: ["MockingbirdGenerator"]),
    ],
    // These dependencies must be kept in sync with the Xcode project.
    // TODO: Add a build rule to enforce consistency.
    dependencies: [
      .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("1.0.2")),
      .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50500.0")),
      .package(url: "https://github.com/jpsim/SourceKitten.git", .exact("0.30.0")),
      .package(url: "https://github.com/tuist/XcodeProj.git", .exact("8.7.1")),
      .package(url: "https://github.com/weichsel/ZIPFoundation.git", .exact("0.9.11")),
    ],
    targets: [
      commonTarget,
      .target(
        name: "MockingbirdCli",
        dependencies: [
          .product(name: "ArgumentParser", package: "swift-argument-parser"),
          "MockingbirdCommon",
          "MockingbirdGenerator",
          "XcodeProj",
          "ZIPFoundation",
        ],
        path: "Sources/MockingbirdCli"
      ),
      .target(
        name: "MockingbirdGenerator",
        dependencies: [
          .product(name: "SourceKittenFramework", package: "SourceKitten"),
          "MockingbirdCommon",
          "SwiftSyntax",
          "XcodeProj",
        ],
        path: "Sources/MockingbirdGenerator"
      ),
    ]
  )
  
case .automation:
  // MARK: Automation
  package = Package(
    name: "Mockingbird",
    platforms: [
      .macOS(.v10_15),
    ],
    products: [
      .library(name: "MockingbirdAutomation", targets: ["MockingbirdAutomation"]),
    ],
    // These dependencies must be kept in sync with the Xcode project.
    // TODO: Add a build rule to enforce consistency.
    dependencies: [
      .package(url: "https://github.com/kylef/PathKit.git", .exact("1.0.1")),
    ],
    targets: [
      commonTarget,
      .target(
        name: "MockingbirdAutomation",
        dependencies: ["MockingbirdCommon", "PathKit"],
        path: "Sources/MockingbirdAutomation"
      ),
    ]
  )
  break
}
