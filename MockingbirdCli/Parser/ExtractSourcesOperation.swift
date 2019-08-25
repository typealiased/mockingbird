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

class ExtractSourcesOperation: BasicOperation {
  let target: PBXTarget
  let sourceRoot: Path
  
  class Result {
    fileprivate(set) var targetPaths = Set<SourcePath>()
    fileprivate(set) var dependencyPaths = Set<SourcePath>()
  }
  
  let result = Result()
  
  init(with target: PBXTarget, sourceRoot: Path) {
    self.target = target
    self.sourceRoot = sourceRoot
  }
  
  override func run() {
    result.targetPaths = sourceFilePaths(for: target)
    result.dependencyPaths =
      Set(allTargets(for: target, includeTarget: false).flatMap({ sourceFilePaths(for: $0) }))
        .subtracting(result.targetPaths)
  }
  
  private static var memoizedSourceFilePaths = Synchronized<[PBXTarget: Set<SourcePath>]>([:])
  private func sourceFilePaths(for target: PBXTarget) -> Set<SourcePath> {
    if let memoized = ExtractSourcesOperation.memoizedSourceFilePaths.value[target] {
      return memoized
    }
    guard let phase = target.buildPhases.first(where: { $0.buildPhase == .sources }) else {
      ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = [] }
      return []
    }
    let inferredModuleName = target.productModuleName
      ?? self.target.productModuleName
      ?? self.target.name // This is a good assumption, but might not always be the case.
    let paths = Set(phase.files?
      .compactMap({ try? $0.file?.fullPath(sourceRoot: sourceRoot) })
      .filter({ $0.extension == "swift" })
      .map({ SourcePath(path: $0, moduleName: inferredModuleName) })
      ?? [])
    ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = paths }
    return paths
  }
  
  // Includes dependencies
  private static var memoizedAllTargets = Synchronized<[PBXTarget: Set<PBXTarget>]>([:])
  private func allTargets(for target: PBXTarget, includeTarget: Bool = true) -> Set<PBXTarget> {
    if let memoized = ExtractSourcesOperation.memoizedAllTargets.value[target] {
      return memoized
    }
    let targets = Set([target]).union(target.dependencies
      .compactMap({ $0.target })
      .flatMap({ allTargets(for: $0) }))
    ExtractSourcesOperation.memoizedAllTargets.update { $0[target] = targets }
    return targets
  }
}

extension PBXTarget {
  var productModuleName: String? {
    guard let inferredDebugConfig = buildConfigurationList?.buildConfigurations
      .first(where: { $0.name.lowercased() == "debug" })
      ?? buildConfigurationList?.buildConfigurations.first,
      let moduleName = inferredDebugConfig.buildSettings["PRODUCT_MODULE_NAME"] as? String,
      !moduleName.hasPrefix("$(") // TODO: Parse environment vars in build configurations.
      else { return productName }
    return moduleName
  }
}
