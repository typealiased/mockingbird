//
//  TestFileParser.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 6/7/20.
//

import Foundation
import SwiftSyntax

class TestFileParser: SyntaxVisitor {
  var mockedTypeNames = Set<String>()
  
  func parse<SyntaxType: SyntaxProtocol>(_ node: SyntaxType) -> Self {
    walk(node)
    return self
  }
  
  /// Handle function calls, e.g. `mock(SomeType.self)`
  override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
    guard
      node.argumentList.count == 1,
      let firstArgument = node.argumentList.first, firstArgument.label == nil,
      node.calledExpression.withoutTrivia().description == "mock"
      else { return .visitChildren }

    let expression = firstArgument.expression
    guard expression.lastToken?.withoutTrivia().description == "self" else { return .visitChildren }
    
    // Could be a fully or partially qualified type name.
    let typeName = String(expression.withoutTrivia().description.dropLast(5))
    mockedTypeNames.insert(typeName.removingGenericTyping())
    
    return .skipChildren
  }
}
