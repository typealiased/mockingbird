// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Mockingbird",
  products: [
    .library(name: "Mockingbird", targets: ["MockingbirdFramework"]),
    .executable(name: "mockingbird", targets: ["MockingbirdCli"]),
  ],
  dependencies: [
    .package(url: "https://github.com/tuist/XcodeProj.git", from: "7.0.0"),
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.24.0"),
    .package(url: "https://github.com/apple/swift-package-manager.git", .exact("0.4.0")),
  ],
  targets: [
    .target(
      name: "MockingbirdShared",
      dependencies: [],
      path: "MockingbirdShared"
    ),
    .target(
      name: "MockingbirdFramework",
      dependencies: [
        "MockingbirdShared",
      ],
      path: "MockingbirdFramework"
    ),
    .target(
      name: "MockingbirdCli",
      dependencies: [
        "MockingbirdShared",
        "SourceKittenFramework",
        "SPMUtility",
        "XcodeProj",
      ],
      path: "MockingbirdCli"
    ),
    .target(
      name: "MockingbirdTestsHost",
      dependencies: [],
      path: "MockingbirdTestsHost"
    ),
    .testTarget(
      name: "MockingbirdTests",
      dependencies: [
        "MockingbirdFramework",
        "MockingbirdTestsHost",
      ],
      path: "MockingbirdTests",
      exclude: [
        "Resources",
      ]
    )
  ]
)
