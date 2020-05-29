//
//  SubstitutionStyle.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/15/20.
//

import Foundation

/// Variable substitution using parentheses or curly braces. Technically Make accepts Bash-style
/// variable substitution, but for simplicity Make is `$(VAR)` and Bash is `${VAR}`.
public enum SubstitutionStyle: CaseIterable {
  case make, bash
  
  public func wrap(_ variable: String) -> String {
    return prefix + variable + suffix
  }
  
  public static func unwrap(_ value: String) -> (variable: String, style: SubstitutionStyle)? {
    guard let style = SubstitutionStyle.allCases.first(where: {
      value.hasPrefix($0.prefix) && value.hasSuffix($0.suffix)
    }) else { return nil }
    return (String(value.dropFirst(style.prefix.count).dropLast(style.suffix.count)), style)
  }
  
  public var prefix: String {
    switch self {
    case .make: return "$("
    case .bash: return "${"
    }
  }
  
  public var suffix: String {
    switch self {
    case .make: return ")"
    case .bash: return "}"
    }
  }
}
