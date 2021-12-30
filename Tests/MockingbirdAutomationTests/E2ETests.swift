//
//  E2ETests.swift
//  MockingbirdAutomationTests
//
//  Created by typealias on 12/29/21.
//

import MockingbirdAutomation
import MockingbirdCommon
import PathKit
import XCTest

class E2ETests: XCTestCase {
  
  var sourceRoot: Path!
  var projectPath: Path!
  var backupProjectPath: Path!
  var cliPath: Path!
  
  override func setUpWithError() throws {
    guard let srcroot = ProcessInfo.processInfo.environment["SRCROOT"] else {
      preconditionFailure("Missing 'SRCROOT' environment variable")
    }
    
    sourceRoot = Path(srcroot)
    precondition(sourceRoot.isDirectory)
    projectPath = sourceRoot + "Mockingbird.xcodeproj"
    precondition(projectPath.isDirectory)
    
    // The backup project is used to restore the original state after each test.
    backupProjectPath = sourceRoot + "Mockingbird.xcodeproj.backup"
    try? backupProjectPath.delete()
    try projectPath.copy(backupProjectPath)
    
    var environment = ProcessInfo.processInfo.environment
    environment[BuildType.environmentKey] = String(BuildType.cli.rawValue)
    cliPath = try SwiftPackage.build(target: .product(name: "mockingbird"),
                                     configuration: .release,
                                     environment: environment,
                                     package: sourceRoot + "Package.swift")
    
    try cleanTestIntermediates()
  }
  
  override func tearDownWithError() throws {
    try cleanTestIntermediates()
    
    guard backupProjectPath.isDirectory else {
      fatalError("Missing backup Xcode project at \(backupProjectPath.abbreviate())")
      return
    }
    try projectPath.delete()
    try backupProjectPath.move(projectPath)
  }
  
  func cleanTestIntermediates() throws {
    try? (sourceRoot + "MockingbirdMocks").delete()
    try? (projectPath + "MockingbirdCache").delete()
  }
  
  func testDefaultConfiguration() throws {
    try Subprocess(cliPath.absolute().string, [
      "configure",
      "MockingbirdTests",
      "--verbose",
      "--",
      "--targets", "MockingbirdTestsHost", "MockingbirdShadowedTestsHost",
      "--support", "Sources/MockingbirdSupport",
      "--diagnostics", "all",
      "--verbose",
    ], workingDirectory: sourceRoot).runWithOutput()
    
    try? XcodeBuild.test(target: .scheme(name: "MockingbirdTests"),
                         project: .project(path: projectPath),
                         destination: .macOS)
    
    let testsHostMocks = sourceRoot
      + "MockingbirdMocks/MockingbirdTests-MockingbirdTestsHostMocks.generated.swift"
    let shadowedTestsHostMocks = sourceRoot
      + "MockingbirdMocks/MockingbirdTests-MockingbirdShadowedTestsHostMocks.generated.swift"
    
    XCTAssertTrue(testsHostMocks.isFile)
    XCTAssertTrue(shadowedTestsHostMocks.isFile)
  }
  
