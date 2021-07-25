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
       arguments: [(argumentLabel: String?, argument: String)] = []) {
    self.name = name
    self.genericTypes = genericTypes
    self.arguments = arguments.map({ (argumentLabel, argument) in
      guard let label = argumentLabel else { return argument }
      return label + ": " + argument
    })
  }
  
  func render() -> String {
    let genericTypesString = genericTypes.isEmpty ? "" : "<\(separated: genericTypes)>"
    return "\(name)\(genericTypesString)(\(separated: arguments))"
  }
}
