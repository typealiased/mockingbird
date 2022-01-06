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
