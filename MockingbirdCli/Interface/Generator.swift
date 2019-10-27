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
  struct Configuration {
    let projectPath: Path
    let sourceRoot: Path
    let inputTargetNames: [String]
    let outputPaths: [Path]?
    let supportPath: Path?
    let compilationCondition: String?
    let shouldImportModule: Bool
    let onlyMockProtocols: Bool
    let disableSwiftlint: Bool
    let disableCache: Bool
  }
  
  enum Failure: Error, CustomStringConvertible {
    case malformedConfiguration(description: String)
    case internalError(description: String)
    
    var description: String {
      switch self {
      case .malformedConfiguration(let description):
        return "Malformed configuration - \(description)"
      case .internalError(let description):
        return "Internal error - \(description)"
      }
    }
  }
  
  enum Constants {
    static let generatedFileNameSuffix = "Mocks.generated.swift"
  }
  
  struct Pipeline {
    let inputTarget: AbstractTarget
    let outputPath: Path
    let operations: [BasicOperation]
    var usedCache: Bool {
      return operations.contains(where: {
        guard let operation = $0 as? CheckCacheOperation else { return false }
        return operation.result.isCached
      })
    }
    
    init(inputTarget: AbstractTarget, outputPath: Path, config: Configuration) throws {
      self.inputTarget = inputTarget
      self.outputPath = outputPath
      self.operations = try Pipeline.createOperations(for: inputTarget,
                                                      outputPath: outputPath,
                                                      config: config)
    }
    
    private static func createOperations(for inputTarget: AbstractTarget,
                                         outputPath: Path,
                                         config: Configuration) throws -> [BasicOperation] {
      let extractSources: ExtractSourcesAbstractOperation
      let checkCache: CheckCacheOperation?
      
      if let inputTarget = inputTarget as? CodableTarget {
        extractSources = ExtractSourcesOperation(with: inputTarget,
                                                 sourceRoot: config.sourceRoot,
                                                 supportPath: config.supportPath)
        checkCache = CheckCacheOperation(extractSourcesResult: extractSources.result,
                                         codableTarget: inputTarget,
                                         outputFilePath: outputPath)
        checkCache?.addDependency(extractSources)
      } else if let inputTarget = inputTarget as? PBXTarget {
        extractSources = ExtractSourcesOperation(with: inputTarget,
                                                 sourceRoot: config.sourceRoot,
                                                 supportPath: config.supportPath)
        checkCache = nil
      } else {
        throw Failure.internalError(
          description: "Unsupported pipeline input target `\(inputTarget.productModuleName)`"
        )
      }
        
      let parseFiles = ParseFilesOperation(extractSourcesResult: extractSources.result,
                                           checkCacheResult: checkCache?.result)
      parseFiles.addDependency(extractSources)
      
      let processTypes = ProcessTypesOperation(parseFilesResult: parseFiles.result,
                                               checkCacheResult: checkCache?.result)
      processTypes.addDependency(parseFiles)
      
      let moduleName = inputTarget.productModuleName
      let generateFile = GenerateFileOperation(processTypesResult: processTypes.result,
                                               checkCacheResult: checkCache?.result,
                                               moduleName: moduleName,
                                               outputPath: outputPath,
                                               compilationCondition: config.compilationCondition,
                                               shouldImportModule: config.shouldImportModule,
                                               onlyMockProtocols: config.onlyMockProtocols,
                                               disableSwiftlint: config.disableSwiftlint)
      generateFile.addDependency(processTypes)
      
      if let checkCache = checkCache {
        parseFiles.addDependency(checkCache)
        return [extractSources, checkCache, parseFiles, processTypes, generateFile]
      } else {
        return [extractSources, parseFiles, processTypes, generateFile]
      }
    }
  }
  
  static func generate(using config: Configuration) throws {
    guard config.outputPaths == nil || config.inputTargetNames.count == config.outputPaths?.count else {
      throw Failure.malformedConfiguration(
        description: "Number of input targets does not match the number of output file paths"
      )
    }
    
    if config.supportPath == nil {
      logWarning("No supporting source files specified. Running the generator without supporting source files can result in malformed mocks. Please see 'Supporting Source Files' in the README.")
    }
    
    var lazyXcodeProj: XcodeProj?
    let getXcodeProj: () throws -> XcodeProj = {
      if let xcodeproj = lazyXcodeProj { return xcodeproj }
      var xcodeproj: XcodeProj!
      try time(.parseXcodeProject) {
        xcodeproj = try XcodeProj(path: config.projectPath)
      }
      lazyXcodeProj = xcodeproj
      return xcodeproj
    }
    
    let pbxprojPath = !config.disableCache ? config.projectPath.glob("*.pbxproj").first : nil
    let pbxprojHash = try pbxprojPath?.read().generateSha1Hash()
    let cacheDirectory = config.projectPath + "MockingbirdCache"
    if let projectHash = pbxprojHash {
      log("Using SHA-1 project hash `\(projectHash)` and cache directory at \(cacheDirectory)")
    }

    // Resolve target names to concrete Xcode project targets.
    let targets = try config.inputTargetNames.compactMap({ targetName throws -> AbstractTarget? in
      // Check if the target is cached in the project.
      if let projectHash = pbxprojHash,
        let target = cachedTarget(for: targetName,
                                  projectHash: projectHash,
                                  cacheDirectory: cacheDirectory,
                                  sourceRoot: config.sourceRoot) {
        return target
      }
      
      // Need to parse the Xcode project for the full `PBXTarget` object.
      let xcodeproj = try getXcodeProj()
      let targets = xcodeproj.pbxproj.targets(named: targetName).filter({ target in
        guard target.productType?.isTestBundle != true else {
          logWarning("Ignoring unit test target `\(targetName)`")
          return false
        }
        return true
      })
      if targets.count > 1 {
        logWarning("Found multiple input targets named `\(targetName)`, using the first one")
      }
      guard let target = targets.first else {
        throw Failure.malformedConfiguration(
          description: "Unable to find input target named `\(targetName)`"
        )
      }
      return target
    })
    
    // Resolve nil output paths to mocks source root and output suffix.
    let outputPaths = try config.outputPaths ?? targets.map({ target throws -> Path in
      try config.sourceRoot.mocksDirectory.mkpath()
      return Generator.defaultOutputPath(for: target, sourceRoot: config.sourceRoot)
    })
    
    // Create abstract generation pipelines from targets and output paths.
    var pipelines = [Pipeline]()
    for (target, outputPath) in zip(targets, outputPaths) {
      guard !outputPath.isDirectory else {
        throw Failure.malformedConfiguration(description: "Output file path points to a directory: \(outputPath)")
      }
      try pipelines.append(Pipeline(inputTarget: target, outputPath: outputPath, config: config))
    }
    
    // Create concrete generation operation graphs from pipelines.
    let queue = OperationQueue.createForActiveProcessors()
    pipelines.forEach({ queue.addOperations($0.operations, waitUntilFinished: false) })
    let operationsCopy = queue.operations.compactMap({ $0 as? BasicOperation })
    queue.waitUntilAllOperationsAreFinished()
    operationsCopy.compactMap({ $0.error }).forEach({ log($0) })
    
    // Write intermediary module cache info into project cache directory.
    if let projectHash = pbxprojHash {
      try time(.cacheMocks) {
        try cacheDirectory.mkpath()
        try pipelines.forEach({
          try cachePipeline($0,
                            projectHash: projectHash,
                            sourceRoot: config.sourceRoot,
                            cacheDirectory: cacheDirectory)
        })
      }
    }
  }
  
  static func defaultOutputPath(for target: AbstractTarget, sourceRoot: Path) -> Path {
    let moduleName = target.productModuleName
    return sourceRoot.mocksDirectory + "\(moduleName)\(Constants.generatedFileNameSuffix)"
  }
  
  static func targetLockFilePath(for targetName: String, cacheDirectory: Path) -> Path {
    return cacheDirectory + "\(targetName).lock"
  }
  
  static func cachedTarget(for targetName: String,
                           projectHash: String,
                           cacheDirectory: Path,
                           sourceRoot: Path) -> CodableTarget? {
    let filePath = targetLockFilePath(for: targetName, cacheDirectory: cacheDirectory)
    guard filePath.exists,
      let target = try? JSONDecoder().decode(CodableTarget.self, from: filePath.read()) else {
        logWarning("Unable to decode the cached target data at \(filePath.absolute())")
        return nil
    }
    guard target.projectHash == projectHash else {
      log("Current project hash invalidates the cached target data at \(filePath.absolute())")
      return nil
    }
    guard Path(target.sourceRoot) == sourceRoot else {
      log("Project source root invalidates the cached target data at \(filePath.absolute())")
      return nil
    }
    
    log("Found cached source file information for target `\(targetName)` at \(filePath.absolute())")
    return target
  }
  
  static func cachePipeline(_ pipeline: Pipeline,
                            projectHash: String,
                            sourceRoot: Path,
                            cacheDirectory: Path) throws {
    guard !pipeline.usedCache,
      let result = pipeline.operations
        .compactMap({ $0 as? ExtractSourcesAbstractOperation }).first?.result else { return }
    
    var ignoredDependencies = Set<String>()
    let target: CodableTarget
    if let pipelineTarget = pipeline.inputTarget as? CodableTarget {
      target = try CodableTarget(from: pipelineTarget,
                                 sourceRoot: sourceRoot,
                                 supportPaths: result.supportPaths.map({ $0.path }),
                                 projectHash: projectHash,
                                 outputHash: pipeline.outputPath.read().generateSha1Hash(),
                                 targetPathsHash: result.generateTargetPathsHash(),
                                 dependencyPathsHash: result.generateDependencyPathsHash(),
                                 ignoredDependencies: &ignoredDependencies)
    } else if let pipelineTarget = pipeline.inputTarget as? PBXTarget {
      target = try CodableTarget(from: pipelineTarget,
                                 sourceRoot: sourceRoot,
                                 supportPaths: result.supportPaths.map({ $0.path }),
                                 projectHash: projectHash,
                                 outputHash: pipeline.outputPath.read().generateSha1Hash(),
                                 targetPathsHash: result.generateTargetPathsHash(),
                                 dependencyPathsHash: result.generateDependencyPathsHash(),
                                 ignoredDependencies: &ignoredDependencies)
    } else {
      throw Failure.internalError(
        description: "Unsupported pipeline input target `\(pipeline.inputTarget.productModuleName)`"
      )
    }
    let data = try JSONEncoder().encode(target)
    let filePath = targetLockFilePath(for: target.name, cacheDirectory: cacheDirectory)
    try filePath.write(data)
    log("Cached pipeline input target `\(pipeline.inputTarget.productModuleName)` to \(filePath.absolute())")
  }
}

extension Path {
  var mocksDirectory: Path {
    return absolute() + Path("MockingbirdMocks")
  }
}

extension PBXProductType {
  var isTestBundle: Bool {
    switch self {
    case .unitTestBundle, .uiTestBundle, .ocUnitTestBundle: return true
    default: return false
    }
  }
}
