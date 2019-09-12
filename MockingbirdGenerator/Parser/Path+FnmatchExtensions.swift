//
//  Path+FnmatchExtensions.swift
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
    // PathKit strips trailing slashes when normalizing which causes directory globs to fail.
    let isDirectory = isDirectory ?? self.isDirectory
    
    guard let rawPattern = pattern.data(using: .utf8, allowLossyConversion: false)?.withUnsafeBytes({
      return $0.bindMemory(to: Int8.self).baseAddress
    }), let rawPathString = "\(self)\(isDirectory ? "/" : "")".data(using: .utf8, allowLossyConversion: false)?.withUnsafeBytes({
      return $0.bindMemory(to: Int8.self).baseAddress
    }) else { return false }
    
    return fnmatch(rawPattern, rawPathString, 0) == 0
  }
}
