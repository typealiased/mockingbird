// swift-tools-version:5.0
import PackageDescription

// Package configuration for building the CLI using `$ swift build`.
let package = Package(
  name: "MockingbirdCli",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v8),
    .tvOS(.v9),
  ],
  products: [
    .executable(name: "mockingbird", targets: ["MockingbirdCli"]),
    .library(name: "MockingbirdGenerator", targets: ["MockingbirdGenerator"]),
  ],
  // Keep this in sync with the Mockingbird.xcodeproj dependencies!
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
  ]
)
