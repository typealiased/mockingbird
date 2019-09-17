//
//  Installer.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation
import MockingbirdGenerator
import PathKit
import XcodeProj

class Installer {
  struct InstallConfiguration {
    let projectPath: Path
    let sourceRoot: Path
    let sourceTargetNames: [String]
    let destinationTargetName: String
    let outputPaths: [Path]?
    let cliPath: Path
    let ignoreExisting: Bool
    let asynchronousGeneration: Bool
    let preprocessorExpression: String?
    let onlyMockProtocols: Bool
    let disableSwiftlint: Bool
  }
  
  struct UninstallConfiguration {
    let projectPath: Path
    let sourceRoot: Path
    let targetNames: [String]
  }
  
  enum Failure: LocalizedError {
    case malformedConfiguration(description: String)
    case invalidXcodeProjectConfiguration(description: String)
    
    var errorDescription: String? {
      switch self {
      case .malformedConfiguration(let description):
        return "Malformed configuration - \(description)"
      case .invalidXcodeProjectConfiguration(let description):
        return "Invalid Xcode project configuration - \(description)"
      }
    }
  }
  
  private enum Constants {
    /// The name of the build phase is also used for uninstalling previous phases the CLI installed.
    static let buildPhaseName = "Generate Mockingbird Mocks"
    /// The name of the Xcode project file group containing all generated mock file references.
    static let sourceGroupName = "Generated Mocks"
  }
  
  static func install(using config: InstallConfiguration) throws {
    guard config.outputPaths == nil || config.sourceTargetNames.count == config.outputPaths?.count else {
      throw Failure.malformedConfiguration(description: "Number source targets does not match the number of output file paths")
    }
    
    let xcodeproj = try XcodeProj(path: config.projectPath)
    
    guard let rootGroup = try? xcodeproj.pbxproj.rootGroup() else {
      throw Failure.invalidXcodeProjectConfiguration(
        description: "Xcode project does not have a root file group"
      )
    }
    
    // Validate destination target.
    let targetName = config.destinationTargetName
    let destinationTargets = xcodeproj.pbxproj.targets(named: targetName)
    if destinationTargets.count > 1 {
      logWarning("Found multiple destination targets named `\(targetName)`, using the first one")
    }
    guard let target = destinationTargets.first else {
      throw Failure.malformedConfiguration(
        description: "Unable to find destination target named `\(targetName)`"
      )
    }
    
    let sourceGroup: PBXGroup
    if let existingSourceGroup = rootGroup.group(named: Constants.sourceGroupName) {
      sourceGroup = existingSourceGroup
    } else {
      guard let addedGroup = try xcodeproj.pbxproj
        .rootGroup()?
        .addGroup(named: Constants.sourceGroupName, options: [.withoutFolder]).first else {
          throw Failure.malformedConfiguration(
            description: "Unable to create top-level `Generated Mocks` Xcode project file group"
          )
      }
      sourceGroup = addedGroup
    }
    
    if !config.ignoreExisting { // Cleanup past installations.
      try uninstall(from: xcodeproj, target: target, sourceRoot: config.sourceRoot)
    } else {
      guard !target.buildPhases.contains(where: { $0.name() == Constants.buildPhaseName })
        else { return } // Build phase is already added.
    }
    
    // Validate that the destination target has a compile sources phase.
    guard let sourcesBuildPhase = try target.sourcesBuildPhase(),
      let buildPhaseIndex = target.buildPhases.firstIndex(of: sourcesBuildPhase) else {
        throw Failure.malformedConfiguration(
          description: "Destination target `\(targetName)` does not have a compile sources phase"
        )
    }
    
    // Add build phase reference to project.
    let outputPaths = config.outputPaths ?? config.sourceTargetNames.map({
      config.sourceRoot.mocksDirectory + Path("\($0)\(Generator.Constants.generatedFileNameSuffix)")
    })
    let buildPhase = createGenerateMocksBuildPhase(outputPaths: outputPaths, config: config)
    xcodeproj.pbxproj.add(object: buildPhase)
    
    // Add build phase to target before the first compile sources phase.
    target.buildPhases.insert(buildPhase, at: buildPhaseIndex)
    
    // Add the generated source target mock files to the destination target compile sources phase.
    for outputPath in outputPaths {
      guard try target.sourcesBuildPhase()?.files?.contains(where: {
        try $0.file?.fullPath(sourceRoot: config.sourceRoot) == outputPath
      }) == false else { break } // De-dup already-added sources.
      
      // Add the generated source file reference to the destination target groups.
      let fileReference: PBXFileReference
      if let existingReference = sourceGroup.file(named: outputPath.lastComponent) {
        fileReference = existingReference
      } else {
        fileReference = try sourceGroup.addFile(at: outputPath,
                                                sourceRoot: config.sourceRoot,
                                                override: false,
                                                validatePresence: false)
      }
      
      // Add the generated source file reference to the Xcode project.
      xcodeproj.pbxproj.add(object: fileReference)
      
      _ = try target.sourcesBuildPhase()?.add(file: fileReference)
    }
    
    try xcodeproj.writePBXProj(path: config.projectPath, outputSettings: PBXOutputSettings())
  }
  
