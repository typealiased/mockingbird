//
//  Target.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/15/20.
//

import Foundation
import PathKit

public protocol TargetDependency: Hashable {
  associatedtype T where T: Target
  var target: T? { get }
}

public protocol AbstractTarget {
  var name: String { get }
  func resolveProductModuleName(environment: () -> [String: Any]) -> String
}

/// Common protocol that both XcodeProj `PBXTarget` and our own `CodableTarget` objects conform to.
public protocol Target: AbstractTarget, Hashable {
  associatedtype D where D: TargetDependency
  
  var dependencies: [D] { get }
  func findSourceFilePaths(sourceRoot: Path) -> [Path]
}
