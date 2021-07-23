//
//  NominalTypeDefinitionTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/23/21.
//

import Foundation

struct NominalTypeDefinitionTemplate: Template {
  let declaration: String
  let genericTypes: [String]
  let genericConstraints: [String]
  let inheritedTypes: [String]
  let body: String
  
  init(declaration: String,
       genericTypes: [String] = [],
       genericConstraints: [String] = [],
       inheritedTypes: [String] = [],
       body: String) {
    self.declaration = declaration
    self.genericTypes = genericTypes
    self.genericConstraints = genericConstraints
    self.inheritedTypes = inheritedTypes
    self.body = body
  }
  
  func render() -> String {
    let genericTypesString = genericTypes.isEmpty ? "" :
      ("<" + genericTypes.joined(separator: ", ") + ">")
    let genericConstraintsString = genericConstraints.isEmpty ? "" :
      (" where " + genericConstraints.joined(separator: ", ") )
    let inheritedTypesString = inheritedTypes.joined(separator: ", ")
    return declaration + genericTypesString
      + (!inheritedTypes.isEmpty ? ": " : "")
      + inheritedTypesString + genericConstraintsString + " "
      + BlockTemplate(body: body).render()
  }
}
