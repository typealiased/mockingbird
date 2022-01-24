import Foundation
import PathKit

public extension Path {
  func followRecursively() throws -> Path {
    guard isSymlink else {
      return self
    }
    // POSIX should detect circular symlinks for us.
    return try symlinkDestination().followRecursively()
  }
}
