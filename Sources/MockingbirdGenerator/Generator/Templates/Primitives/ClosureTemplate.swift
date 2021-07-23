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
    let throwing = isThrowing ? " throws" : ""
    let type = "\(parenthetical: parameters.joined(separator: ", "))\(throwing) -> \(returnType)"
    return BlockTemplate(body: "\(type) in \(body)", multiline: false).render()
  }
}
