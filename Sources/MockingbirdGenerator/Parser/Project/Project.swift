//
//  Project.swift
//  MockingbirdGenerator
//
//  Created by typealias on 9/23/20.
//

import Foundation
import XcodeProj

public enum Project {
  case xcode(_ xcodeProj: XcodeProj)
  case json(_ jsonProject: JSONProject)
  
  public func targets(named name: String) -> [TargetType] {
    switch self {
    case .xcode(let xcodeProj):
      return xcodeProj.pbxproj.targets(named: name).map({ .pbxTarget($0) })
    case .json(let jsonProject):
      return jsonProject.targets(named: name).map({ .describedTarget($0) })
    }
  }
}
