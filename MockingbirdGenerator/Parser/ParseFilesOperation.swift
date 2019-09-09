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
  let data: Data?
  let path: Path
  let moduleName: String
  let imports: Set<String>
  let importedModuleNames: Set<String>
  let structure: Structure
  let shouldMock: Bool
  
  init(file: File,
       path: Path,
       moduleName: String,
       imports: Set<String>,
       structure: Structure,
       shouldMock: Bool) {
    self.file = file
    self.data = file.contents.data(using: .utf8, allowLossyConversion: false)
    self.path = path
    self.moduleName = moduleName
    self.imports = imports
    self.importedModuleNames = Set(imports.compactMap({
      guard let importKeywordIndex = $0.range(of: #"\bimport\b"#, options: .regularExpression)
        else { return nil }
      let importDeclaration = $0[$0.index(after: importKeywordIndex.upperBound)...]
      guard let moduleMemberIndex = importDeclaration.firstIndex(of: ".") else {
        return String(importDeclaration).trimmingCharacters(in: .whitespacesAndNewlines)
      }
      return String(importDeclaration[..<moduleMemberIndex])
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }))
    self.structure = structure
    self.shouldMock = shouldMock
  }
  
  func clone(shouldMock: Bool) -> ParsedFile {
    return ParsedFile(file: file,
                      path: path,
                      moduleName: moduleName,
                      imports: imports,
                      structure: structure,
                      shouldMock: shouldMock)
  }
}

public class ParseFilesOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperation.Result
  
  public class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
    fileprivate(set) var imports = Set<String>()
    fileprivate(set) var moduleDependencies = [String: Set<String>]()
  }
  
  public let result = Result()
  
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
    
    override func run() throws {
      let sourcePath = self.sourcePath
      if let memoized = ParseFilesOperation.SubOperation.memoizedParsedFiles.value[sourcePath] {
        result.parsedFile = memoized.clone(shouldMock: shouldMock)
        return
      }
      
      let file = try sourcePath.path.getFile()
      let structure = try Structure(file: file)
      let parsedFile = ParsedFile(file: file,
                                  path: sourcePath.path,
                                  moduleName: sourcePath.moduleName,
                                  imports: shouldMock ? file.parseImports() : [],
                                  structure: structure,
                                  shouldMock: shouldMock)
      ParseFilesOperation.SubOperation.memoizedParsedFiles.update { $0[sourcePath] = parsedFile }
      result.parsedFile = parsedFile
    }
  }
  
  public init(extractSourcesResult: ExtractSourcesOperation.Result) {
    self.extractSourcesResult = extractSourcesResult
  }
  
  override func run() {
    let operations = extractSourcesResult.targetPaths.map({
      SubOperation(sourcePath: $0, shouldMock: true)
    }) + extractSourcesResult.dependencyPaths.map({
      SubOperation(sourcePath: $0, shouldMock: false)
    })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    result.parsedFiles = operations.compactMap({ $0.result.parsedFile })
    result.imports = Set(result.parsedFiles.flatMap({ $0.imports }))
    result.moduleDependencies = extractSourcesResult.moduleDependencies
  }
}

private extension Path {
  func getFile() throws -> File {
    let url = URL(fileURLWithPath: String(describing: absolute()), isDirectory: false)
    return try File(contents: String(contentsOf: url, encoding: .utf8))
  }
}

private extension File {
  /// Parses a file line-by-line looking for valid import declarations.
  func parseImports() -> Set<String> {
    var imports = Set<String>()
    var currentSource = contents[..<contents.endIndex]

    while true {
      let lineIndex = currentSource.firstIndex(of: "\n") ?? currentSource.endIndex
      let lineContents = currentSource[..<lineIndex].trimmingCharacters(in: .whitespacesAndNewlines)
      
      if !lineContents.isEmpty && (
        lineContents.hasPrefix("import ") ||
        lineContents.hasPrefix("@testable import ") ||
        lineContents.hasPrefix(";")
      ) {
        let moduleNames = lineContents.substringComponents(separatedBy: ";")
          .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
          .filter({ $0.hasPrefix("import ") || $0.hasPrefix("@testable import ") })
          .map({String($0
            .substringComponents(separatedBy: "/").first!
            .trimmingCharacters(in: .whitespacesAndNewlines)) })
        imports = imports.union(moduleNames)
      }
      
      guard lineIndex != currentSource.endIndex else { break }
      currentSource = currentSource[currentSource.index(after: lineIndex)..<currentSource.endIndex]
    }
    return imports
  }
}
