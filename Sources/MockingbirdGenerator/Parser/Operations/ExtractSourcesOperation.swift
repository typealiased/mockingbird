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

public struct ExtractSourcesOptions: OptionSet {
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let dependencyPaths = ExtractSourcesOptions(rawValue: 1 << 1)
  public static let useMockingbirdIgnore = ExtractSourcesOptions(rawValue: 1 << 2)
  
  public static let all: ExtractSourcesOptions = [.dependencyPaths, .useMockingbirdIgnore]
}

/// Given a target, find all related source files including those compiled by dependencies.
public class ExtractSourcesOperation<T: Target>: BasicOperation, ExtractSourcesAbstractOperation {
  public let target: T
  let sourceRoot: Path
  let supportPath: Path?
  let options: ExtractSourcesOptions
  let environment: () -> [String: Any]
  
  public let result = ExtractSourcesOperationResult()
  
  public override var description: String { "Extract Sources" }
  
  public init(target: T,
              sourceRoot: Path,
              supportPath: Path?,
              options: ExtractSourcesOptions,
              environment: @escaping () -> [String: Any]) {
    self.target = target
    self.sourceRoot = sourceRoot
    self.supportPath = supportPath
    self.options = options
    self.environment = environment
  }
  
  override func run() throws {
    try time(.extractSources) {
      result.targetPaths = sourceFilePaths(for: target)
      
      if options.contains(.dependencyPaths) {
        let supportSourcePaths: Set<SourcePath>
        if let supportPath = supportPath {
          supportSourcePaths = try findSupportSourcePaths(at: supportPath)
        } else {
          supportSourcePaths = []
        }
        result.supportPaths = supportSourcePaths
      
        result.dependencyPaths =
          Set(allTargets(for: target).flatMap({ sourceFilePaths(for: $0) }))
            .union(supportSourcePaths)
            .subtracting(result.targetPaths)
      }
    }
    log("Found \(result.targetPaths.count) source file\(result.targetPaths.count != 1 ? "s" : "") and \(result.dependencyPaths.count) dependency source file\(result.dependencyPaths.count != 1 ? "s" : "") for target \(target.name.singleQuoted)")
  }
  
  /// Returns the compiled source file paths for a single given target.
  private var memoizedSourceFilePaths = [T: Set<SourcePath>]()
  private func sourceFilePaths(for target: T) -> Set<SourcePath> {
    if let memoized = memoizedSourceFilePaths[target] { return memoized }
    
    let moduleName = resolveProductModuleName(for: target)
    let paths = target.findSourceFilePaths(sourceRoot: sourceRoot)
      .map({ SourcePath(path: $0, moduleName: moduleName) })
    
    let includedPaths = includedSourcePaths(for: Set(paths))
    memoizedSourceFilePaths[target] = includedPaths
    
    return includedPaths
  }
  
