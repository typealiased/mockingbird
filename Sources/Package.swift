// swift-tools-version:5.0
import PackageDescription

// Package configuration for local development.
let package = Package(
  name: "MockingbirdCli",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v8),
    .tvOS(.v9),
  ],
  products: [
    .executable(name: "mockingbird", targets: ["MockingbirdCli"]),
    .library(name: "Mockingbird", targets: ["Mockingbird"]),
    .library(name: "MockingbirdGenerator", targets: ["MockingbirdGenerator"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.4.0")),
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50200.0")),
    .package(url: "https://github.com/jpsim/SourceKitten.git", .exact("0.24.0")),
    .package(url: "https://github.com/tuist/XcodeProj.git", .exact("7.0.0")),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", .exact("0.9.11")),
  ],
  targets: [
    .target(
      name: "Mockingbird",
      path: "MockingbirdFramework",
      linkerSettings: [.linkedFramework("XCTest")]
    ),
    .target(
      name: "MockingbirdCli",
      dependencies: [
        "MockingbirdGenerator",
        "SPMUtility",
        "XcodeProj",
        "ZIPFoundation",
      ],
      path: "MockingbirdCli"
    ),
    .target(
      name: "MockingbirdGenerator",
      dependencies: [
        "SourceKittenFramework",
        "SwiftSyntax",
        "XcodeProj",
      ],
      path: "MockingbirdGenerator"
    ),
    .target(
      name: "MockingbirdTestsHost",
      dependencies: [
        "MockingbirdModuleTestsHost",
      ],
      path: "MockingbirdTestsHost",
      exclude: ["Module", "Performance"]
    ),
    .target(
      name: "MockingbirdModuleTestsHost",
      path: "MockingbirdTestsHost/Module"
    ),
    .target(
      name: "MockingbirdPerformanceTestsHost",
      path: "MockingbirdTestsHost/Performance"
    ),
    // Uncomment before running `$ swift package generate-xcodeproj`.
//    .testTarget(
//      name: "MockingbirdTests",
//      dependencies: [
//        "Mockingbird",
//        "MockingbirdGenerator",
//        "MockingbirdTestsHost",
//        "MockingbirdPerformanceTestsHost",
//      ],
//      path: "Tests/MockingbirdTests"
//    ),
  ]
)
