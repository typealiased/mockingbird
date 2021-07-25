//
//  ThunkTemplate.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/24/21.
//

import Foundation

class ThunkTemplate: Template {
  let mockableType: MockableType
  let invocation: String
  let shortSignature: String?
  let longSignature: String
  let returnTypeName: String
  let isThrowing: Bool
  let isStatic: Bool
  let callMember: (_ scope: Scope) -> String
  let invocationArguments: [(argumentLabel: String?, parameterName: String)]
  
  enum Scope: CustomStringConvertible {
    case superclass
    case object
    var description: String {
      switch self {
      case .superclass: return "super"
      case .object: return "mkbObject"
      }
    }
  }
  
  init(mockableType: MockableType,
       invocation: String,
       shortSignature: String?,
       longSignature: String,
       returnTypeName: String,
       isThrowing: Bool,
       isStatic: Bool,
       callMember: @escaping (_ scope: Scope) -> String,
       invocationArguments: [(argumentLabel: String?, parameterName: String)]) {
    self.mockableType = mockableType
    self.invocation = invocation
    self.shortSignature = shortSignature
    self.longSignature = longSignature
    self.returnTypeName = returnTypeName
    self.isThrowing = isThrowing
    self.isStatic = isStatic
    self.callMember = callMember
    self.invocationArguments = invocationArguments
  }
  
  func render() -> String {
    let unlabledArguments = invocationArguments.map({ $0.parameterName })
    let callDefault = IfStatementTemplate(
      condition: "let mkbImpl = mkbImpl as? \(longSignature)",
      body: """
      return \(FunctionCallTemplate(
                name: "mkbImpl",
                unlabeledArguments: unlabledArguments,
                isThrowing: isThrowing))
      """)
    let callConvenience: String = {
      guard let shortSignature = shortSignature else { return "" }
      return IfStatementTemplate(
        condition: "let mkbImpl = mkbImpl as? \(shortSignature)",
        body: "return \(FunctionCallTemplate(name: "mkbImpl", isThrowing: isThrowing))"
      ).render()
    }()
    let context = isStatic ? "self.staticMock.mockingbirdContext" : "self.mockingbirdContext"
    let supertype = isStatic ? "MockingbirdSupertype.Type" : "MockingbirdSupertype"
    let didInvoke = FunctionCallTemplate(name: "\(context).mocking.didInvoke",
                                         unlabeledArguments: [invocation],
                                         isThrowing: isThrowing)
    let isGeneric = !mockableType.genericTypes.isEmpty || mockableType.hasSelfConstraint
    
    return """
    return \(didInvoke) \(BlockTemplate(body: """
    \(FunctionCallTemplate(name: "\(context).recordInvocation", arguments: [(nil, "$0")]))
    let mkbImpl = \(FunctionCallTemplate(name: "\(context).stubbing.implementation",
                                         arguments: [("for", "$0")]))
    \(callDefault)
    \(callConvenience)
    \(ForInStatementTemplate(
        item: "(mkbIndex, mkbTarget)",
        collection: "\(context).proxy.targets.value.enumerated()",
        body: SwitchStatementTemplate(
          controlExpression: "mkbTarget",
          cases: [
            (".superclass", mockableType.kind != .class ? "break" :
              "return \(callMember(.superclass))"),
            (".object(let mkbObject)", mockableType.kind == .protocol && isGeneric ? "break" : """
            \(GuardStatementTemplate(
                condition: "var mkbObject = mkbObject as? \(supertype)", body: "continue"))
            let mkbValue: \(returnTypeName) = \(callMember(.object))
            \(FunctionCallTemplate(
                name: "\(context).proxy.updateTarget",
                arguments: [(nil, "&mkbObject"), ("at", "mkbIndex")]))
            return mkbValue
            """)
          ]).render()))
    \(IfStatementTemplate(
        condition: """
        let mkbValue = \(FunctionCallTemplate(
                          name: "\(context).stubbing.defaultValueProvider.value.provideValue",
                          arguments: [("for", "\(parenthetical: returnTypeName).self")]))
        """,
        body: "return mkbValue"))
    \(FunctionCallTemplate(name: "fatalError", unlabeledArguments: [
      FunctionCallTemplate(name: "\(context).stubbing.failTest",
                           arguments: [
                            ("for", "$0"),
                            ("at", "\(context).sourceLocation")]).render()
    ]))
    """))
    """
  }
}
