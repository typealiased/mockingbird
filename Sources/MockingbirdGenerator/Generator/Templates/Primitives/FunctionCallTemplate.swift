import Foundation

struct FunctionCallTemplate: Template {
  let name: String
  let arguments: [String]
  let isAsync: Bool
  let isThrowing: Bool
  
  init(name: String,
       arguments: [(argumentLabel: String?, parameterName: String)],
       isAsync: Bool = false,
       isThrowing: Bool = false) {
    self.name = name
    self.arguments = arguments.map({
      guard let argumentLabel = $0.argumentLabel else { return $0.parameterName }
      return "\(argumentLabel): \($0.parameterName)"
    })
    self.isAsync = isAsync
    self.isThrowing = isThrowing
  }
  
  init(name: String, unlabeledArguments: [String] = [], isAsync: Bool = false, isThrowing: Bool = false) {
    self.name = name
    self.arguments = unlabeledArguments
    self.isAsync = isAsync
    self.isThrowing = isThrowing
  }
  
  init(name: String, parameters: [MethodParameter], isAsync: Bool = false, isThrowing: Bool = false) {
    self.name = name
    self.arguments = parameters.map({ parameter -> String in
      guard let label = parameter.argumentLabel else { return parameter.name.backtickWrapped }
      return "\(label): \(backticked: parameter.name)"
    })
    self.isAsync = isAsync
    self.isThrowing = isThrowing
  }
  
  func render() -> String {
    return "\(isThrowing ? "try " : "")\(isAsync ? "await " : "")\(name)(\(separated: arguments))"
  }
}
