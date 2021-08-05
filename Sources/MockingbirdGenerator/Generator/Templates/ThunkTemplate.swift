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
  let returnType: String
  let isBridged: Bool
  let isThrowing: Bool
  let isStatic: Bool
  let callMember: (_ scope: Scope) -> String
  let invocationArguments: [(argumentLabel: String?, parameterName: String)]
  
  enum Scope: CustomStringConvertible {
    case `super`
    case object
    var description: String {
      switch self {
      case .super: return "super"
      case .object: return "mkbObject"
      }
    }
  }
  
  init(mockableType: MockableType,
       invocation: String,
       shortSignature: String?,
       longSignature: String,
       returnType: String,
       isBridged: Bool,
       isThrowing: Bool,
       isStatic: Bool,
       callMember: @escaping (_ scope: Scope) -> String,
       invocationArguments: [(argumentLabel: String?, parameterName: String)]) {
    self.mockableType = mockableType
    self.invocation = invocation
    self.shortSignature = shortSignature
    self.longSignature = longSignature
    self.returnType = returnType
    self.isBridged = isBridged
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
      return \(FunctionCallTemplate(name: "mkbImpl",
                                    unlabeledArguments: unlabledArguments,
                                    isThrowing: isThrowing))
      """)
    let callConvenience: String = {
      guard let shortSignature = shortSignature else { return "" }
      return IfStatementTemplate(
        condition: "let mkbImpl = mkbImpl as? \(shortSignature)",
        body: """
        return \(FunctionCallTemplate(name: "mkbImpl", isThrowing: isThrowing))
        """).render()
    }()
    
    let callBridgedDefault: String = {
      guard isBridged else { return "" }
      let bridgedSignature = """
      (\(String(list: Array(repeating: "Any?", count: unlabledArguments.count)))) -> Any?
      """
      return IfStatementTemplate(
        condition: "let mkbImpl = mkbImpl as? \(bridgedSignature)",
        body: """
        return \(FunctionCallTemplate(
                  name: "Mockingbird.dynamicCast",
                  unlabeledArguments: [
                    FunctionCallTemplate(
                      name: "mkbImpl",
                      unlabeledArguments: unlabledArguments,
                      isThrowing: isThrowing).render()
                  ])) as \(returnType)
        """).render()
    }()
    let callBridgedConvenience: String = {
      guard isBridged else { return "" }
      return IfStatementTemplate(
        condition: "let mkbImpl = mkbImpl as? () -> Any?",
        body: """
        return \(FunctionCallTemplate(
                  name: "Mockingbird.dynamicCast",
                  unlabeledArguments: [
                    FunctionCallTemplate(name: "mkbImpl", isThrowing: isThrowing).render()
                  ])) as \(returnType)
        """).render()
    }()
    
    let context = isStatic ? "self.staticMock.mockingbirdContext" : "self.mockingbirdContext"
    let supertype = isStatic ? "MockingbirdSupertype.Type" : "MockingbirdSupertype"
    let didInvoke = FunctionCallTemplate(name: "\(context).mocking.didInvoke",
                                         unlabeledArguments: [invocation],
                                         isThrowing: isThrowing)
    
    let isSubclass = mockableType.kind != .class
    
    // TODO: Handle generic protocols
    let isGeneric = !mockableType.genericTypes.isEmpty || mockableType.hasSelfConstraint
    let isProxyable = !(mockableType.kind == .protocol && isGeneric)
    
    return """
    return \(didInvoke) \(BlockTemplate(body: """
    \(FunctionCallTemplate(name: "\(context).recordInvocation", arguments: [(nil, "$0")]))
    let mkbImpl = \(FunctionCallTemplate(name: "\(context).stubbing.implementation",
                                         arguments: [("for", "$0")]))
    \(String(lines: [
      callDefault.render(),
      callConvenience,
      callBridgedDefault,
      callBridgedConvenience,
      !isSubclass && !isProxyable ? "" : ForInStatementTemplate(
        item: "mkbTargetBox",
        collection: "\(context).proxy.targets(for: $0)",
        body: SwitchStatementTemplate(
          controlExpression: "mkbTargetBox.target",
          cases: [
            (".super", isSubclass ? "break" : "return \(callMember(.super))"),
            (".object" + (isProxyable ? "(let mkbObject)" : ""), !isProxyable ? "break" : """
            \(GuardStatementTemplate(
                condition: "var mkbObject = mkbObject as? \(supertype)", body: "break"))
            let mkbValue: \(returnType) = \(callMember(.object))
            \(FunctionCallTemplate(
                name: "\(context).proxy.updateTarget",
                arguments: [(nil, "&mkbObject"), ("in", "mkbTargetBox")]))
            return mkbValue
            """)
          ]).render()).render(),
    ]))
    \(IfStatementTemplate(
        condition: """
        let mkbValue = \(FunctionCallTemplate(
                          name: "\(context).stubbing.defaultValueProvider.value.provideValue",
                          arguments: [("for", "\(parenthetical: returnType).self")]))
        """,
        body: "return mkbValue"))
    \(FunctionCallTemplate(name: "\(context).stubbing.failTest",
                           arguments: [
                            ("for", "$0"),
                            ("at", "\(context).sourceLocation")]).render())
    """))
    """
  }
}
