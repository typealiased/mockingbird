//
//  ParseFilesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit
import SourceKittenFramework
import SwiftSyntax
import os.log

public class ParseFilesOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperationResult
  let checkCacheResult: CheckCacheOperation.Result?
  
  public class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
    fileprivate(set) var imports = Set<String>()
    fileprivate(set) var moduleDependencies = [String: Set<String>]()
  }
  
  public let result = Result()
  
  public override var description: String { "Parse Files" }
  
  public init(extractSourcesResult: ExtractSourcesOperationResult,
              checkCacheResult: CheckCacheOperation.Result?) {
    self.extractSourcesResult = extractSourcesResult
    self.checkCacheResult = checkCacheResult
  }
  
  override func run() {
    guard checkCacheResult?.isCached != true else { return }
    time(.parseFiles) {
      let createOperations: (SourcePath, Bool) -> [BasicOperation] = { (sourcePath, shouldMock) in
        let parseSourceKit = ParseSourceKitOperation(sourcePath: sourcePath)
        let parseSwiftSyntax = ParseSwiftSyntaxOperation(sourcePath: sourcePath)
        let parseSingleFile = ParseSingleFileOperation(sourcePath: sourcePath,
                                                       shouldMock: shouldMock,
                                                       sourceKitResult: parseSourceKit.result,
                                                       swiftSyntaxResult: parseSwiftSyntax.result)
        parseSingleFile.addDependency(parseSourceKit)
        parseSingleFile.addDependency(parseSwiftSyntax)
        retainForever(parseSourceKit)
        retainForever(parseSwiftSyntax)
        retainForever(parseSingleFile)
        return [parseSourceKit, parseSwiftSyntax, parseSingleFile]
      }
      let operations = extractSourcesResult.targetPaths.flatMap({ createOperations($0, true) })
        + extractSourcesResult.dependencyPaths.flatMap({ createOperations($0, false) })
      let queue = OperationQueue.createForActiveProcessors()
      queue.addOperations(operations, waitUntilFinished: true)
      result.parsedFiles = operations.compactMap({ operation in
        return (operation as? ParseSingleFileOperation)?.result.parsedFile
      })
    }
    result.imports = Set(result.parsedFiles.filter({ $0.shouldMock }).flatMap({ $0.imports }))
    result.moduleDependencies = extractSourcesResult.moduleDependencies
  }
}
