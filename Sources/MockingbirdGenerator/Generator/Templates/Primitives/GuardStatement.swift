//
//  GuardStatement.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/24/21.
//

import Foundation

struct GuardStatementTemplate: Template {
  let condition: String
  let body: String
  let multiline: Bool
  
  init(condition: String, body: String, multiline: Bool = false) {
    self.condition = condition
    self.body = body
    self.multiline = multiline
  }
  
  func render() -> String {
    return "guard \(condition) else " + BlockTemplate(body: body, multiline: multiline).render()
  }
}
