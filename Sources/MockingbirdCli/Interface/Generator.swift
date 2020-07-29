//
//  Generator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility
import XcodeProj
import os.log

class Generator {
  struct Configuration: Encodable {
    let projectPath: Path
    let sourceRoot: Path
    let inputTargetNames: [String]
    let environmentProjectFilePath: Path?
    let environmentSourceRoot: Path?
    let environmentTargetName: String?
    let outputPaths: [Path]?
    let supportPath: Path?
    let compilationCondition: String?
    let shouldImportModule: Bool
    let onlyMockProtocols: Bool
    let disableSwiftlint: Bool
    let disableCache: Bool
    let disableRelaxedLinking: Bool
    let disableThunkStubs: Bool
  }
  
  struct MalformedConfiguration: Error, CustomStringConvertible {
    let description: String
  }
  
  enum Constants {
    static let generatedFileNameSuffix = "Mocks.generated.swift"
    static let cacheSubdirectory = "MockingbirdCache"
  }
  
  let config: Configuration
  let configHash: String
  let cliVersion = "\(mockingbirdVersion)"
  
  let sourceTargetCacheDirectory: Path
  let testTargetCacheDirectory: Path?
  
  init(_ config: Configuration) throws {
    self.config = config
    self.configHash = try config.toSha1Hash()
    
    // Set up directories for target metadata caching.
    self.sourceTargetCacheDirectory = config.projectPath + Constants.cacheSubdirectory
    if let environmentProjectFilePath = config.environmentProjectFilePath {
      let cacheDirectory = environmentProjectFilePath + Constants.cacheSubdirectory
      self.testTargetCacheDirectory = cacheDirectory
    } else {
      self.testTargetCacheDirectory = nil
    }
  }
  
  var parsedProjects = [Path: XcodeProj]()
  func getXcodeProj(_ projectPath: Path) throws -> XcodeProj {
    if let xcodeproj = parsedProjects[projectPath] { return xcodeproj }
    var xcodeproj: XcodeProj!
    try time(.parseXcodeProject) {
      xcodeproj = try XcodeProj(path: projectPath)
    }
    parsedProjects[projectPath] = xcodeproj
    return xcodeproj
  }
  
  // Parsing Xcode projects can be slow, so lazily get implicit build environments.
  func getBuildEnvironment() -> [String: Any] {
    let xcodeproj = try? getXcodeProj(config.projectPath)
    return xcodeproj?.implicitBuildEnvironment ?? [:]
  }
  
  var projectHash: String?
  func getProjectHash(_ projectPath: Path) -> String? {
    if let projectHash = projectHash { return projectHash }
    let pbxprojPath = projectPath.glob("*.pbxproj").first
    let projectHash = try? pbxprojPath?.read().generateSha1Hash()
    self.projectHash = projectHash
    return projectHash
  }
  
  // Get cached source target metadata.
  func getCachedSourceTarget(targetName: String) -> TargetType? {
    guard !config.disableCache,
      let projectHash = getProjectHash(config.projectPath),
      let cachedTarget = findCachedSourceTarget(for: targetName,
                                                cliVersion: cliVersion,
                                                projectHash: projectHash,
                                                configHash: configHash,
                                                cacheDirectory: sourceTargetCacheDirectory,
                                                sourceRoot: config.sourceRoot)
      else { return nil }
    return .sourceTarget(cachedTarget)
  }
  
  // Get cached test target metadata.
  func getCachedTestTarget(targetName: String) -> TargetType? {
    guard !config.disableThunkStubs,
      let cacheDirectory = testTargetCacheDirectory,
      let projectHash = getProjectHash(config.projectPath),
      let cachedTarget = findCachedTestTarget(for: targetName,
                                              projectHash: projectHash,
                                              cliVersion: cliVersion,
                                              configHash: configHash,
                                              cacheDirectory: cacheDirectory,
                                              sourceRoot: config.sourceRoot)
      else { return nil }
    return .testTarget(cachedTarget)
  }
  
