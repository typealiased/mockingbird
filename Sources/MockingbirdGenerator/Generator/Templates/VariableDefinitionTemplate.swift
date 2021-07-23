//
//  VariableDefinitionTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

struct VariableDefinitionTemplate: Template {
  let attributes: [String]
  let declaration: String
  let body: String
  
  init(attributes: [String] = [],
       declaration: String,
       body: String) {
    self.attributes = attributes
    self.declaration = declaration
    self.body = body
  }
  
  func render() -> String {
    return String(lines: [
      attributes.filter({ !$0.isEmpty }).joined(separator: " "),
      declaration + " {",
      body.indent(),
      "}"
    ])
  }
}
