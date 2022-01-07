//
//  String+GeneratorUtils.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

extension String {
  init(lines: [String], spacing: Int = 1, keepEmptyLines: Bool = false) {
    self = (keepEmptyLines ? lines : lines.filter({ !$0.isEmpty }))
      .joined(separator: String(repeating: "\n", count: spacing))
  }
  
  init(list values: [String], separator: String = ", ") {
    self = values.joined(separator: separator)
  }
  
  func justified(columns: Int, separatedBy delimiter: Character = " ") -> [String] {
    let tokens = substringComponents(separatedBy: delimiter)
    return tokens.reduce(into: []) { lines, token in
      guard let line = lines.last, line.count + token.count + 1 <= columns else {
        lines.append(String(token))
        return
      }
      lines[lines.count-1] = line + String(delimiter) + token
    }
  }
}
