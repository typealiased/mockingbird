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
        codableTarget.cliVersion == "\(mockingbirdVersion)",
        let targetPathsHash = codableTarget.targetPathsHash,
        let dependencyPathsHash = codableTarget.dependencyPathsHash,
        let outputHash = codableTarget.outputHash,
        try extractSourcesResult.generateTargetPathsHash() == targetPathsHash,
        try extractSourcesResult.generateDependencyPathsHash() == dependencyPathsHash,
        try outputFilePath.read().generateSha1Hash() == outputHash else {
          log("Detected \(changedFiles.count) changed source file\(changedFiles.count != 1 ? "s" : "") for target `\(codableTarget.name)` - \(changedFiles.map({ "\($0.path.absolute())" }))")
          return
      }
      log("Ignoring target `\(codableTarget.name)` because no source files were changed, the CLI version matches `\(mockingbirdVersion)`, and the generated mock file matches the expected SHA-1 hash of `\(outputHash)`")
      result.isCached = true
    }
  }
}

extension CodableTarget {
  func flattenedSourceHashes() -> [String: String] {
    var moduleSourceHashes = [String: [String: String]]()
    flattenModuleSourceHashes(&moduleSourceHashes)
    
    // Merge each module's flattened source hashes, de-duping by path.
    var sourceHashes = [String: String]()
    moduleSourceHashes.forEach({
      sourceHashes.merge($0.value) { (current, new) in return new }
    })
    
    return sourceHashes
  }
  
  /// Flattens each module's sources and dependency sources (with memoization).
  /// Module name => [Path => SHA-1]
  func flattenModuleSourceHashes(_ current: inout [String: [String: String]]) {
    guard current[productModuleName] == nil else { return }
    
    var sourceHashes = [String: String]()
    (sourceFilePaths + (supportingFilePaths ?? [])).forEach({ sourceHashes[$0.path] = $0.hash })
    
    // Traverse module dependencies.
    dependencies.compactMap({ $0.target }).forEach({ $0.flattenModuleSourceHashes(&current) })
    current[productModuleName] = sourceHashes
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
