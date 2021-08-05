//
//  FunctionDefinitionTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

struct FunctionDefinitionTemplate: Template {
  let attributes: [String]
  let declaration: String
  let genericConstraints: [String]
  let body: String
  
  init(attributes: [String] = [],
       declaration: String,
       genericConstraints: [String] = [],
       body: String) {
    self.attributes = attributes
    self.declaration = declaration
    self.genericConstraints = genericConstraints
    self.body = body
  }

  func render() -> String {
    let genericConstraintsString = genericConstraints.isEmpty ? "" :
      " where \(separated: genericConstraints)"
    return String(lines: [
      attributes.filter({ !$0.isEmpty }).joined(separator: " "),
      declaration + genericConstraintsString + " " + BlockTemplate(body: body).render()
    ])
  }
}
