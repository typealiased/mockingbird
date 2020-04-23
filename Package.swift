// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Mockingbird",
  products: [
    .library(name: "Mockingbird", targets: ["MockingbirdFramework"]),
    .executable(name: "mockingbird", targets: ["MockingbirdCli"]),
    
    // For local dev only. Uncomment before running `$ swift package generate-xcodeproj`.
    //.library(name: "MockingbirdGenerator", targets: ["MockingbirdGenerator"]),
  ],
  dependencies: [
    .package(url: "https://github.com/tuist/XcodeProj.git", from: "7.0.0"),
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.24.0"),
    .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.4.0")),
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50200.0")),
  ],
  targets: [
    .target(
      name: "MockingbirdFramework",
      dependencies: [],
      path: "MockingbirdFramework",
      linkerSettings: [.linkedFramework("XCTest")]
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
      name: "MockingbirdCli",
      dependencies: [
        "MockingbirdGenerator",
        "SPMUtility",
        "XcodeProj",
      ],
      path: "MockingbirdCli"
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
      dependencies: [],
      path: "MockingbirdTestsHost/Module"
    ),
    .target(
      name: "MockingbirdPerformanceTestsHost",
      dependencies: [],
      path: "MockingbirdTestsHost/Performance"
    ),
    .testTarget(
      name: "MockingbirdTests",
      dependencies: [
        "MockingbirdFramework",
        "MockingbirdGenerator",
        "MockingbirdTestsHost",
        "MockingbirdPerformanceTestsHost",
      ],
      path: "MockingbirdTests"
    )
  ]
)
