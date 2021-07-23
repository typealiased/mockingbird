//
//  BlockTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/23/21.
//

import Foundation

struct BlockTemplate: Template {
  let body: String
  let multiline: Bool
  
  init(body: String, multiline: Bool = true) {
    self.body = body
    self.multiline = multiline
  }
  
  func render() -> String {
    if multiline {
      return String(lines: [
        "{",
        body.indent(),
        "}"
      ])
    } else {
      return "{ " + body + " }"
    }
  }
}
