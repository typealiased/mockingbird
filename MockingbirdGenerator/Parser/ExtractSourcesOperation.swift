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
    ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = paths }
    return paths
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
