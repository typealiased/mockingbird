//
//  SwitchStatementTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/24/21.
//

import Foundation

struct SwitchStatementTemplate: Template {
  let controlExpression: String
  let cases: [(pattern: String, body: String)]
  
  init(controlExpression: String, cases: [(pattern: String, body: String)]) {
    self.controlExpression = controlExpression
    self.cases = cases
  }
  
  func render() -> String {
    let body = String(lines: cases.map({ (pattern, body) in
      return """
      case \(pattern):
      \(body.indent())
      """
    }))
    return "switch \(controlExpression) " + BlockTemplate(body: body,
                                                          multiline: true,
                                                          indented: false).render()
  }
}
