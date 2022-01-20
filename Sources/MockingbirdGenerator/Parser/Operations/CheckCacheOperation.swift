import Foundation
import MockingbirdCommon
import PathKit

public class CheckCacheOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperationResult
  let findMockedTypesResult: FindMockedTypesOperation.Result?
  let target: SourceTarget
  let outputFilePath: Path
  let sourceHashes: [Path: String]
  
  public class Result {
    fileprivate(set) public var isCached = false
  }
  
  public let result = Result()
  
  public override var description: String { "Check Cache" }
  
  public init(extractSourcesResult: ExtractSourcesOperationResult,
              findMockedTypesResult: FindMockedTypesOperation.Result?,
              target: SourceTarget,
              outputFilePath: Path) {
    self.extractSourcesResult = extractSourcesResult
    self.findMockedTypesResult = findMockedTypesResult
    self.target = target
    self.outputFilePath = outputFilePath
    self.sourceHashes = target.flattenedSourceHashes()
  }
  
  override func run() throws {
    try time(.checkCache) {
      let mockedTypesHash = try findMockedTypesResult?.generateMockedTypeNamesHash()
      guard mockedTypesHash == target.mockedTypesHash else {
        let previousHash = target.mockedTypesHash ?? ""
        let currentHash = mockedTypesHash ?? ""
        log("Invalidated cached source target metadata for \(target.name.singleQuoted) because the referenced mock types hash changed from \(previousHash.singleQuoted) to \(currentHash.singleQuoted)")
        return
      }
      
      let currentTargetPathsHash = try extractSourcesResult.generateTargetPathsHash()
      guard currentTargetPathsHash == target.targetPathsHash else {
        log("Invalidated cached mocks for \(target.name.singleQuoted) because the target paths hash changed from \(target.targetPathsHash.singleQuoted) to \(currentTargetPathsHash.singleQuoted)")
        return
      }
      
      let currentDependencyPathsHash = try extractSourcesResult.generateDependencyPathsHash()
      guard currentDependencyPathsHash == target.dependencyPathsHash else {
        log("Invalidated cached mocks for \(target.name.singleQuoted) because the dependency paths hash changed from \(target.dependencyPathsHash.singleQuoted) to \(currentDependencyPathsHash.singleQuoted)")
        return
      }
      
      let outputFileData = (try? outputFilePath.read()) ?? Data()
      let currentOutputFilePathHash = outputFileData.hash()
      guard currentOutputFilePathHash == target.outputHash else {
        log("Invalidated cached mocks for \(target.name.singleQuoted) because the output file content hash changed from \(target.outputHash.singleQuoted) to \(currentOutputFilePathHash.singleQuoted)")
        return
      }
      
      let changedFiles = extractSourcesResult.targetPaths
        .union(extractSourcesResult.dependencyPaths)
        .filter({
          return (try? $0.path.read())?.hash() != sourceHashes[$0.path.absolute()]
        })
      guard changedFiles.isEmpty else {
        log("Invalidated cached mocks for \(target.name.singleQuoted) because \(changedFiles.count) source file\(changedFiles.count != 1 ? "s" : "") were modified - \(changedFiles.map({ "\($0.path.absolute())" }).sorted())")
        return
      }
      
      log("Skipping mock generation for target \(target.name.singleQuoted) with valid cached data")
      result.isCached = true
    }
  }
}

extension SourceTarget {
  func flattenedSourceHashes() -> [Path: String] {
    var moduleSourceHashes = [String: [Path: String]]()
    flattenModuleSourceHashes(&moduleSourceHashes)
    
    // Merge each module's flattened source hashes, de-duping by path.
    var sourceHashes = [Path: String]()
    moduleSourceHashes.values.forEach({ hashes in
      sourceHashes.merge(hashes) { $1 }
    })
    
    return sourceHashes
  }
  
  func flattenModuleSourceHashes(_ current: inout [String: [Path: String]]) {
    flattenModuleSourceHashes(&current, supportingFilePaths: supportingFilePaths)
  }
}

extension CodableTarget {
  /// Flattens each module's sources and dependency sources (with memoization).
  /// Module name => [Path => SHA-1]
  func flattenModuleSourceHashes(_ current: inout [String: [Path: String]],
                                 supportingFilePaths: [SourceFile]? = []) {
    guard current[productModuleName] == nil else { return }
    
    var sourceHashes = [Path: String]()
    (sourceFilePaths + (supportingFilePaths ?? [])).forEach({
      sourceHashes[$0.path.absolute()] = $0.hash
    })
    
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
      .hash()
  }
  
  func generateDependencyPathsHash() throws -> String {
    return try dependencyPaths
      .map({ "\($0.path.absolute())" })
      .sorted()
      .joined(separator: ":")
      .hash()
  }
}