  static func uninstall(using config: UninstallConfiguration) throws {
    let xcodeproj = try XcodeProj(path: config.projectPath)
    try config.targetNames.forEach({ targetName throws in
      guard let target = xcodeproj.pbxproj.targets(named: targetName).first else {
        throw Failure.malformedConfiguration(
          description: "Unable to find target named `\(targetName)`"
        )
      }
      try uninstall(from: xcodeproj, target: target, sourceRoot: config.sourceRoot)
    })
    
    try xcodeproj.writePBXProj(path: config.projectPath, outputSettings: PBXOutputSettings())
  }
  
  private static func uninstall(from xcodeproj: XcodeProj, target: PBXTarget, sourceRoot: Path) throws {
    guard let buildPhase = target.buildPhases
      .first(where: { $0.name() == Constants.buildPhaseName }) as? PBXShellScriptBuildPhase
      else { return }
    
    // Remove build phase reference from project.
    xcodeproj.pbxproj.delete(object: buildPhase)
    
    // Remove from target build phases.
    target.buildPhases.removeAll(where: { $0.name() == Constants.buildPhaseName })
    
    // Remove generated mocks file reference from project.
    try buildPhase.outputPaths.forEach({ rawOutputPath in
      guard let fileReference = xcodeproj.pbxproj.fileReferences
        .first(where: { reference -> Bool in
          guard let path = reference.path, reference.sourceTree == .group else { return false }
          return sourceRoot + Path(path) == Path(rawOutputPath)
        }) else { return }
      xcodeproj.pbxproj.delete(object: fileReference)
      
      // And delete any existing generated mocks file.
      let outputPath = Path(rawOutputPath)
      guard outputPath.exists && outputPath.isDeletable else { return }
      try outputPath.delete()
    })
  }
  
  private static func createGenerateMocksBuildPhase(outputPaths: [Path],
                                                    config: InstallConfiguration)
    -> PBXShellScriptBuildPhase {
      let targets = config.sourceTargetNames.map({ "'\($0)'" }).joined(separator: " ")
      let outputs = outputPaths.map({ "'\($0.absolute())'" }).joined(separator: " ")
      var options = [
        "--targets \(targets)",
        "--outputs \(outputs)"
      ]
      if let expression = config.preprocessorExpression {
        options.append("--preprocessor '\(expression)'")
      }
      if config.onlyMockProtocols {
        options.append("--only-protocols")
      }
      if config.disableSwiftlint {
        options.append("--disable-swiftlint")
      }
      if config.asynchronousGeneration {
        options.append("&")
      }
      let shellScript = """
      \(config.cliPath) generate \\
        \(options.joined(separator: " \\\n  "))
      
      """
      // Specifying an output path without input paths causes Xcode to incorrectly cache mock files.
      return PBXShellScriptBuildPhase(name: Constants.buildPhaseName, shellScript: shellScript)
  }
}
