// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Mockingbird",
  products: [
    .library(name: "Mockingbird", targets: ["MockingbirdFramework"]),
    .executable(name: "mockingbird", targets: ["MockingbirdCli"])
  ],
  dependencies: [
//    .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
    .package(url: "https://github.com/andrewchang-bird/Commander.git", from: "0.9.1"), // Carthage support
//    .package(url: "https://github.com/tuist/XcodeProj.git", from: "7.0.0"),
    .package(url: "https://github.com/andrewchang-bird/XcodeProj.git", from: "7.0.1"), // Carthage support
    .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.24.0"),
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
        "MockingbirdShared"
      ],
      path: "MockingbirdFramework"
    ),
    .target(
      name: "MockingbirdCli",
      dependencies: [
        "Commander",
        "SourceKittenFramework",
        "XcodeProj",
        "MockingbirdShared",
      ],
      path: "MockingbirdCli"
    ),
    .testTarget(
      name: "MockingbirdTests",
      dependencies: [
        "MockingbirdFramework"
      ],
      path: "MockingbirdTests",
      exclude: [
        "Resources",
      ]
    )
  ]
)
