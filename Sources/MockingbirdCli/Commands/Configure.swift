//
//  Configure.swift
//  MockingbirdCli
//
//  Created by typealias on 8/7/21.
//

import ArgumentParser
import Foundation
import PathKit
import MockingbirdGenerator

extension Mockingbird {
  struct Configure: ParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Configure a test target to generate mocks."
    )
    
    /// Inherited from parent command.
    @OptionGroup() var globalOptions: Options
    
    @Argument(help: "The name of a test target to configure.")
    var testTarget: String
    
    @Option(name: [.customLong("project"),
                   .customShort("p")],
            help: "Path to an Xcode project.")
    var project: XcodeProjPath?
    
    @Option(name: [.customLong("srcproject")],
            help: "Path to the Xcode project with source modules, if separate from tests.")
    var sourceProject: XcodeProjPath?
    
    @Option(help: "Path to the Mockingbird generator executable.")
    var generator: BinaryPath?
    
    @Option(name: [.customLong("url")],
            help: "The base URL hosting downloadable asset bundles.")
    var baseURL: URLArgument = URLArgument(URL(string: "https://github.com/birdrides/mockingbird/releases/download")!)
    
    // MARK: Flags
    
    @Flag(help: "Keep previously added Mockingbird build phases.")
    var preserveExisting: Bool = false
    
    // MARK: Generator
    
    @Argument(help: "Arguments to use when running the generator. See the 'generate' command for all options.")
    var generatorOptions: [String] = []
    
    struct Arguments {
      let testTarget: String
      let project: Path
      let sourceProject: Path
      let generator: Path
      let baseURL: URL
      let preserveExisting: Bool
      let generatorOptions: [String]
      let generateCommand: Generate
    }
    
    func validate() throws {
      let arguments = try infer()
      guard arguments.project.extension == "xcodeproj" else {
        throw ValidationError("'--project' must be a valid Xcode project")
      }
    }
    
    @discardableResult
    nonmutating func infer() throws -> Arguments {
      let validProject = try validateRequiredArgument(inferArgument(project), name: "project")
      let validGenerator = try validateRequiredArgument(inferArgument(generator), name: "generator")
      let sourceProject = sourceProject?.path ?? validProject.path
      
      let generateCommand: Generate
      do {
        // Common options that should be forwarded to the generate command.
        var forwardedOptions: [String] = []
        // Unnecessarily specifying the project path makes it brittle to refactoring.
        if sourceProject != validProject.path {
          forwardedOptions.append(contentsOf: ["--project", sourceProject.string])
        }
        generateCommand = try Generate.parse(generatorOptions + forwardedOptions)
      } catch {
        // Need to rethrow `CommandError` objects thrown when manually parsing.
        throw ValidationError(Generate.message(for: error))
      }
      
      return Arguments(
        testTarget: testTarget,
        project: validProject.path,
        sourceProject: sourceProject,
        generator: validGenerator.path,
        baseURL: baseURL.url,
        preserveExisting: preserveExisting,
        generatorOptions: generatorOptions,
        generateCommand: generateCommand)
    }
    
    mutating func run() throws {
      let start = Date()
      let parsedConfigureArguments = try infer()
      let parsedGenerateArguments = try parsedConfigureArguments.generateCommand.infer()
      
      logInfo("🛠  Project: \(parsedConfigureArguments.project.abbreviate())")
      logInfo("🎯 Test Target: \(parsedConfigureArguments.testTarget)")
      logInfo("🧰 Supporting sources: \(parsedGenerateArguments.support.abbreviate())")
      
      let downloaderConfig = Downloader.Configuration(
        assetBundleType: .starterPack,
        outputPath: parsedGenerateArguments.support.parent(),
        baseURL: parsedConfigureArguments.baseURL)
      let downloader = Downloader(config: downloaderConfig)
      try downloader.download()
      logInfo("✅ Downloaded supporting source files")
      
      // Ensure consistency between the build phase and the generator frontend while also performing
      // path transformations to make the installation relative to the project source root.
      let encoder = ArgumentsEncoder()
      encoder.sourceRoot = parsedConfigureArguments.project.parent()
      
      let installerConfig = Installer.Configuration(
        projectPath: parsedConfigureArguments.project,
        sourceProjectPath: parsedConfigureArguments.sourceProject,
        testTargetName: parsedConfigureArguments.testTarget,
        cliPath: parsedConfigureArguments.generator,
        sourceRoot: parsedGenerateArguments.srcroot,
        sourceTargetNames: parsedGenerateArguments.targets,
        outputPaths: parsedGenerateArguments.outputs,
        generatorOptions: try encoder.encode(parsedConfigureArguments.generateCommand),
        overwrite: !parsedConfigureArguments.preserveExisting)
      let installer = try Installer(config: installerConfig)
      try installer.install()
      logInfo("✅ Added build phase \(singleQuoted: Installer.Constants.buildPhaseName)")
      
      let wallTime = TimeUnit(Date().timeIntervalSince(start))
      logInfo("🎉 Successfully configured \(parsedConfigureArguments.testTarget) in \(wallTime)")
      logInfo("""
      🚀 Usage:
         1. Initialize a mock in your test with `mock(SomeType.self)`
         2. Build \(singleQuoted: parsedConfigureArguments.testTarget) (⇧⌘U) to generate mocks
         3. Write some Swifty tests!
      """)
    }
  }
}
