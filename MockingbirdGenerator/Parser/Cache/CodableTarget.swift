//
//  CodableTarget.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/29/19.
//

import Foundation
import PathKit
import XcodeProj

// MARK: - XcodeProj adapters

public protocol TargetDependency: Hashable {
  associatedtype T where T: Target
  
  var target: T? { get }
}

public protocol AbstractTarget {
  var productModuleName: String { get }
}

public protocol Target: AbstractTarget, Hashable {
  associatedtype D where D: TargetDependency
  
  var name: String { get }
  var dependencies: [D] { get }
  
  func findSourceFilePaths(sourceRoot: Path) -> [Path]
}

// MARK: - Codable

public struct CodableTargetDependency: TargetDependency, Codable {
  public let target: CodableTarget?
  
  public init?(from dependency: PBXTargetDependency, sourceRoot: Path) {
    guard let target = dependency.target else { return nil }
    self.target = CodableTarget(from: target, sourceRoot: sourceRoot, projectHash: nil)
  }
}

public struct CodableTarget: Target, Codable {
  public let name: String
  public let productModuleName: String
  public let dependencies: [CodableTargetDependency]
  public let sourceFilePaths: [String]
  public let sourceRoot: String
  
  public let projectHash: String?
  
  public init(from target: PBXTarget, sourceRoot: Path, projectHash: String?) {
    self.name = target.name
    self.productModuleName = target.productModuleName
    self.dependencies = target.dependencies.compactMap({
      CodableTargetDependency(from: $0, sourceRoot: sourceRoot)
    })
    self.sourceFilePaths = target.findSourceFilePaths(sourceRoot: sourceRoot)
      .map({ "\($0.absolute())" })
      .sorted()
    self.sourceRoot = "\(sourceRoot.absolute())"
    self.projectHash = projectHash
  }
  
  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    guard "\(sourceRoot.absolute())" == self.sourceRoot else {
      logWarning("Cached source root does not match the input source root") // Should never happen
      return []
    }
    return sourceFilePaths.map({ Path($0) })
  }
}

// MARK: - XcodeProj conformance

extension PBXTarget: AbstractTarget {}

extension PBXTarget: Target {
  public var productModuleName: String {
    guard let inferredDebugConfig = buildConfigurationList?.buildConfigurations
      .first(where: { $0.name.lowercased() == "debug" })
      ?? buildConfigurationList?.buildConfigurations.first,
      let moduleName = inferredDebugConfig.buildSettings["PRODUCT_MODULE_NAME"] as? String,
      !moduleName.hasPrefix("$(") // TODO: Parse environment vars in build configurations.
      else { return productName ?? name }
    return moduleName
  }

  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    guard let phase = buildPhases.first(where: { $0.buildPhase == .sources }) else { return [] }
    return phase.files?
      .compactMap({ try? $0.file?.fullPath(sourceRoot: sourceRoot) })
      .filter({ $0.extension == "swift" }) ?? []
  }
}

extension PBXTargetDependency: TargetDependency {}
