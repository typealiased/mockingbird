// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "Mockingbird",
  platforms: [
    .macOS(.v10_10),
    .iOS(.v9),
    .tvOS(.v9),
  ],
  products: [
    .library(name: "Mockingbird", targets: ["Mockingbird", "MockingbirdObjC", "MockingbirdBridge"]),
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
