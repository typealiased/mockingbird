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
}
