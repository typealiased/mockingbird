//
//  Installer.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdGenerator
import PathKit
import XcodeProj

struct Installer {
  struct Configuration {
    let projectPath: Path
    let testTargetName: String
    let cliPath: Path
    let sourceRoot: Path
    let sourceTargetNames: [String]
    let outputPaths: [Path]
    let generatorOptions: [String]
    let overwrite: Bool
  }
  
  enum Failure: LocalizedError {
    case validationError(_ message: String)
    case invalidProjectConfiguration(_ message: String)
    case invalidTargetConfiguration(_ message: String)
    case unableToModifyProject(_ message: String)
    
    var errorDescription: String? {
      switch self {
      case .validationError(let message),
           .invalidProjectConfiguration(let message),
           .invalidTargetConfiguration(let message),
           .unableToModifyProject(let message):
        return message
      }
    }
  }
  
  enum Constants {
    /// Name of the primary build phase for generating mocks.
    static let buildPhaseName = "Generate Mockingbird Mocks"
    /// Name of the legacy build phase for working around Xcode build caching.
    static let cleanMocksBuildPhaseName = "Clean Mockingbird Mocks"
    /// Name of the Xcode project group containing generated files.
    static let sourceGroupName = "Generated Mocks"
  }
  
  let config: Configuration
  
  init(config: Configuration) throws {
    self.config = config
  }
  
  // MARK: - Install
  
  func install() throws {
    let xcodeproj = try XcodeProj(path: config.projectPath)
    
    guard let rootGroup = try xcodeproj.pbxproj.rootGroup() else {
      throw Failure.invalidProjectConfiguration("Xcode project has no root group")
    }
    
    let testTarget = try findTarget(name: config.testTargetName,
                                    project: xcodeproj,
                                    testTarget: true)
    let sourceTargets = try config.sourceTargetNames.map({ targetName in
      try findTarget(name: targetName, project: xcodeproj, testTarget: false)
    })
    
    if config.overwrite {
      try uninstall(from: xcodeproj, target: testTarget, rootGroup: rootGroup)
    } else if testTarget.buildPhases.contains(where: { buildPhase in
      buildPhase.name() == Constants.buildPhaseName
    }) {
      throw Failure.invalidTargetConfiguration(
        "Target \(singleQuoted: config.testTargetName) is already configured")
    }
    
    let sourceGroup = try createSourceGroup(name: Constants.sourceGroupName, rootGroup: rootGroup)
    
    guard let sourcesBuildPhase = try testTarget.sourcesBuildPhase(),
          let buildPhaseIndex = testTarget.buildPhases.firstIndex(of: sourcesBuildPhase) else {
      throw Failure.invalidTargetConfiguration(
        "Target \(singleQuoted: config.testTargetName) has no Compile Sources build phase")
    }
    
    // TODO: Migrate to a single output file with generator v2.
    let outputPaths = !config.outputPaths.isEmpty ? config.outputPaths :
      sourceTargets.map({ sourceTarget in
        Generator.defaultOutputPath(for: .pbxTarget(sourceTarget),
                                    testTarget: .pbxTarget(testTarget),
                                    sourceRoot: config.sourceRoot,
                                    environment: { xcodeproj.implicitBuildEnvironment })
      })
    guard outputPaths.count == sourceTargets.count else {
      throw Failure.validationError(
        "The number of output paths does not equal the number of targets")
    }
    
    // Add build phase to target and project.
    let buildPhase = createBuildPhase(outputPaths: outputPaths)
    testTarget.buildPhases.insert(buildPhase, at: buildPhaseIndex)
    xcodeproj.pbxproj.add(object: buildPhase)
    
    // Track the generated mock files.
    for outputPath in outputPaths {
      try addSourceFilePath(outputPath,
                            target: testTarget,
                            sourceGroup: sourceGroup,
                            xcodeproj: xcodeproj)
    }
    
    try xcodeproj.writePBXProj(path: config.projectPath, outputSettings: PBXOutputSettings())
  }
  
  private func findTarget(name: String,
                          project: XcodeProj,
                          testTarget: Bool) throws -> PBXTarget {
    let targets = project.pbxproj.targets(named: name)
    if targets.count > 1 {
      logWarning("Found multiple targets named \(singleQuoted: config.testTargetName)")
    }
    
    let validTargets = {
      project.pbxproj.nativeTargets.compactMap({ target -> String? in
        guard let productType = target.productType,
              testTarget ? productType.isSwiftUnitTestBundle : !productType.isTestBundle
        else { return nil }
        return target.name
      })
    }
    
    guard let target = targets.first else {
      throw Failure.validationError("Cannot find \(singleQuoted: name) in Xcode project. " +
                                      "Valid targets: \(separated: validTargets())")
    }
    
    guard let productType = target.productType else {
      throw Failure.invalidTargetConfiguration(
        "Target \(singleQuoted: name) has an unknown product type. " +
          "Valid targets: \(separated: validTargets())")
    }
    
    if testTarget && !productType.isSwiftUnitTestBundle {
      throw Failure.validationError("Target \(singleQuoted: name) is not a unit test bundle. " +
                                      "Valid targets: \(separated: validTargets())")
    }
    
    if !testTarget && productType.isTestBundle {
      throw Failure.validationError("Target \(singleQuoted: name) cannot be a test bundle. " +
                                      "Valid targets: \(separated: validTargets())")
    }
    
    return target
  }
  
