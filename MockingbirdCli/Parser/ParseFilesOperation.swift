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
  let imports: Set<String>
  let structure: Structure
  let shouldMock: Bool
  
  func clone(shouldMock: Bool) -> ParsedFile {
    return ParsedFile(file: file,
                      moduleName: moduleName,
                      imports: imports,
                      structure: structure,
                      shouldMock: shouldMock)
  }
}

class ParseFilesOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperation.Result
  
  class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
    fileprivate(set) var importedModuleNames = Set<String>()
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
                                  imports: file.parseImports(),
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
    result.importedModuleNames = Set(result.parsedFiles.flatMap({ $0.imports }))
  }
}

private extension Path {
  func getFile() -> File? {
    guard isFile else { return nil }
    let url = URL(fileURLWithPath: String(describing: absolute()), isDirectory: false)
    return try? File(contents: String(contentsOf: url, encoding: .utf8))
  }
}

private extension File {
  func parseImports() -> Set<String> {
    var imports = Set<String>()
    var currentSource = contents[..<contents.endIndex]

    while !currentSource.isEmpty {
      guard let lineIndex = currentSource.firstIndex(of: "\n") else { break }
      let lineContents = currentSource[..<lineIndex].trimmingCharacters(in: .whitespacesAndNewlines)
      
      let lineIndexDistance = currentSource.distance(from: currentSource.startIndex, to: lineIndex)
      currentSource = currentSource.dropFirst(lineIndexDistance+1)
      
      guard !lineContents.isEmpty else { continue }
      guard lineContents.hasPrefix("import ")
        || lineContents.hasPrefix("@testable import ")
        || lineContents.hasPrefix(";")
        else { continue }
      let moduleNames = lineContents.components(separatedBy: ";")
        .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        .filter({ $0.hasPrefix("import ") || $0.hasPrefix("@testable import ") })
        .map({String($0
          .components(separatedBy: "/").first!
          .trimmingCharacters(in: .whitespacesAndNewlines)) })
      imports = imports.union(moduleNames)
    }
    return imports
  }
}