  /// Recursively find all targets and its dependency targets.
  private var memoizedTargets = [T: Set<T>]()
  private func allTargets(for target: T) -> Set<T> {
    if let memoized = memoizedTargets[target] { return memoized }
    
    let targets = Set([target]).union(
      target.dependencies
        .compactMap({ $0.target as? T })
        .flatMap({ allTargets(for: $0) }))
    let productModuleName = resolveProductModuleName(for: target)
    
    result.moduleDependencies[productModuleName] = Set(targets.map({
      resolveProductModuleName(for: $0)
    }))
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
  
  /// Only returns non-ignored source file paths based on `.mockingbird-ignore` glob declarations.
  private func includedSourcePaths(for sourcePaths: Set<SourcePath>) -> Set<SourcePath> {
    guard options.contains(.useMockingbirdIgnore) else { return sourcePaths }
    let operations = sourcePaths.map({
      retainForever(GlobSearchOperation(sourcePath: $0, sourceRoot: sourceRoot))
    })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    return Set(operations.compactMap({ $0.result.sourcePath }))
  }
  
  private var memoizedProductModuleNames = [T: String]()
  private func resolveProductModuleName(for target: T) -> String {
    if let memoized = memoizedProductModuleNames[target] { return memoized }
    let productModuleName = target.resolveProductModuleName(environment: environment)
    memoizedProductModuleNames[target] = productModuleName
    return productModuleName
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
    static let negationPrefix = "!"
    static let escapingToken = "\\"
  }
  
  override var description: String { "Glob Search" }
  
  override func run() throws {
    guard shouldInclude(sourcePath: sourcePath.path, in: sourcePath.path.parent()).value else {
      log("Ignoring source path at \(sourcePath.path.absolute())")
      return
    }
    result.sourcePath = sourcePath
  }
  
  struct Glob {
    let pattern: String
    let isNegated: Bool
    let root: Path
  }
  
  /// Recursively checks the source path against any `.mockingbird-ignore` files in the current
  /// directory and traversed subdirectories, working from the source path up to the SRCROOT.
  private func shouldInclude(sourcePath: Path, in directory: Path) -> (value: Bool, globs: [Glob]) {
    guard directory.isDirectory else { return (true, []) }
    let matches: (Bool, [Glob]) -> Bool = { (inheritedState, globs) in
      return globs.reduce(into: inheritedState) { (result, glob) in
        let trailingSlash = glob.pattern.hasPrefix("/") ? "" : "/"
        let pattern = "\(glob.root.absolute())" + trailingSlash + glob.pattern
        let matches = directory.matches(pattern: pattern, isDirectory: true)
          || sourcePath.matches(pattern: pattern, isDirectory: false)
        
        if glob.isNegated { // Inclusion
          result = result || matches
        } else { // Exclusion
          result = result && !matches
        }
      }
    }
    
    // Recursively find globs if this source is within the project SRCROOT.
    guard "\(directory.absolute())".hasPrefix("\(sourceRoot.absolute())") else { return (true, []) }
    let (parentShouldInclude, parentGlobs) = shouldInclude(sourcePath: sourcePath,
                                                           in: directory.parent())
    // Handle non-relative patterns (which can match at any level below the defining ignore level)
    // by cumulatively shifting the root to the current directory. This treats each subsequent
    // directory like it has an ignore file with all of the patterns from its parents.
    let allParentGlobs = parentGlobs + parentGlobs
      .filter({ glob in // Only non-relative patterns (no leading slash, single path component).
        guard !glob.pattern.hasPrefix("/") else { return false }
        return Path(glob.pattern).components.count == 1
      })
      .map({
        Glob(pattern: $0.pattern, isNegated: $0.isNegated, root: directory)
      })

    // Read in the `.mockingbird-ignore` file contents and find glob declarations.
    let ignoreFile = directory + Constants.mockingbirdIgnoreFileName
    guard ignoreFile.isFile else {
      return (matches(parentShouldInclude, parentGlobs), allParentGlobs)
    }
    guard let globs = try? ignoreFile.read(.utf8).components(separatedBy: "\n")
      .filter({ line -> Bool in
        let stripped = line.trimmingCharacters(in: .whitespaces)
        return !stripped.isEmpty && !stripped.hasPrefix(Constants.commentPrefix)
      })
      .map({ rawLine -> Glob in
        let isNegated = rawLine.hasPrefix("!")
        
        // Handle filenames that start with an escaped `!` or `#`.
        let line: String
        if rawLine.hasPrefix(Constants.escapingToken + Constants.negationPrefix)
          || rawLine.hasPrefix(Constants.escapingToken + Constants.commentPrefix) {
          line = String(rawLine.dropFirst())
        } else {
          line = rawLine
        }
        
        guard !line.hasPrefix("/") else {
          return Glob(pattern: line, isNegated: isNegated, root: directory)
        }
        
        let pattern = !isNegated ? line : String(line.dropFirst(Constants.negationPrefix.count))
        return Glob(pattern: pattern, isNegated: isNegated, root: directory)
      })
    else {
      logWarning("Unable to read \(Constants.mockingbirdIgnoreFileName.singleQuoted) at \(ignoreFile.absolute())")
      return (!matches(parentShouldInclude, parentGlobs), allParentGlobs)
    }
    
    let allGlobs = allParentGlobs + globs
    return (matches(parentShouldInclude, allGlobs), allGlobs)
  }
}
