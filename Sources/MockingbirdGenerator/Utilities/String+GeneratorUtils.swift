//
//  String+GeneratorUtils.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

extension String {
  init(lines: [String], spacing: Int = 1, removeEmpty: Bool = true) {
    self = lines.filter({ !$0.isEmpty }).joined(separator: String(repeating: "\n", count: spacing))
  }
  
  func padded(count: Int) -> Self {
    return "\(padded: self, count: count)"
  }
}

extension String.StringInterpolation {
  mutating func appendInterpolation(singleQuoted str: String) {
    appendLiteral("'\(str)'")
  }
  
  mutating func appendInterpolation(doubleQuoted str: String) {
    appendLiteral("\"\(str)\"")
  }
  
  mutating func appendInterpolation(backticked str: String) {
    appendLiteral("`\(str)`")
  }
  
  mutating func appendInterpolation(parenthetical str: String) {
    appendLiteral("(\(str))")
  }
  
  mutating func appendInterpolation(padded str: String, count: Int = 0) {
    let padding = String(repeating: " ", count: count)
    appendLiteral(padding + str + padding)
  }
}
