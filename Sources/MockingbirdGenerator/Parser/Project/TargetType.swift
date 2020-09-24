//
//  TargetType.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 6/9/20.
//

import Foundation
import XcodeProj

public enum TargetType {
  case pbxTarget(_ pbxTarget: PBXTarget)
  case describedTarget(_ describedTarget: DescribedTarget)
  case sourceTarget(_ sourceTarget: SourceTarget)
  case testTarget(_ testTarget: TestTarget)
  
  public var name: String {
    switch self {
    case .pbxTarget(let target): return target.name
    case .describedTarget(let target): return target.name
    case .sourceTarget(let target): return target.name
    case .testTarget(let target): return target.name
    }
  }
  
  public func resolveProductModuleName(environment: () -> [String: Any]) -> String {
    switch self {
    case .pbxTarget(let target):
      return target.resolveProductModuleName(environment: environment)
    case .describedTarget(let target):
      return target.resolveProductModuleName(environment: environment)
    case .sourceTarget(let target):
      return target.resolveProductModuleName(environment: environment)
    case .testTarget(let target):
      return target.resolveProductModuleName(environment: environment)
    }
  }
}
