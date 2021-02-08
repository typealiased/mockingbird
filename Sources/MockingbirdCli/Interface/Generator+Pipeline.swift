//
//  Generator+Pipeline.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 6/7/20.
//

import Foundation
import MockingbirdGenerator
import PathKit
import XcodeProj

extension Generator {
  /// Constructs an operation graph for generating mocks.
  struct Pipeline {
    let inputTarget: TargetType
    let outputPath: Path
    let operations: [BasicOperation]
    var usedCache: Bool {
      return operations.contains(where: {
        guard let operation = $0 as? CheckCacheOperation else { return false }
        return operation.result.isCached
      })
    }
    private let mockedTypesResult: FindMockedTypesOperation.Result?
    private let environmentTargetName: String?
    
    init(inputTarget: TargetType,
         outputPath: Path,
         config: Configuration,
         findMockedTypesOperation: FindMockedTypesOperation?,
         environment: @escaping () -> [String: Any]) throws {
      self.inputTarget = inputTarget
      self.outputPath = outputPath
      self.environmentTargetName = config.environmentTargetName
      
      // Extract sources.
      let extractSources: ExtractSourcesAbstractOperation
      let checkCache: CheckCacheOperation?
      switch inputTarget {
      case .pbxTarget(let target):
        extractSources = ExtractSourcesOperation(target: target,
                                                 sourceRoot: config.sourceRoot,
                                                 supportPath: config.supportPath,
                                                 options: .all,
                                                 environment: environment)
        checkCache = nil
        
      case .describedTarget(let target):
        extractSources = ExtractSourcesOperation(target: target,
                                                 sourceRoot: config.sourceRoot,
                                                 supportPath: config.supportPath,
                                                 options: .all,
                                                 environment: environment)
        checkCache = nil
      
      case .sourceTarget(let target):
        extractSources = ExtractSourcesOperation(target: target as CodableTarget,
                                                 sourceRoot: config.sourceRoot,
                                                 supportPath: config.supportPath,
                                                 options: .all,
                                                 environment: environment)
        checkCache = CheckCacheOperation(extractSourcesResult: extractSources.result,
                                         findMockedTypesResult: findMockedTypesOperation?.result,
                                         target: target,
                                         outputFilePath: outputPath)
        checkCache?.addDependency(extractSources)
        
      case .testTarget:
        fatalError("Invalid pipeline input target")
      }
      
      // Parse files.
      let parseFiles = ParseFilesOperation(extractSourcesResult: extractSources.result,
                                           checkCacheResult: checkCache?.result)
      parseFiles.addDependency(extractSources)
      
      // Process types.
      let processTypes = ProcessTypesOperation(parseFilesResult: parseFiles.result,
                                               checkCacheResult: checkCache?.result,
                                               useRelaxedLinking: !config.disableRelaxedLinking)
      processTypes.addDependency(parseFiles)
      
      // Generate files.
      let moduleName = inputTarget.resolveProductModuleName(environment: environment)
      let generateFile = GenerateFileOperation(
        processTypesResult: processTypes.result,
        checkCacheResult: checkCache?.result,
        findMockedTypesResult: findMockedTypesOperation?.result,
        config: GenerateFileConfig(
          moduleName: moduleName,
          outputPath: outputPath,
          header: config.header,
          compilationCondition: config.compilationCondition,
          shouldImportModule: config.shouldImportModule,
          onlyMockProtocols: config.onlyMockProtocols,
          disableSwiftlint: config.disableSwiftlint,
          pruningMethod: config.pruningMethod
        )
      )
      generateFile.addDependency(processTypes)
      
      if let findMockedTypesOperation = findMockedTypesOperation {
        generateFile.addDependency(findMockedTypesOperation)
      }
      self.mockedTypesResult = findMockedTypesOperation?.result
      
      if let checkCache = checkCache {
        parseFiles.addDependency(checkCache)
        self.operations = [extractSources, checkCache, parseFiles, processTypes, generateFile]
      } else {
        self.operations = [extractSources, parseFiles, processTypes, generateFile]
      }
    }
    