  private func createSourceGroup(name: String, rootGroup: PBXGroup) throws -> PBXGroup {
    if let previousGroup = rootGroup.group(named: name) {
      return previousGroup
    }
    
    if let newGroup = try rootGroup.addGroup(named: Constants.sourceGroupName,
                                             options: [.withoutFolder]).first {
      return newGroup
    }
    
    throw Failure.unableToModifyProject(
      "Cannot create \(singleQuoted: Constants.sourceGroupName) Xcode project group")
  }
  
  private func addSourceFilePath(_ outputPath: Path,
                                 target: PBXTarget,
                                 sourceGroup: PBXGroup,
                                 xcodeproj: XcodeProj) throws {
    guard try target.sourcesBuildPhase()?.files?.contains(where: { buildFile in
      try buildFile.file?.fullPath(sourceRoot: config.sourceRoot) == outputPath
    }) != true else {
      log("Target \(singleQuoted: target.name) already compiles \(outputPath.absolute())")
      return
    }
    
    let fileReference = try sourceGroup.addFile(at: outputPath,
                                                sourceRoot: config.sourceRoot,
                                                override: true,
                                                validatePresence: false)
    _ = try target.sourcesBuildPhase()?.add(file: fileReference)
    xcodeproj.pbxproj.add(object: fileReference)
  }
  
  private func createBuildPhase(outputPaths: [Path]) -> PBXShellScriptBuildPhase {
    let cliPath = config.cliPath.getRelativePath(to: config.sourceRoot,
                                                 style: .bash,
                                                 shouldNormalize: false)
    var options = config.generatorOptions
    // TODO: Remove this for generator v2. Only needed for backwards compatibility.
    if config.outputPaths.isEmpty {
      options += ["--outputs"] + outputPaths.map({ path in
        path.getRelativePath(to: config.sourceRoot, style: .bash).doubleQuoted
      })
    }
    return PBXShellScriptBuildPhase(
      name: Constants.buildPhaseName,
      outputPaths: outputPaths.map({ path in
        path.getRelativePath(to: config.sourceRoot, style: .make)
      }),
      shellScript: """
      \(cliPath) generate \(options.joined(separator: " "))
      """,
      alwaysOutOfDate: true)
  }
  
  // MARK: - Uninstall
  
  private func uninstall(from xcodeproj: XcodeProj, target: PBXTarget, rootGroup: PBXGroup) throws {
    let sourceGroup = rootGroup.group(named: Constants.sourceGroupName)
    
    for buildPhase in target.buildPhases {
      guard let shellScriptBuildPhase = buildPhase as? PBXShellScriptBuildPhase else {
        continue
      }
      
      guard let name = buildPhase.name(),
            name == Constants.buildPhaseName ||
            name == Constants.cleanMocksBuildPhaseName else {
        continue
      }
      
      log("Removing \(singleQuoted: name) build phase from \(singleQuoted: target.name)")
      
      // Build phase must be removed from both the target and the project.
      xcodeproj.pbxproj.delete(object: buildPhase)
      target.buildPhases.removeAll(where: { $0 === buildPhase })
      
      // Remove generated output files from the Compile Sources build phase and the project.
      let generatedFilePaths = Set(shellScriptBuildPhase.outputPaths.map({ path in
        path.replacingOccurrences(of: SubstitutionStyle.make.wrap("SRCROOT"),
                                  with: config.sourceRoot.absolute().string)
      }))
      
      try target.sourcesBuildPhase()?.files?.removeAll(where: { buildFile in
        guard let fullPath = try buildFile.file?.fullPath(sourceRoot: config.sourceRoot) else {
          return false
        }
        return generatedFilePaths.contains(fullPath.string)
      })
      
      try sourceGroup?.children.removeAll(where: { child in
        guard let fullPath = try child.fullPath(sourceRoot: config.sourceRoot) else {
          return false
        }
        return generatedFilePaths.contains(fullPath.string)
      })
    }
  }
}

extension Path {
  func getRelativePath(to sourceRoot: Path,
                       style: SubstitutionStyle,
                       shouldNormalize: Bool = true) -> String {
    let sourceRootPath = sourceRoot.absolute().string
    let absolutePath = (shouldNormalize ? absolute() : abbreviate()).string
    guard absolutePath.hasPrefix(sourceRootPath) else {
      return absolutePath
    }
    return style.wrap("SRCROOT") + absolutePath.dropFirst(sourceRootPath.count)
  }
}
