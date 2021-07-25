//
//  ClosureTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/22/21.
//

import Foundation

struct ClosureTemplate: Template {
  let parameters: [String]
  let returnType: String
  let isThrowing: Bool
  let body: String
  
  init(parameters: [(argumentLabel: String, type: String)] = [],
       returnType: String = "Void",
       isThrowing: Bool = false,
       body: String) {
    self.parameters = parameters.map({ $0.argumentLabel + ": " + $0.type })
    self.returnType = returnType
    self.isThrowing = isThrowing
    self.body = body
  }
  
  func render() -> String {
    let modifiers = isThrowing ? " throws" : ""
    let signature = parameters.isEmpty && returnType == "Void" ? "" :
      "(\(separated: parameters))\(modifiers) -> \(returnType) in "
    return BlockTemplate(body: "\(signature)\(body)", multiline: false).render()
  }
}