    func cache(projectHash: String,
               cliVersion: String,
               configHash: String,
               sourceRoot: Path,
               cacheDirectory: Path,
               environment: () -> [String: Any]) throws {
      guard !usedCache,
        let result = operations.compactMap({ $0 as? ExtractSourcesAbstractOperation }).first?.result
        else { return }
      
      // Used to keep a sparse representation of the dependency graph.
      var ignoredDependencies = Set<String>()
      
      let target: SourceTarget
      switch inputTarget {
      case .pbxTarget(let pipelineTarget):
        target = try SourceTarget(from: pipelineTarget,
                                  sourceRoot: sourceRoot,
                                  supportPaths: result.supportPaths.map({ $0.path }),
                                  projectHash: projectHash,
                                  outputHash: outputPath.read().generateSha1Hash(),
                                  mockedTypesHash: mockedTypesResult?.generateMockedTypeNamesHash(),
                                  targetPathsHash: result.generateTargetPathsHash(),
                                  dependencyPathsHash: result.generateDependencyPathsHash(),
                                  cliVersion: cliVersion,
                                  configHash: configHash,
                                  ignoredDependencies: &ignoredDependencies,
                                  environment: environment)
        
      case .describedTarget(let pipelineTarget):
        target = try SourceTarget(from: pipelineTarget,
                                  sourceRoot: sourceRoot,
                                  supportPaths: result.supportPaths.map({ $0.path }),
                                  projectHash: projectHash,
                                  outputHash: outputPath.read().generateSha1Hash(),
                                  mockedTypesHash: mockedTypesResult?.generateMockedTypeNamesHash(),
                                  targetPathsHash: result.generateTargetPathsHash(),
                                  dependencyPathsHash: result.generateDependencyPathsHash(),
                                  cliVersion: cliVersion,
                                  configHash: configHash,
                                  ignoredDependencies: &ignoredDependencies,
                                  environment: environment)
        
      case .sourceTarget(let pipelineTarget):
        target = try SourceTarget(from: pipelineTarget,
                                  sourceRoot: sourceRoot,
                                  supportPaths: result.supportPaths.map({ $0.path }),
                                  projectHash: projectHash,
                                  outputHash: outputPath.read().generateSha1Hash(),
                                  mockedTypesHash: mockedTypesResult?.generateMockedTypeNamesHash(),
                                  targetPathsHash: result.generateTargetPathsHash(),
                                  dependencyPathsHash: result.generateDependencyPathsHash(),
                                  cliVersion: cliVersion,
                                  configHash: configHash,
                                  ignoredDependencies: &ignoredDependencies,
                                  environment: environment)
        
      case .testTarget:
        fatalError("Invalid pipeline input target")
      }
      
      let data = try JSONEncoder().encode(target)
      let filePath = cacheDirectory.targetLockFilePath(for: target.name, testBundle: self.environmentTargetName)
      try filePath.write(data)
      log("Cached pipeline input target \(inputTarget.name.singleQuoted) to \(filePath.absolute())")
    }
  }
  
  func findCachedSourceTarget(for targetName: String,
                              cliVersion: String,
                              projectHash: String,
                              configHash: String,
                              cacheDirectory: Path,
                              sourceRoot: Path) -> SourceTarget? {
    let filePath = cacheDirectory.targetLockFilePath(for: targetName, testBundle: self.config.environmentTargetName)
    
    guard filePath.exists else {
      log("No cached source target metadata exists for \(targetName.singleQuoted) at \(filePath.absolute())")
      return nil
    }
    
    guard let target = try? JSONDecoder().decode(SourceTarget.self, from: filePath.read()) else {
      logWarning("Unable to decode the cached source target metadata at \(filePath.absolute())")
      return nil
    }
    
    guard target.projectHash == projectHash else {
      log("Invalidated cached source target metadata for \(targetName.singleQuoted) because the project hash changed from \(target.projectHash.singleQuoted) to \(projectHash.singleQuoted)")
      return nil
    }
    
    guard target.sourceRoot.absolute() == sourceRoot.absolute() else {
      log("Invalidated cached source target metadata for \(targetName.singleQuoted) because the source root changed from \(target.sourceRoot.absolute()) to \(sourceRoot.absolute())")
      return nil
    }
    
    guard cliVersion == target.cliVersion else {
      log("Invalidated cached source target metadata for \(target.name.singleQuoted) because the CLI version changed from \(target.cliVersion.singleQuoted) to \(cliVersion.singleQuoted)")
      return nil
    }
    
    guard configHash == target.configHash else {
      log("Invalidated cached source target metadata for \(target.name.singleQuoted) because the config hash changed from \(target.configHash.singleQuoted) to \(configHash.singleQuoted)")
      return nil
    }
    
    log("Using valid cached source target metadata for \(targetName.singleQuoted) at \(filePath.absolute())")
    return target
  }
}
