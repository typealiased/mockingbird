//
//  Installer.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation
import XcodeProj
import PathKit

class Installer {
  struct InstallConfiguration {
    let projectPath: Path
    let sourceRoot: Path
    let targetNames: [String]
    let outputPaths: [Path]?
    let cliPath: Path
    let shouldReinstall: Bool
    let synchronousGeneration: Bool
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
    
    var errorDescription: String? {
      switch self {
      case .malformedConfiguration(let description):
        return "Malformed configuration - \(description)"
      }
    }
  }
  
  private enum Constants {
    /// The name of the build phase is also used for uninstalling previous phases the CLI installed.
    static let buildPhaseName = "Generate Mockingbird Mocks"
  }
  
  static func install(using config: InstallConfiguration) throws {
    guard config.outputPaths == nil || config.targetNames.count == config.outputPaths?.count else {
      throw Failure.malformedConfiguration(description: "Number of installation targets does not match the number of output file paths")
    }
    
    let xcodeproj = try XcodeProj(path: config.projectPath)
    var index = 0
    try config.targetNames.forEach({ targetName throws in
      guard let target = xcodeproj.pbxproj.targets(named: targetName).first else {
        throw Failure.malformedConfiguration(
          description: "Unable to find target named `\(targetName)`"
        )
      }
      
      // Cleanup past installations.
      if config.shouldReinstall {
        try uninstall(from: xcodeproj, target: target, sourceRoot: config.sourceRoot)
      }
      
      guard !target.buildPhases.contains(where: { $0.name() == Constants.buildPhaseName })
        else { return } // Build phase is already added.
      
      // Add build phase reference to project.
      let defaultOutputPath = config.sourceRoot.mocksDirectory
        + Path("\(targetName)\(Generator.Constants.generatedFileNameSuffix)")
      let outputPath = config.outputPaths?[index] ?? defaultOutputPath
      let buildPhase = createGenerateMocksBuildPhase(outputPath: outputPath, config: config)
      xcodeproj.pbxproj.add(object: buildPhase)
      
      // Add build phase to target before the first compile sources phase.
      if let sourcesBuildPhase = try target.sourcesBuildPhase(),
        let buildPhaseIndex = target.buildPhases.firstIndex(of: sourcesBuildPhase) {
        target.buildPhases.insert(buildPhase, at: buildPhaseIndex)
      } else {
        target.buildPhases.append(buildPhase)
      }
      
      // Add generated mocks file reference to project if synchronous.
      if config.synchronousGeneration {
        let fileReference = PBXFileReference(sourceTree: .group,
                                             path: String(describing: outputPath.absolute()))
        xcodeproj.pbxproj.add(object: fileReference)
        _ = try target.sourcesBuildPhase()?.add(file: fileReference)
      }
      
      index += 1
    })
    
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
  
  private static func createGenerateMocksBuildPhase(outputPath: Path, config: InstallConfiguration)
    -> PBXShellScriptBuildPhase {
      var options = [
        "--project '\(config.projectPath.absolute())'",
        "--output '\(outputPath.absolute())'"
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
      if !config.synchronousGeneration {
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