  func testThunkPruningStubs() throws {
    try Subprocess(cliPath.absolute().string, [
      "configure",
      "MockingbirdTests",
      "--verbose",
      "--",
      "--targets", "MockingbirdTestsHost", "MockingbirdShadowedTestsHost",
      "--support", "Sources/MockingbirdSupport",
      "--prune", "stub",
      "--diagnostics", "all",
      "--verbose",
    ], workingDirectory: sourceRoot).runWithOutput()
    
    try XcodeBuild.test(target: .scheme(name: "MockingbirdTests"),
                         project: .project(path: projectPath),
                         destination: .macOS)
    
    let testsHostMocks = sourceRoot
      + "MockingbirdMocks/MockingbirdTests-MockingbirdTestsHostMocks.generated.swift"
    let contents = try testsHostMocks.read(.utf8)
    XCTAssertTrue(contents.contains(#"fatalError("See 'Thunk Pruning' in the README")"#))
  }
  
  func testThunkPruningDisabled() throws {
    try Subprocess(cliPath.absolute().string, [
      "configure",
      "MockingbirdTests",
      "--verbose",
      "--",
      "--targets", "MockingbirdTestsHost", "MockingbirdShadowedTestsHost",
      "--support", "Sources/MockingbirdSupport",
      "--prune", "disable",
      "--diagnostics", "all",
      "--verbose",
    ], workingDirectory: sourceRoot).runWithOutput()
    
    try XcodeBuild.test(target: .scheme(name: "MockingbirdTests"),
                         project: .project(path: projectPath),
                         destination: .macOS)
    
    let testsHostMocks = sourceRoot
      + "MockingbirdMocks/MockingbirdTests-MockingbirdTestsHostMocks.generated.swift"
    let contents = try testsHostMocks.read(.utf8)
    XCTAssertFalse(contents.contains(#"fatalError("See 'Thunk Pruning' in the README")"#))
  }
  
  func testCachingDisabled() throws {
    try Subprocess(cliPath.absolute().string, [
      "configure",
      "MockingbirdTests",
      "--verbose",
      "--",
      "--targets", "MockingbirdTestsHost", "MockingbirdShadowedTestsHost",
      "--support", "Sources/MockingbirdSupport",
      "--prune", "disable",
      "--disable-cache",
      "--diagnostics", "all",
      "--verbose",
    ], workingDirectory: sourceRoot).runWithOutput()
    
    try? XcodeBuild.test(target: .scheme(name: "MockingbirdTests"),
                         project: .project(path: projectPath),
                         destination: .macOS)
    
    let targetLockFiles = (sourceRoot + "Mockingbird.xcodeproj/MockingbirdCache").glob("*.lock")
    XCTAssertEqual(targetLockFiles.count, 0)
  }
  
  func testCustomHeader() throws {
    try Subprocess(cliPath.absolute().string, [
      "configure",
      "MockingbirdTests",
      "--verbose",
      "--",
      "--targets", "MockingbirdTestsHost", "MockingbirdShadowedTestsHost",
      "--support", "Sources/MockingbirdSupport",
      "--prune", "disable",
      "--header", "// CUSTOM HEADER - LINE 1", "// CUSTOM HEADER - LINE 2",
      "--diagnostics", "all",
      "--verbose",
    ], workingDirectory: sourceRoot).runWithOutput()
    
    try XcodeBuild.test(target: .scheme(name: "MockingbirdTests"),
                        project: .project(path: projectPath),
                        destination: .macOS)
    
    let testsHostMocks = sourceRoot
      + "MockingbirdMocks/MockingbirdTests-MockingbirdTestsHostMocks.generated.swift"
    let contents = try testsHostMocks.read(.utf8)
    XCTAssertTrue(contents.contains(#"// CUSTOM HEADER - LINE 1"#))
    XCTAssertTrue(contents.contains(#"// CUSTOM HEADER - LINE 2"#))
  }
  
  func testOutputFlakiness() throws {
    var expectedHash: String?
    for _ in 0...10 {
      // Call the generator directly as it takes a while to run the entire test suite.
      try Subprocess(cliPath.absolute().string, [
        "generate",
        "--testbundle", "MockingbirdTests",
        "--targets", "MockingbirdTestsHost",
        "--support", "Sources/MockingbirdSupport",
        "--prune", "disable",
        "--diagnostics", "all",
        "--disable-cache",
        "--verbose",
      ], workingDirectory: sourceRoot).runWithOutput()
    
      let testsHostMocks = sourceRoot
        + "MockingbirdMocks/MockingbirdTestsHostMocks.generated.swift"
      let actualHash = try testsHostMocks.read().hash()
      if expectedHash == nil { expectedHash = actualHash }
      XCTAssertEqual(actualHash, expectedHash)
    }
  }
}
