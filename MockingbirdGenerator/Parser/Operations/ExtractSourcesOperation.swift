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
import os.log

public struct SourcePath: Hashable, Equatable {
  public let path: Path
  public let moduleName: String
}

public class ExtractSourcesOperationResult {
  fileprivate(set) public var targetPaths = Set<SourcePath>()
  fileprivate(set) public var dependencyPaths = Set<SourcePath>()
  fileprivate(set) public var supportPaths = Set<SourcePath>() // Mainly used for caching.
  fileprivate(set) public var moduleDependencies = [String: Set<String>]()
}

public protocol ExtractSourcesAbstractOperation: BasicOperation {
  var result: ExtractSourcesOperationResult { get }
}

/// Given a target, find all related source files including those compiled by dependencies.
public class ExtractSourcesOperation<T: Target>: BasicOperation, ExtractSourcesAbstractOperation {
  public let target: T
  let sourceRoot: Path
  let supportPath: Path?
  
  public let result = ExtractSourcesOperationResult()
  
  public init(with target: T, sourceRoot: Path, supportPath: Path?) {
    self.target = target
    self.sourceRoot = sourceRoot
    self.supportPath = supportPath
  }
  
  override func run() throws {
    try time(.extractSources) {
      result.targetPaths = sourceFilePaths(for: target)
      
      let supportSourcePaths: Set<SourcePath>
      if let supportPath = supportPath {
        supportSourcePaths = try findSupportSourcePaths(at: supportPath)
      } else {
        supportSourcePaths = []
      }
      
      result.supportPaths = supportSourcePaths
      result.dependencyPaths = Set(allTargets(for: target, includeTarget: false)
        .flatMap({ sourceFilePaths(for: $0) }))
        .union(supportSourcePaths)
        .subtracting(result.targetPaths)
    }
    log("Found \(result.targetPaths.count) source file\(result.targetPaths.count != 1 ? "s" : "") and \(result.dependencyPaths.count) dependency source file\(result.dependencyPaths.count != 1 ? "s" : "") for target `\(target.name)`")
  }
  
  /// Returns the compiled source file paths for a single given target.
  private var memoizedSourceFilePaths = [T: Set<SourcePath>]()
  private func sourceFilePaths(for target: T) -> Set<SourcePath> {
    if let memoized = memoizedSourceFilePaths[target] { return memoized }
    let paths = target.findSourceFilePaths(sourceRoot: sourceRoot)
      .map({ SourcePath(path: $0, moduleName: target.productModuleName) })
    let includedPaths = includedSourcePaths(for: Set(paths))
    memoizedSourceFilePaths[target] = includedPaths
    return includedPaths
  }
  
  /// Recursively find all targets and its dependency targets.
  private var memoizedTargets = [T: Set<T>]()
  private func allTargets(for target: T, includeTarget: Bool = true) -> Set<T> {
    if let memoized = memoizedTargets[target] { return memoized }
    let targets = Set([target]).union(target.dependencies
      .compactMap({ $0.target as? T })
      .flatMap({ allTargets(for: $0) }))
    result.moduleDependencies[target.productModuleName] = Set(targets.map({ $0.productModuleName }))
    memoizedTargets[target] = targets
    return targets
  }
  
  /// Recursively find support module sources, taking each directory as the module name. Nested
  /// directories are treated as submodules and can be accessed as a source from each parent module.
  private func findSupportSourcePaths(at root: Path,
                                      isTopLevel: Bool = true) throws -> Set<SourcePath> {
    guard root.isDirectory else { return [] }
    let moduleName = root.lastComponent
    
    return try Set(root.children().flatMap({ path throws -> [SourcePath] in
      if path.isDirectory {
        let childSourcePaths = try findSupportSourcePaths(at: path, isTopLevel: false)
        // Parent modules inherit all submodule source paths.
        let inheritedSourcePaths = isTopLevel ? [] : childSourcePaths.map({
          SourcePath(path: $0.path, moduleName: moduleName)
        })
        return childSourcePaths + inheritedSourcePaths
      } else if !isTopLevel, path.isFile, path.extension == "swift" {
        return [SourcePath(path: path, moduleName: moduleName)]
      } else {
        return []
      }
    }))
  }
  
  /// Only returns non-ignored source file paths based on `.mockingbird-ignored` glob declarations.
  private func includedSourcePaths(for sourcePaths: Set<SourcePath>) -> Set<SourcePath> {
    let operations = sourcePaths.map({ GlobSearchOperation(sourcePath: $0,
                                                           sourceRoot: sourceRoot) })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    return Set(operations.compactMap({ $0.result.sourcePath }))
  }
}

/// Finds whether a given source path is ignored by a `.mockingbird-ignore` file.
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
  
  private enum Constants {
    static let mockingbirdIgnoreFileName = ".mockingbird-ignore"
    static let commentPrefix = "#"
  }
  
  override func run() throws {
    guard shouldInclude(sourcePath: sourcePath.path, in: sourcePath.path.parent()).value else {
      log("Ignoring source path at \(sourcePath.path.absolute())")
      return
    }
    result.sourcePath = sourcePath
  }
  
  private func shouldInclude(sourcePath: Path, in directory: Path) -> (value: Bool, globs: Set<String>) {
    guard directory.isDirectory else { return (true, []) }
    let matches: (Set<String>) -> Bool = { globs in
      return globs.contains(where: {
        directory.matches(pattern: $0, isDirectory: true)
          || sourcePath.matches(pattern: $0, isDirectory: false)
      })
    }
    
    // Recursively find globs if this source is within the project SRCROOT.
    guard "\(directory.absolute())".hasPrefix("\(sourceRoot.absolute())") else { return (true, []) }
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
        logWarning("Unable to read `\(Constants.mockingbirdIgnoreFileName)` at \(ignoreFile.absolute())")
        return (!matches(parentGlobs), parentGlobs)
    }
    let globs = parentGlobs.union(Set(lines))
    return (!matches(globs), globs)
  }
}
