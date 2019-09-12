//
//  ExtractSourcesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit
import XcodeProj

struct SourcePath: Hashable, Equatable {
  let path: Path
  let moduleName: String
}

/// Given a target, find all related source files including those compiled by dependencies.
public class ExtractSourcesOperation: BasicOperation {
  let target: PBXTarget
  let sourceRoot: Path
  
  public class Result {
    fileprivate(set) var targetPaths = Set<SourcePath>()
    fileprivate(set) var dependencyPaths = Set<SourcePath>()
    fileprivate(set) var moduleDependencies = [String: Set<String>]()
  }
  
  public let result = Result()
  
  private enum Constants {
    static let mockingbirdIgnoreFileName = ".mockingbird-ignore"
    static let commentPrefix = "#"
  }
  
  public init(with target: PBXTarget, sourceRoot: Path) {
    self.target = target
    self.sourceRoot = sourceRoot
  }
  
  override func run() throws {
    result.targetPaths = sourceFilePaths(for: target)
    result.dependencyPaths =
      Set(allTargets(for: target, includeTarget: false).flatMap({ sourceFilePaths(for: $0) }))
        .subtracting(result.targetPaths)
  }
  
  private static var memoizedSourceFilePaths = Synchronized<[PBXTarget: Set<SourcePath>]>([:])
  /// Returns the compiled source file paths for a single given target.
  private func sourceFilePaths(for target: PBXTarget) -> Set<SourcePath> {
    if let memoized = ExtractSourcesOperation.memoizedSourceFilePaths.value[target] {
      return memoized
    }
    guard let phase = target.buildPhases.first(where: { $0.buildPhase == .sources }) else {
      ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = [] }
      return []
    }
    let inferredModuleName = target.productModuleName
    let paths = Set(phase.files?
      .compactMap({ try? $0.file?.fullPath(sourceRoot: sourceRoot) })
      .filter({ $0.extension == "swift" })
      .map({ SourcePath(path: $0, moduleName: inferredModuleName) })
      ?? [])
    let includedPaths = includedSourcePaths(for: paths)
    ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = includedPaths }
    return includedPaths
  }
  
  private static var memoizedAllTargets = Synchronized<[PBXTarget: Set<PBXTarget>]>([:])
  /// Recursively find all targets and its dependency targets.
  private func allTargets(for target: PBXTarget, includeTarget: Bool = true) -> Set<PBXTarget> {
    if let memoized = ExtractSourcesOperation.memoizedAllTargets.value[target] {
      return memoized
    }
    let targets = Set([target]).union(target.dependencies
      .compactMap({ $0.target })
      .flatMap({ allTargets(for: $0) }))
    result.moduleDependencies[target.productModuleName] = Set(targets.map({ $0.productModuleName }))
    ExtractSourcesOperation.memoizedAllTargets.update { $0[target] = targets }
    return targets
  }
  
  /// Only returns non-ignored source file paths based on `.mockingbird-ignored` glob declarations.
  private func includedSourcePaths(for sourcePaths: Set<SourcePath>) -> Set<SourcePath> {
    let operations = sourcePaths.map({ GlobSearchOperation(sourcePath: $0,
                                                           sourceRoot: sourceRoot) })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    return Set(operations.compactMap({ $0.result.sourcePath }))
  }
  
  private class GlobSearchOperation: BasicOperation {
    class Result {
      fileprivate(set) var sourcePath: SourcePath?
    }
    let result = Result()
    
    let sourcePath: SourcePath
    let sourceRoot: Path
    init(sourcePath: SourcePath, sourceRoot: Path) {
      self.sourcePath = sourcePath
      self.sourceRoot = sourceRoot
    }
    
    override func run() throws {
      guard shouldInclude(sourcePath: sourcePath.path, in: sourcePath.path.parent()).value else {
        return
      }
      result.sourcePath = sourcePath
    }
    
    private func shouldInclude(sourcePath: Path, in directory: Path) -> (value: Bool, globs: Set<String>) {
      guard directory.isDirectory else { return (true, []) }
      let memoizationKey = "\(directory.absolute())"
      let matches: (Set<String>) -> Bool = { globs in
        return globs.contains(where: {
          directory.matches(pattern: $0, isDirectory: true)
            || sourcePath.matches(pattern: $0, isDirectory: false)
        })
      }
      
      // Recursively find globs if this source is within the project SRCROOT.
      guard memoizationKey.hasPrefix("\(sourceRoot.absolute())") else { return (true, []) }
      let (parentShouldInclude, parentGlobs) = shouldInclude(sourcePath: sourcePath,
                                                             in: directory.parent())
      if !parentShouldInclude { return (false, parentGlobs) }
      
      // Read in the `.mockingbird-ignore` file contents and find glob declarations.
      let ignoreFile = directory + Constants.mockingbirdIgnoreFileName
      guard ignoreFile.isFile else { return (!matches(parentGlobs), parentGlobs) }
      guard let lines = try? ignoreFile.read(.utf8).components(separatedBy: "\n")
        .filter({ line -> Bool in
          let stripped = line.stripped()
          return !stripped.isEmpty && !stripped.hasPrefix(Constants.commentPrefix)
        })
        .map({ line -> String in
          guard !line.hasPrefix("/") else { return line }
          return "\(directory.absolute())/" + line
        }) else {
          fputs("Unable to read \(Constants.mockingbirdIgnoreFileName) at \(ignoreFile.absolute())\n", stderr)
          return (!matches(parentGlobs), parentGlobs)
      }
      let globs = parentGlobs.union(Set(lines))
      //    ExtractSourcesOperation.memoizedGlobs.update { $0[memoizationKey] = globs }
      return (!matches(globs), globs)
    }
  }
}

public extension PBXTarget {
  var productModuleName: String {
    guard let inferredDebugConfig = buildConfigurationList?.buildConfigurations
      .first(where: { $0.name.lowercased() == "debug" })
      ?? buildConfigurationList?.buildConfigurations.first,
      let moduleName = inferredDebugConfig.buildSettings["PRODUCT_MODULE_NAME"] as? String,
      !moduleName.hasPrefix("$(") // TODO: Parse environment vars in build configurations.
      else { return productName ?? name }
    return moduleName
  }
}
