#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import PathKit  // @kylef == 1.0.1
import Foundation

struct BuildArtifact: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Build a project artifact.",
    subcommands: [
      BuildCli.self,
      BuildFramework.self,
    ])
  
  struct BuildCli: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "cli")
    
    @Flag(help: "Allow the CLI to run from system directories.")
    var installable: Bool = false
    
    func run() throws {
      let packagePath = Path("./Package.swift")
      let installableOptions: [String] = installable ? ["-Xswiftc", "-DMKB_INSTALLABLE"] : []
      var environment = ProcessInfo.processInfo.environment
      environment["MKB_BUILD_TYPE"] = "1"
      try SwiftPackage.build(target: .product(name: "mockingbird"),
                             configuration: .release,
                             buildOptions: [
                              "-Xlinker", "-weak-l_InternalSwiftSyntaxParser",
                             ] + installableOptions,
                             environment: environment,
                             package: packagePath)
    }
  }
  
  struct BuildFramework: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "framework")
    
    @Option(help: "The target platform.")
    var platform: Carthage.Platform = .all
    
    func run() throws {
      // Carthage with `--no-skip-current` searches for matching schemes in all nested Xcode
      // projects and workspaces, even with `--project-directory` specified. To avoid building the
      // framework via the example project dependencies, we lock the Example directory by making it
      // write-only until the build completes.
      logInfo("Locking the example projects directory")
      let exampleProjects = Path("./Examples")
      let fileManager = FileManager.default
      try fileManager.setAttributes([.posixPermissions: FileManager.PosixPermissions.writeOnly],
                                    ofItemAtPath: exampleProjects.string)
      defer {
        logInfo("Unlocking the example projects directory")
        try? fileManager.setAttributes([.posixPermissions: FileManager.PosixPermissions.readWrite],
                                       ofItemAtPath: exampleProjects.string)
      }

      let projectPath = Path("./Mockingbird.xcodeproj")
      try Carthage.build(platform: platform, project: projectPath)
    }
  }
}

extension Carthage.Platform: ExpressibleByArgument {}

BuildArtifact.main()
