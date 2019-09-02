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

class Generator {
  struct Configuration {
    let projectPath: Path
    let sourceRoot: Path
    let inputTargetNames: [String]
    let outputPaths: [Path]?
    let preprocessorExpression: String?
    let shouldImportModule: Bool
    let onlyMockProtocols: Bool
    let disableSwiftlint: Bool
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
  
  enum Constants {
    static let generatedFileNameSuffix = "Mocks.generated.swift"
  }
  
  struct Pipeline {
    let inputTarget: PBXTarget
    let outputPath: Path
    
    func createOperations(with config: Configuration) -> [BasicOperation] {
      let extractSources = ExtractSourcesOperation(with: inputTarget,
                                                   sourceRoot: config.sourceRoot)
      let parseFiles = ParseFilesOperation(extractSourcesResult: extractSources.result)
      parseFiles.addDependency(extractSources)
      let processTypes = ProcessTypesOperation(parseFilesResult: parseFiles.result)
      processTypes.addDependency(parseFiles)
      let moduleName = inputTarget.productModuleName ?? inputTarget.name
      let generateFile = GenerateFileOperation(processTypesResult: processTypes.result,
                                               moduleName: moduleName,
                                               outputPath: outputPath,
                                               preprocessorExpression: config.preprocessorExpression,
                                               shouldImportModule: config.shouldImportModule,
                                               onlyMockProtocols: config.onlyMockProtocols,
                                               disableSwiftlint: config.disableSwiftlint)
      generateFile.addDependency(processTypes)
      return [extractSources, parseFiles, processTypes, generateFile]
    }
  }
  
  static func generate(using config: Configuration) throws {
    guard config.outputPaths == nil || config.inputTargetNames.count == config.outputPaths?.count else {
      throw Failure.malformedConfiguration(description: "Number of input targets does not match the number of output file paths")
    }
    
    let xcodeproj = try XcodeProj(path: config.projectPath)
    
    // Resolve target names to concrete Xcode project targets.
    let targets = try config.inputTargetNames.map({ targetName throws -> PBXTarget in
      guard let target = xcodeproj.pbxproj.targets(named: targetName).first else {
        throw Failure.malformedConfiguration(description: "Unable to find input target named `\(targetName)`")
      }
      return target
    })
    
    // Resolve nil output paths to mocks source root and output suffix.
    let outputPaths = try config.outputPaths ?? targets.map({ target throws -> Path in
      try config.sourceRoot.mocksDirectory.mkpath()
      let moduleName = target.productModuleName ?? target.name
      return config.sourceRoot.mocksDirectory + "\(moduleName)\(Constants.generatedFileNameSuffix)"
    })
    
    // Create abstract generation pipelines from targets and output paths.
    var pipelines = [Pipeline]()
    for (target, outputPath) in zip(targets, outputPaths) {
      guard !outputPath.isDirectory else {
        throw Failure.malformedConfiguration(description: "Output file path points to a directory: \(outputPath)")
      }
      pipelines.append(Pipeline(inputTarget: target, outputPath: outputPath))
    }
    
    // Create concrete generation operation graphs from pipelines.
    time("Generated mocks for all targets") {
      let queue = OperationQueue.createForActiveProcessors()
      pipelines.forEach({
        queue.addOperations($0.createOperations(with: config), waitUntilFinished: false)
      })
      let operationsCopy = queue.operations.compactMap({ $0 as? BasicOperation })
      queue.waitUntilAllOperationsAreFinished()
      operationsCopy.forEach({
        guard let error = $0.error else { return }
        fputs(error.localizedDescription + "\n", stderr)
      })
    }
  }
}

extension Path {
  var mocksDirectory: Path {
    return absolute() + Path("Mockingbird/Mocks/")
  }
}
