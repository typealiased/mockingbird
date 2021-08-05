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
    let header: [String]?
    let compilationCondition: String?
    let diagnostics: [DiagnosticType]?
    let logLevel: LogLevel?
    let pruningMethod: PruningMethod?
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
  
  
  // MARK: - Install
  
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
      logWarning("Found multiple targets named \(targetName.singleQuoted), using the first one")
    }
    guard let target = destinationTargets.first else {
      throw Failure.malformedConfiguration(
        description: "Unable to find a target named \(targetName.singleQuoted)"
      )
    }
    if target.productType?.isTestBundle != true {
      logWarning("Installing to target `\(targetName)` which is not a test target")
    }
    
    // Validate source targets.
    let sourceTargets = try getSourceTargets(for: config, xcodeproj: xcodeproj)
    
    // Create a "Generated Mocks" source group to store all mocks under.
    let sourceGroup: PBXGroup
    if let existingSourceGroup = rootGroup.group(named: Constants.sourceGroupName) {
      sourceGroup = existingSourceGroup
    } else {
      guard let addedGroup = try xcodeproj.pbxproj
        .rootGroup()?
        .addGroup(named: Constants.sourceGroupName, options: [.withoutFolder]).first else {
          throw Failure.malformedConfiguration(
            description: "Unable to create top-level 'Generated Mocks' Xcode project file group"
          )
      }
      sourceGroup = addedGroup
    }
    
    // Check if there's an existing installation that should be overridden or if we should abort.
    if !config.ignoreExisting { // Cleanup past installations.
      try uninstall(from: xcodeproj, target: target, sourceRoot: config.sourceRoot)
    } else {
      guard !target.buildPhases.contains(where: { $0.name() == Constants.buildPhaseName }) else {
        // Build phase is already added.
        log("Ignoring existing Mockingbird build phase in target \(target.name.singleQuoted)")
        return
      }
    }
    
    // Validate that the destination target has a compile sources phase.
    guard let sourcesBuildPhase = try target.sourcesBuildPhase(),
      let buildPhaseIndex = target.buildPhases.firstIndex(of: sourcesBuildPhase) else {
        throw Failure.malformedConfiguration(
          description: "Target \(targetName.singleQuoted) does not have a compile sources phase"
        )
    }
    
    // Create fixed output paths for each source target.
    let getBuildEnvironment = { return xcodeproj.implicitBuildEnvironment }
    let outputPaths = config.outputPaths ?? sourceTargets.map({
      Generator.defaultOutputPath(for: .pbxTarget($0),
                                  testTarget: .pbxTarget(target),
                                  sourceRoot: config.sourceRoot,
                                  environment: getBuildEnvironment)
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
      try addSourceFilePath(outputPath,
                            target: target,
                            sourceGroup: sourceGroup,
                            xcodeproj: xcodeproj,
                            config: config)
    }
    
    try xcodeproj.writePBXProj(path: config.projectPath, outputSettings: PBXOutputSettings())
  }
  
  private static func getSourceTargets(for config: InstallConfiguration,
                                       xcodeproj: XcodeProj) throws -> [PBXTarget] {
    return try config.sourceTargetNames.map({ targetName throws -> PBXTarget in
      let sourceTargets = xcodeproj.pbxproj.targets(named: targetName).filter({ target in
        guard target.productType?.isTestBundle != true else {
          logWarning("Ignoring source target \(targetName.singleQuoted) because it is a test target")
          return false
        }
        return true
      })
      if sourceTargets.count > 1 {
        logWarning("Found multiple source targets named \(targetName.singleQuoted), using the first one")
      }
      guard let sourceTarget = sourceTargets.first else {
        throw Failure.malformedConfiguration(
          description: "Unable to find source target named \(targetName.singleQuoted)"
        )
      }
      return sourceTarget
    })
  }
  
  private static func addSourceFilePath(_ outputPath: Path,
                                        target: PBXTarget,
                                        sourceGroup: PBXGroup,
                                        xcodeproj: XcodeProj,
                                        config: InstallConfiguration) throws {
    guard try target.sourcesBuildPhase()?.files?.contains(where: {
      try $0.file?.fullPath(sourceRoot: config.sourceRoot) == outputPath
    }) != true else {
      // De-dup already-added sources.
      log("Target \(target.name.singleQuoted) already references the output mock file at \(outputPath)")
      return
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
  
  
  // MARK: - Uninstall
  
  static func uninstall(using config: UninstallConfiguration) throws {
    let xcodeproj = try XcodeProj(path: config.projectPath)
    try config.targetNames.forEach({ targetName throws in
      guard let target = xcodeproj.pbxproj.targets(named: targetName).first else {
        throw Failure.malformedConfiguration(
          description: "Unable to find target named \(targetName.singleQuoted)"
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
      .first(where: {
        $0 is PBXShellScriptBuildPhase && $0.name() == Constants.buildPhaseName
      }) as? PBXShellScriptBuildPhase
      else { return }
    
    log("Uninstalling existing 'Generate Mockingbird Mocks' build phase from target \(target.name.singleQuoted)")
    
    // Remove build phase reference from project.
    xcodeproj.pbxproj.delete(object: buildPhase)
    
    // Remove all associated generated output files.
    let outputFilesPaths = Set(buildPhase.outputPaths.map({
      $0.replacingOccurrences(of: "$(SRCROOT)", with: "\(sourceRoot.absolute())")
    }))
    try target.sourcesBuildPhase()?.files?.removeAll(where: {
      guard let fullPath = try $0.file?.fullPath(sourceRoot: sourceRoot) else { return false }
      return outputFilesPaths.contains("\(fullPath)")
    })
    
    // Remove from target build phases.
    target.buildPhases.removeAll(where: { $0 === buildPhase })
  }
  
  private static func uninstallCleanPhase(from xcodeproj: XcodeProj,
                                          target: PBXTarget,
                                          sourceRoot: Path) throws {
    guard let buildPhase = target.buildPhases
      .first(where: {
        $0 is PBXShellScriptBuildPhase && $0.name() == Constants.cleanBuildPhaseName
      }) as? PBXShellScriptBuildPhase
      else { return }
    
    log("Uninstalling existing 'Clean Mockingbird Mocks' build phase from target \(target.name.singleQuoted)")
    
    // Remove build phase reference from project.
    xcodeproj.pbxproj.delete(object: buildPhase)
    
    // Remove from target build phases.
    target.buildPhases.removeAll(where: { $0 === buildPhase })
  }
  
  
  // MARK: - Create build phases
  
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
        options.append("--condition \(expression.singleQuoted)")
      }
      if let header = config.header {
        options.append("--header \(header.map({ "'\($0)'" }).joined(separator: " "))")
      }
      if let diagnostics = config.diagnostics {
        let allDiagnostics = Set(diagnostics)
          .map({ $0.rawValue.singleQuoted })
          .sorted()
          .joined(separator: " ")
        options.append("--diagnostics \(allDiagnostics)")
      }
      if let method = config.pruningMethod {
        options.append("--prune \(method.rawValue.singleQuoted)")
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
      set -eu
      
      # Ensure mocks are generated prior to running Compile Sources
      rm -f '\(cacheBreakerPath.absolute())'
      
      \(cliPath) generate \\
        \(options.joined(separator: " \\\n  "))
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
    let absolutePath = shouldNormalize ? "\(absolute())" : "\(abbreviate())"
    guard absolutePath.hasPrefix(sourceRootPath) else { return absolutePath }
    return style.wrap("SRCROOT") + absolutePath.dropFirst(sourceRootPath.count)
  }
}
