//
//  SupportingSourcesPath.swift
//  MockingbirdCli
//
//  Created by typealias on 8/7/21.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

final class SupportingSourcesPath: DirectoryPath {}

extension SupportingSourcesPath: InferableArgument {
  convenience init?(context: ArgumentContext) throws {
    let defaultSupportPath = Self.genDefaultPath(workingPath: context.workingPath)
    guard defaultSupportPath.exists, defaultSupportPath.isDirectory else {
      return nil
    }
    log("Using inferred support path at \(defaultSupportPath.absolute())")
    self.init(path: defaultSupportPath)
  }
  
  static func genDefaultPath(workingPath: Path) -> Path {
    return workingPath + "MockingbirdSupport"
  }
}
