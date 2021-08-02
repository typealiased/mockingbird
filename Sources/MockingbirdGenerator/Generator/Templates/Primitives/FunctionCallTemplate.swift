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
  
  init(name: String,
       arguments: [(argumentLabel: String?, parameterName: String)],
       isThrowing: Bool = false) {
    self.name = name
    self.arguments = arguments.map({
      guard let argumentLabel = $0.argumentLabel else { return $0.parameterName }
      return "\(argumentLabel): \($0.parameterName)"
    })
    self.isThrowing = isThrowing
  }
  
  init(name: String, unlabeledArguments: [String] = [], isThrowing: Bool = false) {
    self.name = name
    self.arguments = unlabeledArguments
    self.isThrowing = isThrowing
  }
  
  init(name: String, parameters: [MethodParameter], isThrowing: Bool = false) {
    self.name = name
    self.arguments = parameters.map({ parameter -> String in
      guard let label = parameter.argumentLabel else { return parameter.name.backtickWrapped }
      return "\(label): \(backticked: parameter.name)"
    })
    self.isThrowing = isThrowing
  }
  
  func render() -> String {
    return "\(isThrowing ? "try " : "")\(name)(\(separated: arguments))"
  }
}
