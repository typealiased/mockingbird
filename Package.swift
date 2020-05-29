// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Mockingbird",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v8),
    .tvOS(.v9),
  ],
  products: [
    .library(name: "Mockingbird", targets: ["Mockingbird"]),
  ],
  targets: [
    .target(
      name: "Mockingbird",
      path: "Sources/MockingbirdFramework",
      linkerSettings: [.linkedFramework("XCTest")]
    ),
  ]
)
