//
//  FindMockedTypesOperation.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 6/7/20.
//

import Foundation
import PathKit
import SwiftSyntax

public class FindMockedTypesOperation: BasicOperation {
  public class Result {
    public fileprivate(set) var allMockedTypeNames = Set<String>()
    public fileprivate(set) var mockedTypeNames = [Path: Set<String>]()
    
    public func generateMockedTypeNamesHash() throws -> String {
      return try allMockedTypeNames.sorted().joined(separator: ":").generateSha1Hash()
    }
  }
  
  public let result = Result()
  public override var description: String { "Find Mocked Types" }
  let extractSourcesResult: ExtractSourcesOperationResult
  let cachedTestTarget: TestTarget?
  
  public init(extractSourcesResult: ExtractSourcesOperationResult,
              cachedTestTarget: TestTarget?) {
    self.extractSourcesResult = extractSourcesResult
    self.cachedTestTarget = cachedTestTarget
  }
  
  override func run() throws {
    time(.parseTests) {
      let cachedMockedTypeNames = cachedTestTarget?.sourceFilePaths
        .reduce(into: [Path: (typeNames: Set<String>, fileHash: String)]()) {
          (result, sourceFile) in
          guard let hash = sourceFile.hash,
            let mockedTypeNames = cachedTestTarget?.mockedTypeNames[sourceFile.path]
            else { return }
          result[sourceFile.path] = (typeNames: mockedTypeNames, fileHash: hash)
      }
      
      let operations = extractSourcesResult.targetPaths
        .filter({ "\($0.path)".hasSuffix(".generated.swift") == false })
        .map({ sourcePath -> ParseTestFileOperation in
          let operation = ParseTestFileOperation(
            sourcePath: sourcePath,
            cachedMockedTypeNames: cachedMockedTypeNames?[sourcePath.path]
          )
          retainForever(operation)
          return operation
        })
      let queue = OperationQueue.createForActiveProcessors()
      queue.addOperations(operations, waitUntilFinished: true)
      result.allMockedTypeNames = Set(operations.flatMap({ $0.result.mockedTypeNames }))
      result.mockedTypeNames = operations.reduce(into: [Path: Set<String>]()) {
        (mockedTypeNames, operation) in
        mockedTypeNames[operation.sourcePath.path] = operation.result.mockedTypeNames
      }
    }
  }
}

/// Find mock types that are referenced in a `mock(SomeType.self)` initializer.
private class ParseTestFileOperation: BasicOperation {
  class Result {
    fileprivate(set) var mockedTypeNames = Set<String>()
  }
  
  let result = Result()
  override var description: String { "Parse Test File" }
  let sourcePath: SourcePath
  let cachedMockedTypeNames: (typeNames: Set<String>, fileHash: String)?
  
  init(sourcePath: SourcePath, cachedMockedTypeNames: (Set<String>, fileHash: String)?) {
    self.sourcePath = sourcePath
    self.cachedMockedTypeNames = cachedMockedTypeNames
  }
  
  override func run() throws {
    if let cached = try checkCached() {
      result.mockedTypeNames = cached
      return
    }
    
    let file = try sourcePath.path.getFile()
    let sourceFile = try SyntaxParser.parse(source: file.contents)
    let parser = TestFileParser().parse(sourceFile)
    retainForever(parser)
    result.mockedTypeNames = parser.mockedTypeNames
    log("Parsed \(result.mockedTypeNames.count) referenced mock type\(result.mockedTypeNames.count != 1 ? "s" : "") in \(sourcePath.path.absolute())")
  }
  
  private func checkCached() throws -> Set<String>? {
    guard let cachedMockedTypeNames = cachedMockedTypeNames else { return nil }
    let currentHash = try sourcePath.path.read().generateSha1Hash()
    guard currentHash == cachedMockedTypeNames.fileHash else {
      log("Invalidated cached referenced mock types because the test file content hash changed from \(cachedMockedTypeNames.fileHash.singleQuoted) to \(currentHash.singleQuoted) for \(sourcePath.path.absolute())")
      return nil
    }
    
    log("Using \(cachedMockedTypeNames.typeNames.count) cached referenced mock type\(cachedMockedTypeNames.typeNames.count != 1 ? "s" : "") for \(sourcePath.path.absolute())")
    return cachedMockedTypeNames.typeNames
  }
}
