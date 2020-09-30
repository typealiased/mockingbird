//
//  CodableTarget.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/29/19.
//

import Foundation
import PathKit
import XcodeProj

public struct SourceFile: Codable, Hashable {
  public let path: Path
  public let hash: String?
}

/// A sparse representation of dependencies is used since caching only relies on the unique set of
/// dependency sources for a single module being mocked.
public class CodableTargetDependency: TargetDependency, Codable {
  public let target: CodableTarget?
  
  init?<D: TargetDependency>(from dependency: D,
                             sourceRoot: Path,
                             ignoredDependencies: inout Set<String>,
                             environment: () -> [String: Any]) throws {
    guard let target = dependency.target else { return nil }
    self.target = try CodableTarget(from: target,
                                    sourceRoot: sourceRoot,
                                    ignoredDependencies: &ignoredDependencies,
                                    environment: environment)
  }
  
  init(target: CodableTarget) {
    self.target = target
  }
  
  public static func == (lhs: CodableTargetDependency, rhs: CodableTargetDependency) -> Bool {
    return lhs.target == rhs.target
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(target)
  }
}

public class CodableTarget: Target, Codable {
  public let name: String
  public let productModuleName: String
  public let dependencies: [CodableTargetDependency]
  
  public let sourceRoot: Path
  public let sourceFilePaths: [SourceFile]
  
  public init<T: Target>(from target: T,
                         sourceRoot: Path,
                         dependencies: [CodableTargetDependency]? = nil,
                         ignoredDependencies: inout Set<String>,
                         environment: () -> [String: Any]) throws {
    self.name = target.name
    self.productModuleName = target.resolveProductModuleName(environment: environment)
    if let dependencies = dependencies {
      self.dependencies = dependencies
    } else {
      self.dependencies = try target.dependencies
        .filter({
          !ignoredDependencies.contains(
            $0.target?.resolveProductModuleName(environment: environment) ?? ""
          )
        })
        .compactMap({
          try CodableTargetDependency(from: $0,
                                      sourceRoot: sourceRoot,
                                      ignoredDependencies: &ignoredDependencies,
                                      environment: environment)
        })
    }
    ignoredDependencies.formUnion(self.dependencies.map({ $0.target?.productModuleName ?? "" }))
    self.sourceFilePaths = try target.findSourceFilePaths(sourceRoot: sourceRoot)
      .map({ $0.absolute() })
      .sorted()
      .map({
        let data = (try? $0.read()) ?? Data()
        return try SourceFile(path: $0, hash: data.generateSha1Hash())
      })
    self.sourceRoot = sourceRoot.absolute()
  }
  
  init(name: String,
       productModuleName: String,
       dependencies: [CodableTargetDependency],
       sourceRoot: Path,
       sourceFilePaths: [SourceFile]) {
    self.name = name
    self.productModuleName = productModuleName
    self.dependencies = dependencies
    self.sourceRoot = sourceRoot
    self.sourceFilePaths = sourceFilePaths
  }
  
  public func resolveProductModuleName(environment: () -> [String : Any]) -> String {
    return productModuleName
  }
  
  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    guard sourceRoot.absolute() == self.sourceRoot.absolute() else {
      // Should not happen unless the `.xcodeproj` is moved relative to `SRCROOT`.
      logWarning("Cached source root does not match the input source root")
      return []
    }
    return sourceFilePaths.map({ $0.path })
  }
  
  public static func == (lhs: CodableTarget, rhs: CodableTarget) -> Bool {
    return lhs.productModuleName == rhs.productModuleName
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(productModuleName)
  }
}
