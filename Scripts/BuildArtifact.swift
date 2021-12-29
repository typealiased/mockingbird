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
  
  static func archive(artifacts: [Path], destination: Path, includeLicense: Bool = true) throws {
    guard !artifacts.isEmpty else {
      logError("No artifacts to archive")
      return
    }
    guard destination.extension == "zip" else {
      logError("Archive destination is not a ZIP file")
      return
    }
      
    let stagingPath = Path("./.build/mockingbird/intermediates")
      + destination.lastComponentWithoutExtension
    try? stagingPath.delete()
    try stagingPath.mkpath()
    
    var items = artifacts
    if includeLicense { items.append(Path("./LICENSE.md")) }
    try items.forEach({ try $0.copy(stagingPath + $0.lastComponent) })
    
    try? destination.delete()
    try destination.parent().mkpath()
    try FileManager().zipItem(at: stagingPath.url, to: destination.url, compressionMethod: .deflate)
  }
  
  struct BuildCli: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "cli")
    
    @Flag(help: "Allow the CLI to run from system directories.")
    var installable: Bool = false
    
    @OptionGroup()
    var globalOptions: Options
    
    func run() throws {
      let packagePath = Path("./Package.swift")
      let installableOptions: [String] = installable ? ["-Xswiftc", "-DMKB_INSTALLABLE"] : []
      var environment = ProcessInfo.processInfo.environment
      environment["MKB_BUILD_TYPE"] = "1"
      let cliPath = try SwiftPackage.build(target: .product(name: "mockingbird"),
                                           configuration: .release,
                                           buildOptions: [
                                            "-Xlinker", "-weak-l_InternalSwiftSyntaxParser",
                                           ] + installableOptions,
                                           environment: environment,
                                           package: packagePath)
      if let location = globalOptions.archiveLocation {
        try archive(artifacts: [cliPath], destination: Path(location))
      }
    }
  }
  
  struct BuildFramework: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "framework")
    
    @Option(help: "The target platform.")
    var platform: Carthage.Platform = .all
    
    @OptionGroup()
    var globalOptions: Options
    
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
        try archive(artifacts: [frameworkPath], destination: Path(location))
      }
    }
  }
}

extension Carthage.Platform: ExpressibleByArgument {}

BuildArtifact.main()
