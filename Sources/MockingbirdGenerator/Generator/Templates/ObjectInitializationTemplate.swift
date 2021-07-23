//
//  ObjectInitializationTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

struct ObjectInitializationTemplate: Template {
  let name: String
  let genericTypes: [String]
  let arguments: [String]
  
  init(name: String,
       genericTypes: [String] = [],
       arguments: [(parameter: String, argument: String)]) {
    self.name = name
    self.genericTypes = genericTypes
    self.arguments = arguments.map({ $0.parameter + ": " + $0.argument })
  }
  
  func render() -> String {
    let genericTypesString = genericTypes.isEmpty ? "" :
      ("<" + genericTypes.joined(separator: ", ") + ">")
    return name + genericTypesString + "(" + arguments.joined(separator: ", ") + ")"
  }
}
