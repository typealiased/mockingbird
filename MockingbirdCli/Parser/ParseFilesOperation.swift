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

struct ParsedFile {
  let file: File
  let moduleName: String
  let structure: Structure
  let shouldMock: Bool
  
  func clone(shouldMock: Bool) -> ParsedFile {
    return ParsedFile(file: file,
                      moduleName: moduleName,
                      structure: structure,
                      shouldMock: shouldMock)
  }
}

class ParseFilesOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperation.Result
  
  class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
  }
  
  let result = Result()
  
  private let queue = OperationQueue()
  class SubOperation: BasicOperation {
    let sourcePath: SourcePath
    let shouldMock: Bool
    
    class Result {
      fileprivate(set) var parsedFile: ParsedFile?
    }
    
    let result = Result()
    
    init(sourcePath: SourcePath, shouldMock: Bool) {
      self.sourcePath = sourcePath
      self.shouldMock = shouldMock
    }
    
    private static var memoizedParsedFiles = Synchronized<[SourcePath: ParsedFile]>([:])
    
    override func run() {
      let sourcePath = self.sourcePath
      if let memoized = ParseFilesOperation.SubOperation.memoizedParsedFiles.value[sourcePath] {
        result.parsedFile = memoized.clone(shouldMock: shouldMock)
        return
      }
      
      guard let file = sourcePath.path.getFile(),
        let structure = try? Structure(file: file) else { return }
      let parsedFile = ParsedFile(file: file,
                                  moduleName: sourcePath.moduleName,
                                  structure: structure,
                                  shouldMock: shouldMock)
      ParseFilesOperation.SubOperation.memoizedParsedFiles.update { $0[sourcePath] = parsedFile }
      result.parsedFile = parsedFile
    }
  }
  
  init(extractSourcesResult: ExtractSourcesOperation.Result) {
    self.extractSourcesResult = extractSourcesResult
  }
  
  override func run() {
    let operations = extractSourcesResult.targetPaths.map({
      SubOperation(sourcePath: $0, shouldMock: true)
    }) + extractSourcesResult.dependencyPaths.map({
      SubOperation(sourcePath: $0, shouldMock: false)
    })
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount * 2
    queue.addOperations(operations, waitUntilFinished: true)
    result.parsedFiles = operations.compactMap({ $0.result.parsedFile })
  }
}

private extension Path {
  func getFile() -> File? {
    guard isFile else { return nil }
    let url = URL(fileURLWithPath: String(describing: absolute()), isDirectory: false)
    return try? File(contents: String(contentsOf: url, encoding: .utf8))
  }
}
