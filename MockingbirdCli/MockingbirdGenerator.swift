//
//  MockingbirdGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import XcodeProj
import PathKit

class MockingbirdCliGenerator {
  struct Configuration {
    let projectPath: Path
    let sourceRoot: Path
    let inputTargetNames: [String]
    let outputPaths: [Path]?
    let preprocessorExpression: String?
    let shouldImportModule: Bool
    let onlyMockProtocols: Bool
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
  
  static func generate(using config: Configuration) throws {
    guard config.outputPaths == nil || config.inputTargetNames.count == config.outputPaths?.count else {
      throw Failure.malformedConfiguration(description: "Number of input targets does not match the number of output file paths")
    }
    
    struct Pipeline {
      let inputTarget: PBXTarget
      let outputPath: Path
    }
    
    let xcodeproj = try XcodeProj(path: config.projectPath)
    var pipelines = [Pipeline]()
    for i in 0..<config.inputTargetNames.count {
      let targetName = config.inputTargetNames[i]
      guard let target = xcodeproj.pbxproj.targets(named: targetName).first else {
        throw Failure.malformedConfiguration(description: "Unable to find input target named `\(targetName)`")
      }
      
      let path: Path
      if let outputPath = config.outputPaths?[i] {
        path = outputPath
      } else {
        try config.sourceRoot.mocksDirectory.mkpath()
        let moduleName = target.productModuleName ?? target.name
        path = config.sourceRoot.mocksDirectory
          + "\(moduleName)\(MockingbirdCliConstants.generatedFileNameSuffix)"
      }
      guard !path.isDirectory else {
        throw Failure.malformedConfiguration(description: "Output file path points to a directory: \(path)")
      }
      
      pipelines.append(Pipeline(inputTarget: target, outputPath: path))
    }
    
    time("Generated mocks for all targets") {
      let queue = OperationQueue()
      queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
      
      var generateFileOperations = [GenerateFileOperation]()
      pipelines.forEach({ pipeline in
        let extractSources = ExtractSourcesOperation(with: pipeline.inputTarget,
                                                     sourceRoot: config.sourceRoot)
        let parseFiles = ParseFilesOperation(extractSourcesResult: extractSources.result)
        parseFiles.addDependency(extractSources)
        let processTypes = ProcessTypesOperation(parseFilesResult: parseFiles.result )
        processTypes.addDependency(parseFiles)
        let moduleName = pipeline.inputTarget.productModuleName ?? pipeline.inputTarget.name
        let generateFile = GenerateFileOperation(processTypesResult: processTypes.result,
                                                 moduleName: moduleName,
                                                 outputPath: pipeline.outputPath,
                                                 preprocessorExpression: config.preprocessorExpression,
                                                 shouldImportModule: config.shouldImportModule,
                                                 onlyMockProtocols: config.onlyMockProtocols)
        generateFile.addDependency(processTypes)
        generateFileOperations.append(generateFile)
        
        queue.addOperations([extractSources, parseFiles, processTypes, generateFile],
                            waitUntilFinished: false)
      })
      queue.waitUntilAllOperationsAreFinished()
      generateFileOperations.forEach({
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
