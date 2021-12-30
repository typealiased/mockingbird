#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import PathKit  // @kylef == 1.0.1
import Foundation
import ZIPFoundation  // @weichsel == 0.9.14

struct BuildArtifact: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Build a project artifact.",
    subcommands: [
      BuildCli.self,
      BuildFramework.self,
    ])
  
  struct Options: ParsableArguments {
    @Option(name: .customLong("archive"), help: "File path to store archived built products.")
    var archiveLocation: String?
  }
  
  @OptionGroup()
  var globalOptions: Options
  
  static func archive(artifacts: [(location: String, path: Path)],
                      destination: Path,
                      includeLicense: Bool = true) throws {
    guard !artifacts.isEmpty else {
      logError("No artifacts to archive")
      return
    }
    guard destination.extension == "zip" else {
      logError("Archive destination is not a ZIP file")
      return
    }
    logInfo("Creating archive at \(destination.abbreviate())")
      
    let stagingPath = Path("./.build/mockingbird/intermediates")
      + destination.lastComponentWithoutExtension
    try? stagingPath.delete()
    try stagingPath.mkpath()
    
    var items = artifacts
    if includeLicense { items.append(("", Path("./LICENSE.md"))) }
    try items.forEach({ artifact in
      let destination = stagingPath + artifact.location + artifact.path.lastComponent
      try destination.parent().mkpath()
      try artifact.path.copy(destination)
    })
    
    try? destination.delete()
    try destination.parent().mkpath()
    try FileManager().zipItem(at: stagingPath.url, to: destination.url, compressionMethod: .deflate)
  }
  
  struct BuildCli: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "cli",
      abstract: "Build the command line interface.")
    
    @Option(name: .customLong("sign"), help: "Identity used to sign the built binary.")
    var signingIdentity: String?
    
    @Option(help: "File path containing the designated requirement for codesigning.")
    var requirements: String = "./Scripts/Resources/CodesigningRequirements/mockingbird.txt"
    
    @OptionGroup()
    var globalOptions: Options
    
    func getVersionString() throws -> String {
      return try PlistBuddy.printValue(key: "CFBundleShortVersionString",
                                       plist: Path("./Sources/MockingbirdCli/Info.plist"))
    }
    
    func fixupRpaths(binary: Path) throws {
      let version = try getVersionString()
      
      // Get rid of toolchain-dependent rpaths which aren't guaranteed to have a compatible version
      // of the internal SwiftSyntax parser lib.
      let developerDirectory = try XcodeSelect.printPath()
      let swiftToolchainPath = developerDirectory
        + "Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"
      try InstallNameTool.deleteRpath(swiftToolchainPath.absolute().string, binary: binary)
      // Swift 5.5 is only present in Xcode 13.2+
      let swift5_5ToolchainPath = developerDirectory
        + "Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.5/macosx"
      try? InstallNameTool.deleteRpath(swift5_5ToolchainPath.absolute().string, binary: binary)
      
      // Add new rpaths in descending order of precedence.
      try InstallNameTool.addRpath("/usr/lib/mockingbird/\(version)", binary: binary)
      // Support environments with restricted write permissions to system resources.
      try InstallNameTool.addRpath("/var/tmp/lib/mockingbird/\(version)", binary: binary)
      try InstallNameTool.addRpath("/tmp/lib/mockingbird/\(version)", binary: binary)
    }
    
    func run() throws {
      let packagePath = Path("./Package.swift")
      var environment = ProcessInfo.processInfo.environment
      environment["MKB_BUILD_TYPE"] = "1"
      let cliPath = try SwiftPackage.build(target: .product(name: "mockingbird"),
                                           configuration: .release,
                                           environment: environment,
                                           package: packagePath)
      try fixupRpaths(binary: cliPath)
      if let identity = signingIdentity {
        try Codesign.sign(binary: cliPath, identity: identity)
        try Codesign.verify(binary: cliPath, requirements: Path(requirements))
      }
      if let location = globalOptions.archiveLocation {
        let libRoot = Path("./Sources/MockingbirdCli/Libraries")
        let libPaths = libRoot.glob("*.dylib") + [libRoot + "LICENSE.txt"]
        try archive(artifacts: [("", cliPath)] + libPaths.map({ ("Libraries", $0) }),
                    destination: Path(location))
      }
    }
  }
  
  struct BuildFramework: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "framework",
      abstract: "Build a fat XCFramework bundle.")
    
    @Option(help: "The target platform.")
    var platform: Carthage.Platform = .all
    
    @OptionGroup()
    var globalOptions: Options
    
    func getVersionString() throws -> String {
      return try PlistBuddy.printValue(key: "CFBundleShortVersionString",
                                       plist: Path("./Sources/MockingbirdFramework/Info.plist"))
    }
    
    func run() throws {
      // Carthage with `--no-skip-current` searches for matching schemes in all nested Xcode
      // projects and workspaces, even with `--project-directory` specified. To avoid building the
      // framework via the example project dependencies, we lock the Example directory by making it
      // write-only until the build completes.
      logInfo("Locking the example projects directory")
      let exampleProjects = Path("./Examples")
      let fileManager = FileManager()
      try fileManager.setAttributes([.posixPermissions: FileManager.PosixPermissions.writeOnly],
                                    ofItemAtPath: exampleProjects.string)
      defer {
        logInfo("Unlocking the example projects directory")
        try? fileManager.setAttributes([.posixPermissions: FileManager.PosixPermissions.readWrite],
                                       ofItemAtPath: exampleProjects.string)
      }

      let projectPath = Path("./Mockingbird.xcodeproj")
      try Carthage.build(platform: platform, project: projectPath)
      
      // Carthage doesn't provide a way to query for the built product path, so this is inferred.
      let frameworkPath = projectPath.parent() + "Carthage/Build/Mockingbird.xcframework"
      
      if let location = globalOptions.archiveLocation {
        try archive(artifacts: [("", frameworkPath)], destination: Path(location))
      }
    }
  }
}

extension Carthage.Platform: ExpressibleByArgument {}

BuildArtifact.main()
