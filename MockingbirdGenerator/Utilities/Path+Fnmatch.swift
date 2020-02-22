//
//  Path+Fnmatch.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 9/11/19.
//

import PathKit
import Darwin

extension Path {
  /// Checks whether `pattern` matches the absolute path using POSIX fnmatch.
  ///
  /// - Parameters:
  ///   - pattern: A file name Bash-style glob pattern.
  ///   - isDirectory: Whether this path is a directory, if known at call time.
  /// - Returns: True if the path matches, false otherwise.
  func matches(pattern: String, isDirectory: Bool? = nil) -> Bool {
    // PathKit strips trailing slashes for normalized paths which can cause directory globs to fail.
    let rawPathString = "\(self)"
    let shouldAppendTrailingSlash = !rawPathString.hasSuffix("/")
      && pattern.hasSuffix("/") // Only apply trailing slash fix-it to directory globs.
      && (isDirectory ?? self.isDirectory)
    let pathString = rawPathString + (shouldAppendTrailingSlash ? "/" : "")
    return fnmatch(pattern, pathString, FNM_PATHNAME) != FNM_NOMATCH
  }
}
