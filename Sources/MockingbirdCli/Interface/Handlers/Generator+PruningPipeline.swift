//
//  Generator+PruningPipeline.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 6/11/20.
//

import Foundation
import MockingbirdGenerator
import PathKit
import XcodeProj

extension Generator {
  /// Constructs an operation graph for pruning thunks in generated mocks.
  struct PruningPipeline {
    let operations: [BasicOperation]
    let testTarget: TargetType
    let findMockedTypesOperation: FindMockedTypesOperation
    private let environmentTargetName: String
    
    init?(config: Configuration,
          getCachedTarget: (String) -> TargetType?,
          getProject: (Path) throws -> Project,
          environment: @escaping () -> [String: Any]) {
      guard let environmentProjectFilePath = config.environmentProjectFilePath,
        let environmentSourceRoot = config.environmentSourceRoot,
        let environmentTargetName = config.environmentTargetName
        else { return nil }
      self.environmentTargetName = environmentTargetName
      
      let isTestTarget: (TargetType) -> Bool = { target in
        switch target {
        case .pbxTarget(let target):
          guard target.productType?.isSwiftUnitTestBundle == true else {
            log("Ignoring \(target.name.singleQuoted) because it is not a Swift unit test bundle")
            return false
          }
          return true
        case .describedTarget(let target):
          switch target.productType {
          case .library, .none: return false
          case .test: return true
          }
        case .sourceTarget: return false
        case .testTarget: return true
        }
      }
      guard let testTarget = try? resolveTarget(targetName: environmentTargetName,
                                                projectPath: environmentProjectFilePath,
                                                isValidTarget: isTestTarget,
                                                getCachedTarget: getCachedTarget,
                                                getProject: getProject)
      else {
        log("Generating all thunks because the build environment target does not appear to be a Swift unit test bundle")
        return nil
      }
      
      let extractSources: BasicOperation
      let extractSourcesResult: ExtractSourcesOperationResult
      let cachedTestTarget: TestTarget?
      switch testTarget {
      case .pbxTarget(let target):
        let operation = ExtractSourcesOperation(target: target,
                                                sourceRoot: environmentSourceRoot,
                                                supportPath: config.supportPath,
                                                options: [],
                                                environment: environment)
        extractSources = operation
        extractSourcesResult = operation.result
        cachedTestTarget = nil
        
      case .describedTarget(let target):
        let operation = ExtractSourcesOperation(target: target,
                                                sourceRoot: environmentSourceRoot,
                                                supportPath: config.supportPath,
                                                options: [],
                                                environment: environment)
        extractSources = operation
        extractSourcesResult = operation.result
        cachedTestTarget = nil
        
      case .sourceTarget:
        fatalError("Invalid thunk test target")
      
      case .testTarget(let target):
        let operation = ExtractSourcesOperation(target: target as CodableTarget,
                                                sourceRoot: environmentSourceRoot,
                                                supportPath: config.supportPath,
                                                options: [],
                                                environment: environment)
        extractSources = operation
        extractSourcesResult = operation.result
        cachedTestTarget = target
      }
      
      let findMockedTypesOperation = FindMockedTypesOperation(
        extractSourcesResult: extractSourcesResult,
        cachedTestTarget: cachedTestTarget
      )
      findMockedTypesOperation.addDependency(extractSources)
      
      self.operations = [extractSources, findMockedTypesOperation]
      self.testTarget = testTarget
      self.findMockedTypesOperation = findMockedTypesOperation
    }
    
    func cache(projectHash: String,
               cliVersion: String,
               configHash: String,
               sourceRoot: Path,
               cacheDirectory: Path,
               environment: () -> [String: Any]) throws {
      let mockedTypeNames = findMockedTypesOperation.result.mockedTypeNames
      
      let target: TestTarget
      switch testTarget {
      case .pbxTarget(let pipelineTarget):
        target = try TestTarget(from: pipelineTarget,
                                sourceRoot: sourceRoot,
                                mockedTypeNames: mockedTypeNames,
                                projectHash: projectHash,
                                cliVersion: cliVersion,
                                configHash: configHash,
                                environment: environment)
        
      case .describedTarget(let pipelineTarget):
        target = try TestTarget(from: pipelineTarget,
                                sourceRoot: sourceRoot,
                                mockedTypeNames: mockedTypeNames,
                                projectHash: projectHash,
                                cliVersion: cliVersion,
                                configHash: configHash,
                                environment: environment)
        
      case .sourceTarget:
        fatalError("Invalid pipeline test target")
        
      case .testTarget(let pipelineTarget):
        target = try TestTarget(from: pipelineTarget,
                                sourceRoot: sourceRoot,
                                mockedTypeNames: mockedTypeNames,
                                projectHash: projectHash,
                                cliVersion: cliVersion,
                                configHash: configHash,
                                environment: environment)
      }
      
      let data = try JSONEncoder().encode(target)
      let filePath = cacheDirectory.targetLockFilePath(for: target.name, testBundle:  environmentTargetName)
      try filePath.write(data)
      log("Cached pipeline test target \(target.name.singleQuoted) to \(filePath.absolute())")
    }
  }
  
  func findCachedTestTarget(for targetName: String,
                            projectHash: String,
                            cliVersion: String,
                            configHash: String,
                            cacheDirectory: Path,
                            sourceRoot: Path) -> TestTarget? {
    let filePath = cacheDirectory.targetLockFilePath(for: targetName, testBundle: self.config.environmentTargetName)
    
    guard filePath.exists else {
      log("No cached test target metadata exists for \(targetName.singleQuoted) at \(filePath.absolute())")
      return nil
    }
    
    guard let target = try? JSONDecoder().decode(TestTarget.self, from: filePath.read()) else {
      logWarning("Unable to decode the cached test target metadata at \(filePath.absolute())")
      return nil
    }
    
    guard target.sourceRoot.absolute() == sourceRoot.absolute() else {
      log("Invalidated cached test target metadata for \(targetName.singleQuoted) because the source root changed from \(target.sourceRoot.absolute()) to \(sourceRoot.absolute())")
      return nil
    }
    
    guard target.projectHash == projectHash else {
      log("Invalidated cached test target metadata for \(targetName.singleQuoted) because the project hash changed from \(target.projectHash.singleQuoted) to \(projectHash.singleQuoted)")
      return nil
    }
    
    guard cliVersion == target.cliVersion else {
      log("Invalidated cached test target metadata for \(target.name.singleQuoted) because the CLI version changed from \(target.cliVersion.singleQuoted) to \(cliVersion.singleQuoted)")
      return nil
    }
    
    guard configHash == target.configHash else {
      log("Invalidated cached test target metadata for \(target.name.singleQuoted) because the config hash changed from \(target.configHash.singleQuoted) to \(configHash.singleQuoted)")
      return nil
    }
    
    log("Using valid cached test target metadata for \(targetName.singleQuoted) at \(filePath.absolute())")
    return target
  }
}
