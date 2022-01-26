import Foundation

struct ClosureTemplate: Template {
  let parameters: [String]
  let returnType: String
  let isAsync: Bool
  let isThrowing: Bool
  let body: String
  
  init(parameters: [(argumentLabel: String, type: String)] = [],
       returnType: String = "Void",
       isAsync: Bool = false,
       isThrowing: Bool = false,
       body: String) {
    self.parameters = parameters.map({ $0.argumentLabel + ": " + $0.type })
    self.returnType = returnType
    self.isAsync = isAsync
    self.isThrowing = isThrowing
    self.body = body
  }
  
  func render() -> String {
    var modifiers = isAsync ? " async" : ""
    modifiers += isThrowing ? " throws" : ""
    let signature = parameters.isEmpty && returnType == "Void" ? "" :
      "(\(separated: parameters))\(modifiers) -> \(returnType) in "
    return BlockTemplate(body: "\(signature)\(body)", multiline: false).render()
  }
}
