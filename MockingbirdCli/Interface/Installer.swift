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
    let supportPath: Path?
    let cliPath: Path
    let compilationCondition: String?
    let logLevel: LogLevel?
    let ignoreExisting: Bool
    let asynchronousGeneration: Bool
    let onlyMockProtocols: Bool
    let disableSwiftlint: Bool
    let disableCache: Bool
    let disableRelaxedLinking: Bool
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
    /// The name of the build phase for generating mocks.
    static let buildPhaseName = "Generate Mockingbird Mocks"
    /// The name of the build phase for forcing Xcode to generate mocks before each build.
    static let cleanBuildPhaseName = "Clean Mockingbird Mocks"
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
    
    // Validate source targets.
    let sourceTargets = try config.sourceTargetNames.map({ targetName throws -> PBXTarget in
      let sourceTargets = xcodeproj.pbxproj.targets(named: targetName).filter({ target in
        guard target.productType?.isTestBundle != true else {
          logWarning("Ignoring unit test source target `\(targetName)`")
          return false
        }
        return true
      })
      if sourceTargets.count > 1 {
        logWarning("Found multiple source targets named `\(targetName)`, using the first one")
      }
      guard let sourceTarget = sourceTargets.first else {
        throw Failure.malformedConfiguration(
          description: "Unable to find source target named `\(targetName)`"
        )
      }
      return sourceTarget
    })
    
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
      guard !target.buildPhases.contains(where: { $0.name() == Constants.buildPhaseName }) else {
        // Build phase is already added.
        log("Ignoring existing Mockingbird build phase in target `\(target.name)`")
        return
      }
    }
    
    // Validate that the destination target has a compile sources phase.
    guard let sourcesBuildPhase = try target.sourcesBuildPhase(),
      let buildPhaseIndex = target.buildPhases.firstIndex(of: sourcesBuildPhase) else {
        throw Failure.malformedConfiguration(
          description: "Destination target `\(targetName)` does not have a compile sources phase"
        )
    }
    
    let outputPaths = config.outputPaths ?? sourceTargets.map({
      Generator.defaultOutputPath(for: $0, sourceRoot: config.sourceRoot)
    })
    
    // Add build phase reference to project.
    let cacheBreakerPath = Path("/tmp/Mockingbird-\(UUID().uuidString)")
    let buildPhase = createGenerateMocksBuildPhase(outputPaths: outputPaths,
                                                   cacheBreakerPath: cacheBreakerPath,
                                                   config: config)
    let cleanBuildPhase = createCleanMocksBuildPhase(cacheBreakerPath: cacheBreakerPath)
    xcodeproj.pbxproj.add(object: buildPhase)
    xcodeproj.pbxproj.add(object: cleanBuildPhase)
    
    // Add build phase to target before the first compile sources phase.
    target.buildPhases.insert(buildPhase, at: buildPhaseIndex)
    target.buildPhases.insert(cleanBuildPhase, at: buildPhaseIndex)
    
    // Add the generated source target mock files to the destination target compile sources phase.
    for outputPath in outputPaths {
      guard try target.sourcesBuildPhase()?.files?.contains(where: {
        try $0.file?.fullPath(sourceRoot: config.sourceRoot) == outputPath
      }) != true else {
        // De-dup already-added sources.
        log("Destination target `\(target.name)` already references the output mock file at \(outputPath)")
        continue
      }
      
      // Add the generated source file reference to the destination target groups.
      let fileReference: PBXFileReference
      if let existingReference = sourceGroup.file(named: outputPath.lastComponent),
        (try? existingReference.fullPath(sourceRoot: config.sourceRoot)) == outputPath {
        fileReference = existingReference
        log("Using existing output mock file reference at \(outputPath)")
      } else {
        fileReference = try sourceGroup.addFile(at: outputPath,
                                                sourceRoot: config.sourceRoot,
                                                override: false,
                                                validatePresence: false)
        log("Creating new output mock file reference at \(outputPath)")
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
  
  private static func uninstall(from xcodeproj: XcodeProj,
                                target: PBXTarget,
                                sourceRoot: Path) throws {
    try uninstallGeneratePhase(from: xcodeproj, target: target, sourceRoot: sourceRoot)
    try uninstallCleanPhase(from: xcodeproj, target: target, sourceRoot: sourceRoot)
  }
  
  private static func uninstallGeneratePhase(from xcodeproj: XcodeProj,
                                             target: PBXTarget,
                                             sourceRoot: Path) throws {
    guard let buildPhase = target.buildPhases
      .first(where: { $0.name() == Constants.buildPhaseName }) as? PBXShellScriptBuildPhase
      else { return }
    
    log("Uninstalling existing 'Generate Mockingbird Mocks' build phase from target `\(target.name)`")
    
    // Remove build phase reference from project.
    xcodeproj.pbxproj.delete(object: buildPhase)
    
    // Remove from target build phases.
    target.buildPhases.removeAll(where: { $0.name() == Constants.buildPhaseName })
  }
  
  private static func uninstallCleanPhase(from xcodeproj: XcodeProj,
                                          target: PBXTarget,
                                          sourceRoot: Path) throws {
    guard let buildPhase = target.buildPhases
      .first(where: { $0.name() == Constants.cleanBuildPhaseName }) as? PBXShellScriptBuildPhase
      else { return }
    
    log("Uninstalling existing 'Clean Mockingbird Mocks' build phase from target `\(target.name)`")
    
    // Remove build phase reference from project.
    xcodeproj.pbxproj.delete(object: buildPhase)
    
    // Remove from target build phases.
    target.buildPhases.removeAll(where: { $0.name() == Constants.cleanBuildPhaseName })
  }
  
  private static func createGenerateMocksBuildPhase(outputPaths: [Path],
                                                    cacheBreakerPath: Path,
                                                    config: InstallConfiguration)
    -> PBXShellScriptBuildPhase {
      let targets = config.sourceTargetNames.map({ $0.singleQuoted }).joined(separator: " ")
      let outputs = outputPaths.map({
        $0.getRelativePath(to: config.sourceRoot, style: .bash).doubleQuoted
      }).joined(separator: " ")
      var options = [
        "--targets \(targets)",
        "--outputs \(outputs)",
      ]
      if let supportPath = config.supportPath {
        let relativeSupportPath = supportPath.getRelativePath(to: config.sourceRoot, style: .bash)
        options.append("--support \(relativeSupportPath.doubleQuoted)")
      }
      if let expression = config.compilationCondition {
        options.append("--condition '\(expression)'")
      }
      if config.onlyMockProtocols {
        options.append("--only-protocols")
      }
      if config.disableSwiftlint {
        options.append("--disable-swiftlint")
      }
      if config.disableCache {
        options.append("--disable-cache")
      }
      if config.disableRelaxedLinking {
        options.append("--disable-relaxed-linking")
      }
      if let logLevel = config.logLevel {
        switch logLevel {
        case .quiet: options.append("--quiet")
        case .normal: break
        case .verbose: options.append("--verbose")
        }
      }
      if config.asynchronousGeneration {
        options.append("&")
      }
      let cliPath = config.cliPath.getRelativePath(to: config.sourceRoot,
                                                   style: .bash,
                                                   shouldNormalize: false)
      let shellScript = """
      \(cliPath) generate \\
        \(options.joined(separator: " \\\n  "))
      
      # Ensure mocks are generated prior to running Compile Sources
      rm -f '\(cacheBreakerPath.absolute())'
      
      """
      return PBXShellScriptBuildPhase(name: Constants.buildPhaseName,
                                      inputPaths: ["\(cacheBreakerPath.absolute())"],
                                      outputPaths: outputPaths.map({
                                        $0.getRelativePath(to: config.sourceRoot, style: .make)
                                      }),
                                      shellScript: shellScript)
  }
  
  /// Xcode constructs a dependency graph from the input and output file lists of build phases and
  /// uses that to parallelize operations. The Generate Mocks phase lists each generated mock as an
  /// output file in order to ensure that it runs prior to the Compile Source phase.
  ///
  /// However, Xcode also caches Run Script phase results based on the presence and modification of
  /// input and output files. In order to not specify all input source files at installation time
  /// (which would be brittle), it's necessary to use a secondary build phase as a trigger for the
  /// primary Generate Mocks phase.
  private static func createCleanMocksBuildPhase(cacheBreakerPath: Path)
    -> PBXShellScriptBuildPhase {
      let shellScript = "echo $RANDOM > '\(cacheBreakerPath.absolute())'\n"
      return PBXShellScriptBuildPhase(name: Constants.cleanBuildPhaseName,
                                      outputPaths: ["\(cacheBreakerPath.absolute())"],
                                      shellScript: shellScript)
  }
}

extension Path {
  func getRelativePath(to sourceRoot: Path,
                       style: SubstitutionStyle,
                       shouldNormalize: Bool = true) -> String {
    let sourceRootPath = "\(sourceRoot.absolute())"
    let absolutePath = shouldNormalize ? "\(absolute())" : "\(self)"
    guard absolutePath.hasPrefix(sourceRootPath) else { return absolutePath }
    return style.wrap("SRCROOT") + absolutePath.dropFirst(sourceRootPath.count)
  }
}