  func generate() throws {
    guard config.outputPaths == nil || config.inputTargetNames.count == config.outputPaths?.count else {
      throw MalformedConfiguration(
        description: "Number of input targets does not match the number of output file paths"
      )
    }
    
    if config.supportPath == nil {
      logWarning("No supporting source files specified which can result in missing mocks")
    }
    
    // Resolve target names to concrete Xcode project targets.
    let isSourceTarget: (PBXTarget) -> Bool = { target in
      guard target.productType?.isTestBundle != true else {
        logWarning("Excluding \(target.name.singleQuoted) from mock generation because it is a test bundle target")
        return false
      }
      return true
    }
    let targets = try config.inputTargetNames.compactMap({ targetName throws -> TargetType? in
      return try Generator.resolveTarget(targetName: targetName,
                                         projectPath: config.projectPath,
                                         isValidTarget: isSourceTarget,
                                         getCachedTarget: getCachedSourceTarget,
                                         getXcodeProj: getXcodeProj)
    })
    
    // Resolve unspecified output paths to the default mock file output destination.
    let outputPaths = try config.outputPaths ?? targets.map({ target throws -> Path in
      try config.sourceRoot.mocksDirectory.mkpath()
      return Generator.defaultOutputPath(for: target,
                                         sourceRoot: config.sourceRoot,
                                         environment: getBuildEnvironment)
    })
    
    let queue = OperationQueue.createForActiveProcessors()
    
    // Create operations to find used mock types in tests.
    let pruningPipeline = config.disableThunkStubs ? nil :
      PruningPipeline(config: config,
                      getCachedTarget: getCachedTestTarget,
                      getXcodeProj: getXcodeProj,
                      environment: getBuildEnvironment)
    if let pruningOperations = pruningPipeline?.operations {
      queue.addOperations(pruningOperations, waitUntilFinished: false)
    }
    let findMockedTypesOperation = pruningPipeline?.findMockedTypesOperation
    
    // Create abstract generation pipelines from targets and output paths.
    var pipelines = [Pipeline]()
    for (target, outputPath) in zip(targets, outputPaths) {
      guard !outputPath.isDirectory else {
        throw MalformedConfiguration(
          description: "Output file path points to a directory: \(outputPath)"
        )
      }
      try pipelines.append(Pipeline(inputTarget: target,
                                    outputPath: outputPath,
                                    config: config,
                                    findMockedTypesOperation: findMockedTypesOperation,
                                    environment: getBuildEnvironment))
    }
    pipelines.forEach({ queue.addOperations($0.operations, waitUntilFinished: false) })
    
    // Run the operations.
    let operationsCopy = queue.operations.compactMap({ $0 as? BasicOperation })
    queue.waitUntilAllOperationsAreFinished()
    operationsCopy.compactMap({ $0.error }).forEach({ log($0) })
    
    // Write intermediary module cache info into project cache directory.
    if !config.disableCache {
      try time(.cacheMocks) {
        try cachePipelines(sourcePipelines: pipelines, pruningPipeline: pruningPipeline)
      }
    }
  }
  
  func cachePipelines(sourcePipelines: [Pipeline], pruningPipeline: PruningPipeline?) throws {
    guard let projectHash = getProjectHash(config.projectPath) else { return }
    
    // Cache source targets for generation.
    try sourceTargetCacheDirectory.mkpath()
    try sourcePipelines.forEach({
      try $0.cache(projectHash: projectHash,
                   cliVersion: cliVersion,
                   configHash: configHash,
                   sourceRoot: config.sourceRoot,
                   cacheDirectory: sourceTargetCacheDirectory,
                   environment: getBuildEnvironment)
    })
    
    // Cache test target for thunk pruning.
    if !config.disableThunkStubs {
      if let testTargetCacheDirectory = testTargetCacheDirectory,
        let environmentSourceRoot = config.environmentSourceRoot {
        try testTargetCacheDirectory.mkpath()
        try pruningPipeline?.cache(projectHash: projectHash,
                                   cliVersion: cliVersion,
                                   configHash: configHash,
                                   sourceRoot: environmentSourceRoot,
                                   cacheDirectory: testTargetCacheDirectory,
                                   environment: getBuildEnvironment)
      }
    }
  }
  
  static func defaultOutputPath(for sourceTarget: TargetType,
                                testTarget: TargetType? = nil,
                                sourceRoot: Path,
                                environment: () -> [String: Any]) -> Path {
    let moduleName = sourceTarget.resolveProductModuleName(environment: environment)
    
    let prefix: String
    if let testTargetName = testTarget?.resolveProductModuleName(environment: environment),
      testTargetName != moduleName {
      prefix = testTargetName + "-"
    } else {
      prefix = "" // Probably installed on a source target instead of a test target.
    }
    
    return sourceRoot.mocksDirectory + "\(prefix)\(moduleName)\(Constants.generatedFileNameSuffix)"
  }
  
  static func resolveTarget(targetName: String,
                            projectPath: Path,
                            isValidTarget: (PBXTarget) -> Bool,
                            getCachedTarget: (String) -> TargetType?,
                            getXcodeProj: (Path) throws -> XcodeProj) throws -> TargetType {
    // Check if the target is cached in the project.
    if let cachedTarget = getCachedTarget(targetName) {
      return cachedTarget
    }
    
    // Need to parse the Xcode project for the full `PBXTarget` object.
    let xcodeproj = try getXcodeProj(projectPath)
    let targets = xcodeproj.pbxproj.targets(named: targetName).filter(isValidTarget)
    
    if targets.count > 1 {
      logWarning("Found multiple targets named \(targetName.singleQuoted), using the first one")
    }
    
    guard let target = targets.first else {
      throw MalformedConfiguration(
        description: "Unable to find target named \(targetName.singleQuoted)"
      )
    }
    return .pbxTarget(target)
  }
}

extension Path {
  var mocksDirectory: Path {
    return absolute() + Path("MockingbirdMocks")
  }
  
  func targetLockFilePath(for targetName: String) -> Path {
    return self + "\(targetName).lock"
  }
}

extension XcodeProj {
  var implicitBuildEnvironment: [String: Any] {
    var buildEnvironment = [String: Any]()

    if let projectName = pbxproj.rootObject?.name {
      buildEnvironment["PROJECT_NAME"] = projectName
      buildEnvironment["PROJECT"] = projectName
    }
    
    return buildEnvironment
  }
}

extension PBXProductType {
  var isTestBundle: Bool {
    switch self {
    case .unitTestBundle, .uiTestBundle, .ocUnitTestBundle: return true
    default: return false
    }
  }
  
  var isSwiftUnitTestBundle: Bool {
    switch self {
    case .unitTestBundle: return true
    default: return false
    }
  }
}
