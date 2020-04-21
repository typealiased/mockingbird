//
//  CodableTarget.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/29/19.
//

import Foundation
import PathKit
import XcodeProj

public class CodableTargetDependency: TargetDependency, Codable {
  public let target: CodableTarget?
  
  init?<D: TargetDependency>(from dependency: D,
                             sourceRoot: Path,
                             ignoredDependencies: inout Set<String>) throws {
    guard let target = dependency.target else { return nil }
    self.target = try CodableTarget(from: target,
                                    sourceRoot: sourceRoot,
                                    ignoredDependencies: &ignoredDependencies)
  }
  
  public static func == (lhs: CodableTargetDependency, rhs: CodableTargetDependency) -> Bool {
    return lhs.target == rhs.target
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(target)
  }
}

public struct SourceFile: Codable, Hashable {
  public let path: String
  public let hash: String?
}

public class CodableTarget: Target, Codable {
  public let name: String
  public let productModuleName: String
  public let dependencies: [CodableTargetDependency]
  
  public let sourceFilePaths: [SourceFile]
  public let supportingFilePaths: [SourceFile]?
  public let sourceRoot: String
  public let projectHash: String?
  public let outputHash: String?
  public let targetPathsHash: String?
  public let dependencyPathsHash: String?
  public let cliVersion: String?
  
  public init<T: Target>(from target: T,
                         sourceRoot: Path,
                         supportPaths: [Path]? = nil,
                         projectHash: String? = nil,
                         outputHash: String? = nil,
                         targetPathsHash: String? = nil,
                         dependencyPathsHash: String? = nil,
                         cliVersion: String? = nil,
                         ignoredDependencies: inout Set<String>) throws {
    self.name = target.name
    self.productModuleName = target.productModuleName
    self.dependencies = try target.dependencies
      .filter({ !ignoredDependencies.contains($0.target?.productModuleName ?? "") })
      .compactMap({ try CodableTargetDependency(from: $0,
                                                sourceRoot: sourceRoot,
                                                ignoredDependencies: &ignoredDependencies) })
    ignoredDependencies.formUnion(self.dependencies.map({ $0.target?.productModuleName ?? "" }))
    self.sourceFilePaths = try target.findSourceFilePaths(sourceRoot: sourceRoot)
      .map({ $0.absolute() })
      .sorted()
      .map({ try SourceFile(path: "\($0)", hash: $0.read().generateSha1Hash()) })
    self.supportingFilePaths = try supportPaths?
      .map({ $0.absolute() })
      .sorted()
      .map({ try SourceFile(path: "\($0)", hash: $0.read().generateSha1Hash()) })
    self.targetPathsHash = targetPathsHash
    self.dependencyPathsHash = dependencyPathsHash
    self.sourceRoot = "\(sourceRoot.absolute())"
    self.projectHash = projectHash
    self.outputHash = outputHash
    self.cliVersion = cliVersion
  }
  
  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    guard "\(sourceRoot.absolute())" == self.sourceRoot else {
      logWarning("Cached source root does not match the input source root") // Should never happen
      return []
    }
    return sourceFilePaths.map({ Path($0.path) })
  }
  
  public static func == (lhs: CodableTarget, rhs: CodableTarget) -> Bool {
    return lhs.productModuleName == rhs.productModuleName
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(productModuleName)
  }
}
