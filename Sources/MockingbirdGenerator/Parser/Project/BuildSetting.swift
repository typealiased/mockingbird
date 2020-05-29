//
//  BuildSetting.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 5/25/20.
//

import Foundation

/// Super tiny recursive parser for Xcode build settings.
struct BuildSetting: CustomStringConvertible, CustomDebugStringConvertible {
  let components: [Component]
  
  var description: String { return components.map({ "\($0)" }).joined() }
  var debugDescription: String { return components.map({ String(reflecting: $0) }).joined() }
  
  enum Component: CustomDebugStringConvertible {
    case literal(Literal)
    case expression(Expression)
    
    var description: String {
      switch self {
      case .literal(let literal): return "\(literal)"
      case .expression(let expression): return "\(expression)"
      }
    }
    
    var debugDescription: String {
      switch self {
      case .literal(let literal): return "Literal(\(String(reflecting: literal)))"
      case .expression(let expression): return "Expression(\(String(reflecting: expression)))"
      }
    }
  }
  
  struct Literal: CustomStringConvertible, CustomDebugStringConvertible {
    let value: String
    var description: String { return value }
    var debugDescription: String { return value }
  }
  
  struct Expression: CustomStringConvertible, CustomDebugStringConvertible {
    enum Token {
      static let operatorDelimeter: Character = ":"
      static let operatorValueDelimiter: Character = "="
      
      static let expressionGroupStart: String = "$("
      static let expressionGroupEnd: Character = ")"
      
      static let expressionGroupStartBash: String = "${"
      static let expressionGroupEndBash: Character = "}"
    }
    
    let name: String
    let expressionOperator: Operator?
    
    var description: String {
      guard let expressionOperator = expressionOperator else { return name }
      return "\(name)\(Token.operatorDelimeter)\(expressionOperator)"
    }
    
    var debugDescription: String {
      guard let expressionOperator = expressionOperator else { return name }
      return "\(name)\(Token.operatorDelimeter)\(String(reflecting: expressionOperator))"
    }
    
    struct Operator: CustomStringConvertible, CustomDebugStringConvertible {
      let name: String
      let value: BuildSetting?
      
      var description: String {
        guard let value = value else { return name }
        return "\(name)\(Token.operatorValueDelimiter)\(value)"
      }
      
      var debugDescription: String {
        guard let value = value else { return name }
        return "\(name)\(Token.operatorValueDelimiter)\(String(reflecting: value))"
      }
      
      init(from value: Substring) {
        guard let valueIndex = value.firstIndex(of: Token.operatorValueDelimiter),
          valueIndex != value.endIndex else {
            self.name = String(value)
            self.value = nil
            return
        }
        self.name = String(value[..<valueIndex])
        self.value = BuildSetting(value[value.index(after: valueIndex)...])
      }
    }
    
    static func parse(from value: Substring) -> (Expression, Int)? {
      let findEndIndex: (Substring, String, Character) -> (Int, Int)? = {
        (value, start, end) in
        guard value.hasPrefix(start) else { return nil }
        let operatorIndex = value.firstIndex(of: Token.operatorDelimeter) ?? value.endIndex
        let endIndex = value.firstIndex(of: end) ?? value.endIndex
        
        if endIndex <= operatorIndex {
          guard let terminalIndex = value.firstIndex(of: end) else { return nil }
          return (start.count, terminalIndex.utf16Offset(in: value))
        } else { // Has an expression operator, e.g. `SETTING:default`.
          let offsetValue = value[operatorIndex...]
          guard let terminalIndex = offsetValue.firstIndex(of: end, excluding: .allGroups) else {
            return nil
          }
          let offset = operatorIndex.utf16Offset(in: value)
          return (start.count, offset+terminalIndex.utf16Offset(in: offsetValue))
        }
      }
      
      guard let (startOffset, endOffset) =
        findEndIndex(value, Token.expressionGroupStart, Token.expressionGroupEnd) ??
        findEndIndex(value, Token.expressionGroupStartBash, Token.expressionGroupEndBash)
        else { return nil }
      
      let startIndex = value.index(value.startIndex, offsetBy: startOffset)
      let endIndex = value.index(startIndex, offsetBy: endOffset-startOffset)
      let unwrappedValue = value[startIndex..<endIndex]
      
      let name: String
      let expressionOperator: Operator?
      if let operatorIndex = unwrappedValue.firstIndex(of: Token.operatorDelimeter) {
        name = String(unwrappedValue[..<operatorIndex])
        let operatorComponent = unwrappedValue[value.index(after: operatorIndex)..<endIndex]
        expressionOperator = Operator(from: operatorComponent)
      } else {
        name = String(unwrappedValue)
        expressionOperator = nil
      }
      
      return (Expression(name: name, expressionOperator: expressionOperator), endOffset+1)
    }
  }
  
  init(_ value: String) {
    self.init(value[...])
  }
  
  init(_ value: Substring) {
    var components = [Component]()
    var trailingIndex = value.startIndex
    var index = value.startIndex
    
    let popBuffer: () -> Void = {
      guard trailingIndex < index else { return }
      let buffer = String(value[trailingIndex..<index])
      components.append(.literal(Literal(value: buffer)))
    }
    
    while index < value.endIndex {
      if let (expression, offset) = Expression.parse(from: value[index...]) {
        popBuffer()
        components.append(.expression(expression))
        index = value.index(index, offsetBy: offset)
        trailingIndex = index
      } else {
        index = value.index(after: index)
      }
    }
    popBuffer()
    
    self.components = components
  }
}
