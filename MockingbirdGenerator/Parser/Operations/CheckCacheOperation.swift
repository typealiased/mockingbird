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
          guard let hash = try $0.path.read().generateSha1Hash() else { return false }
          return hash != sourceHashes["\($0.path.absolute())"]
        })
      guard changedFiles.isEmpty,
        let outputHash = codableTarget.outputHash,
        let currentHash = try outputFilePath.read().generateSha1Hash(),
        outputHash == currentHash else {
          let changedFilesList = changedFiles.map({ "\($0.path.absolute())" })
          log("Detected \(changedFiles.count) changed source file\(changedFiles.count != 1 ? "s" : "") for target `\(codableTarget.name)` - \(changedFilesList)")
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
    (sourceFilePaths + supportingFilePaths).forEach({ sourceHashes[$0.path] = $0.hash })
    dependencies.compactMap({ $0.target }).map({ $0.flattenedSourceHashes() }).forEach({
      sourceHashes.merge($0) { (current, new) in return new }
    })
    return sourceHashes
  }
}
