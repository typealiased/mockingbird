//
//  PropertyDefinitionTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

struct PropertyDefinitionTemplate: Template {
  enum AccessorType {
    case getter, setter
    var keyword: String {
      switch self {
      case .getter: return "get"
      case .setter: return "set"
      }
    }
  }
  
  let type: AccessorType
  let body: String
  
  init(type: AccessorType, body: String) {
    self.type = type
    self.body = body
  }
  
  func render() -> String {
    return type.keyword + " " + BlockTemplate(body: body).render()
  }
}
