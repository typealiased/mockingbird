// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "SPMPackageExample",
  products: [
    .library(
      name: "SPMPackageExample",
      targets: ["SPMPackageExample"]),
  ],
  dependencies: [
    .package(
      name: "Mockingbird",
      url: "https://github.com/birdrides/mockingbird.git",
      .upToNextMinor(from: "0.19.0")),
  ],
  targets: [
    .target(
      name: "SPMPackageExample",
      dependencies: []),
    .testTarget(
      name: "SPMPackageExampleTests",
      dependencies: ["SPMPackageExample", "Mockingbird"]),
  ]
)
