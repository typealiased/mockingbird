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

// TODO: Move
extension PruningMethod: ExpressibleByArgument {}
extension DiagnosticType: ExpressibleByArgument {}

extension Mockingbird {
  struct Configure: ParsableCommand {
    @Argument(help: "The name of a test target to configure.")
    var testTarget: String
    
    @Option(help: "Path to a Xcode project or a JSON project description.")
    var project: XcodeProjPath?
    
    @Option(help: "Path to the Mockingbird generator executable.")
    var generator: BinaryPath?
    
    @Option(help: "The base URL hosting downloadable asset bundles.")
    var assets: String?
    
    @Argument(help: "Additional options to use when running the generator.")
    var generatorOptions: [String] = []
    
    var generateCommand: Generate!
    
    mutating func validate() throws {
      try validateRequiredArgument(inferArgument(&project), name: "project")
      try validateRequiredArgument(inferArgument(&generator), name: "generator")
      
      assets = assets ?? "https://github.com/birdrides/mockingbird/releases/download"
      
      do {
        // Some options should be forwarded to the generate command.
        generatorOptions.append(contentsOf: ["--project", project!.path.string])
        generateCommand = try Generate.parse(generatorOptions)
      } catch {
        // Need to rethrow `CommandError` objects thrown when manually parsing.
        throw ValidationError(Generate.message(for: error))
      }
    }
    
    mutating func run() throws {
      print("🛠  Project: \(project!.path.abbreviate())")
      print("🎯 Test Target: \(testTarget)")
      
      let start = Date()
      
      let supportingSourcesPath = generateCommand.support?.path ??
        SupportingSourcesPath.genDefaultPath(workingPath: ArgumentContext.shared.workingPath)
      print("🧰 Supporting sources: \(supportingSourcesPath.abbreviate())")
      
      let downloaderConfig = Downloader.Configuration(
        assetBundleType: .starterPack,
        outputPath: generateCommand.srcroot!.path,
        baseURL: assets!)
      let downloader = Downloader(config: downloaderConfig)
      try downloader.download()
      print("🚀 Downloaded supporting source files")
      
      let installerConfig = Installer.Configuration(
        projectPath: project!.path,
        testTargetName: testTarget,
        cliPath: generator!.path,
        sourceRoot: generateCommand.srcroot!.path,
        sourceTargetNames: generateCommand.targets,
        outputPaths: generateCommand.outputs,
        generatorOptions: generatorOptions,
        overwrite: true)
      let installer = try Installer(config: installerConfig)
      try installer.install()
      print("🚀 Added build phase \(singleQuoted: Installer.Constants.buildPhaseName)")
      
      let wallTime = TimeUnit(Date().timeIntervalSince(start))
      print("✅ Successfully configured MyTestTarget in \(wallTime)")
    }
  }
}
