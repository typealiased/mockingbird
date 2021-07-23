//
//  FunctionCallTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/21/21.
//

import Foundation

struct FunctionCallTemplate: Template {
  let name: String
  let arguments: [String]
  let isThrowing: Bool
  
  init(name: String, arguments: [(argumentLabel: String?, argument: String)], isThrowing: Bool = false) {
    self.name = name
    self.arguments = arguments.map({
      guard let argumentLabel = $0.argumentLabel else { return $0.argument }
      return argumentLabel + ": " + $0.argument
    })
    self.isThrowing = isThrowing
  }
  
  init(name: String, parameters: [MethodParameter] = [], isThrowing: Bool = false) {
    self.name = name
    self.arguments = parameters.map({ parameter -> String in
      guard let label = parameter.argumentLabel else { return parameter.name.backtickWrapped }
      return "\(label): \(parameter.name.backtickWrapped)"
    })
    self.isThrowing = isThrowing
  }
  
  func render() -> String {
    return (isThrowing ? "try " : "") + name + "(" + arguments.joined(separator: ", ") + ")"
  }
}
