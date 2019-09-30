//
//  CheckCacheOperation.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/30/19.
//

import Foundation
import PathKit

public class CheckCacheOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperationResult
  let codableTarget: CodableTarget
  let outputFilePath: Path
  let sourceHashes: [String: String]
  
  public class Result {
    fileprivate(set) public var isCached = false
  }
  
  public let result = Result()
  
  public init(extractSourcesResult: ExtractSourcesOperationResult,
              codableTarget: CodableTarget,
              outputFilePath: Path) {
    self.extractSourcesResult = extractSourcesResult
    self.codableTarget = codableTarget
    self.outputFilePath = outputFilePath
    self.sourceHashes = codableTarget.flattenedSourceHashes()
  }
  
  override func run() throws {
    try time(.checkCache) {
      let changedFiles = try extractSourcesResult.targetPaths
        .union(extractSourcesResult.dependencyPaths)
        .filter({
          let hash = try $0.path.read().generateSha1Hash()
          return hash != sourceHashes["\($0.path.absolute())"]
        })
      
      guard changedFiles.isEmpty,
        let targetPathsHash = codableTarget.targetPathsHash,
        let dependencyPathsHash = codableTarget.dependencyPathsHash,
        let outputHash = codableTarget.outputHash,
        try extractSourcesResult.generateTargetPathsHash() == targetPathsHash,
        try extractSourcesResult.generateDependencyPathsHash() == dependencyPathsHash,
        try outputFilePath.read().generateSha1Hash() == outputHash else {
          log("Detected \(changedFiles.count) changed source file\(changedFiles.count != 1 ? "s" : "") for target `\(codableTarget.name)` - \(changedFiles.map({ "\($0.path.absolute())" }))")
          return
      }
      log("Ignoring target `\(codableTarget.name)` because no source files were changed and the generated mock file matches the expected SHA-1 hash of `\(outputHash)`")
      result.isCached = true
    }
  }
}

extension CodableTarget {
  func flattenedSourceHashes() -> [String: String] {
    var sourceHashes = [String: String]()
    (sourceFilePaths + (supportingFilePaths ?? [])).forEach({ sourceHashes[$0.path] = $0.hash })
    dependencies.compactMap({ $0.target }).map({ $0.flattenedSourceHashes() }).forEach({
      sourceHashes.merge($0) { (current, new) in return new }
    })
    return sourceHashes
  }
}

public extension ExtractSourcesOperationResult {
  func generateTargetPathsHash() throws -> String {
    return try targetPaths
      .map({ "\($0.path.absolute())" })
      .sorted()
      .joined(separator: ":")
      .generateSha1Hash()
  }
  
  func generateDependencyPathsHash() throws -> String {
    return try dependencyPaths
      .map({ "\($0.path.absolute())" })
      .sorted()
      .joined(separator: ":")
      .generateSha1Hash()
  }
}
