//
//  SourceRootPath.swift
//  MockingbirdCli
//
//  Created by typealias on 8/13/21.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

final class SourceRootPath: DirectoryPath {}

extension SourceRootPath: InferableArgument {
  convenience init?(context: ArgumentContext) throws {
    guard let sourceRoot =
            context.environment["SRCROOT"] ??
            context.environment["SOURCE_ROOT"] else {
      return nil
    }
    
    let path = Path(sourceRoot)
    guard path.exists, path.isDirectory else {
      return nil
    }
    
    log("Using inferred srcroot path at \(path.absolute())")
    self.init(path: path)
  }
}
