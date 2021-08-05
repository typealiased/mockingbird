// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Mockingbird",
  platforms: [
    .macOS(.v10_10),
    .iOS(.v9),
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
