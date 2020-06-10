//
//  SourceLocation.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 5/31/20.
//

import Foundation

/// References a line of code in a file.
public struct SourceLocation {
  let file: StaticString
  let line: UInt
  init(_ file: StaticString, _ line: UInt) {
    self.file = file
    self.line = line
  }
}
