//
//  Path+Symlink.swift
//  MockingbirdCli
//
//  Created by typealias on 8/8/21.
//

import Foundation
import PathKit

extension Path {
  func followRecursively() throws -> Path {
    guard isSymlink else {
      return self
    }
    // POSIX should detect circular symlinks for us.
    return try symlinkDestination().followRecursively()
  }
}
