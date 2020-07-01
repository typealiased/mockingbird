//
//  Target.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/15/20.
//

import Foundation
import PathKit
import XcodeProj

public protocol TargetDependency: Hashable {
  associatedtype T where T: Target
  var target: T? { get }
}

/// Common protocol that both XcodeProj `PBXTarget` and our own `CodableTarget` objects conform to.
public protocol Target: Hashable {
  associatedtype D where D: TargetDependency
  
  var name: String { get }
  var dependencies: [D] { get }
  
  func resolveProductModuleName(environment: () -> [String: Any]) -> String
  func findSourceFilePaths(sourceRoot: Path) -> [Path]
}
