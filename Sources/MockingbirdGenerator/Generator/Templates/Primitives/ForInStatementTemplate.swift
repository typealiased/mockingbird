//
//  ForInStatementTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/24/21.
//

import Foundation

struct ForInStatementTemplate: Template {
  let item: String
  let collection: String
  let body: String
  let multiline: Bool
  
  init(item: String, collection: String, body: String, multiline: Bool = true) {
    self.item = item
    self.collection = collection
    self.body = body
    self.multiline = multiline
  }
  
  func render() -> String {
    return "for \(item) in \(collection) "
      + BlockTemplate(body: body, multiline: multiline).render()
  }
}
