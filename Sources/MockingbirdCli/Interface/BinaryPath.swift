//
//  BinaryPath.swift
//  MockingbirdCli
//
//  Created by typealias on 8/8/21.
//

import ArgumentParser
import Foundation
import PathKit

struct BinaryPath: ExpressibleByArgument {
  var path: Path
  
  init?(argument: String) {
    self.path = Path(argument)
  }
  
  static var defaultCompletionKind: CompletionKind = .file()
}

extension BinaryPath: InferableArgument {
  init?(context: ArgumentContext) throws {
    let launcherPath = context.environment["MKB_LAUNCHER"]
    let realBinaryPath = context.arguments[0]
    self.path = Path(launcherPath ?? realBinaryPath)
  }
}

extension BinaryPath: ValidatableArgument {
  func validate(name: String) throws {
    let realPath = try path.followRecursively()
    guard realPath.isExecutable else {
      throw ValidationError("'\(name)' must be executable")
    }
  }
}
