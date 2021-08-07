// swift-tools-version:5.2
import PackageDescription
import class Foundation.ProcessInfo

let package: Package

// SwiftUI previews fail when including the `mockingbird` executable target.
if ProcessInfo.processInfo.environment["MKB_BUILD_CLI"] == nil {
  // MARK: Framework
  package = Package(
    name: "Mockingbird",
    platforms: [
      .macOS(.v10_10),
      .iOS(.v9),
      .tvOS(.v9),
    ],
    products: [
      .library(name: "Mockingbird", targets: [
        "Mockingbird",
        "MockingbirdObjC",
        "MockingbirdBridge"
      ]),
    ],
    targets: [
      .target(
        name: "Mockingbird",
        dependencies: ["MockingbirdBridge"],
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
} else {
  // MARK: CLI
  package = Package(
    name: "Mockingbird",
    platforms: [
      .macOS(.v10_13),
    ],
    products: [
      .executable(name: "mockingbird", targets: ["MockingbirdCli"]),
      .library(name: "MockingbirdGenerator", targets: ["MockingbirdGenerator"]),
    ],
    // These dependencies must be kept in sync with the Xcode project.
    // TODO: Add a build rule to enforce consistency.
    dependencies: [
      .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.4.0")),
      .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50400.0")),
      .package(url: "https://github.com/jpsim/SourceKitten.git", .exact("0.30.0")),
      .package(url: "https://github.com/tuist/XcodeProj.git", .exact("7.14.0")),
      .package(url: "https://github.com/weichsel/ZIPFoundation.git", .exact("0.9.11")),
    ],
    targets: [
      .target(
        name: "MockingbirdCli",
        dependencies: [
          .product(name: "SPMUtility", package: "swift-package-manager"),
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
          .product(name: "SwiftSyntax", package: "swift-syntax"),
          "XcodeProj",
        ],
        path: "Sources/MockingbirdGenerator"
      ),
    ]
  )
}
