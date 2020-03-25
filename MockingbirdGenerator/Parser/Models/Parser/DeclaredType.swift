//
//  DeclaredType.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/1/19.
//

import Foundation

/// Recursively parses type declarations.
enum DeclaredType: CustomStringConvertible, CustomDebugStringConvertible, SerializableType {
  case single(Single, optionals: String)
  case tuple(Tuple, optionals: String)
  
  var isFunction: Bool {
    switch self {
    case let .single(single, _): return single.isFunction
    case .tuple: return false
    }
  }
  
  var isCollection: Bool {
    switch self {
    case let .single(single, _): return single.isCollection
    case .tuple: return false
    }
  }
  
  var isTuple: Bool {
    switch self {
    case .single: return false
    case .tuple: return true
    }
  }
  
  var isOptional: Bool {
    switch self {
    case .single(_, let optionals), .tuple(_, let optionals): return !optionals.isEmpty
    }
  }
  
  var description: String {
    switch self {
    case let .single(single, optionals):
      if isOptional && isFunction {
        return "(\(single))\(optionals)"
      } else {
        return "\(single)\(optionals)"
      }
    case let .tuple(tuple, optionals): return "\(tuple)\(optionals)"
    }
  }
  
  var debugDescription: String {
    var description: String {
      switch self {
      case let .single(single, optionals):
        if isOptional && isFunction {
          return "(\(String(reflecting: single)))\(optionals)"
        } else {
          return "\(String(reflecting: single))\(optionals)"
        }
      case let .tuple(tuple, optionals): return "\(String(reflecting: tuple))\(optionals)"
      }
    }
    return "DeclaredType(\(description))"
  }
  
  func serialize(with request: SerializationRequest) -> String {
    let processOptionals: (String) -> String = { optionals in
      guard request.options.contains(.shouldExcludeImplicitlyUnwrappedOptionals),
        optionals.hasSuffix("!") else { return optionals }
      return String(optionals.dropLast()) // Not possible to implicitly unwrap multiple times.
    }
    switch self {
    case let .single(single, optionals):
      if isOptional && isFunction {
        return "(" + single.serialize(with: request) + ")" + processOptionals(optionals)
      } else  {
        return single.serialize(with: request) + processOptionals(optionals)
      }
    case let .tuple(tuple, optionals):
      return tuple.serialize(with: request) + processOptionals(optionals)
    }
  }
}

extension DeclaredType {
  init(from serialized: String, ignoreCache: Bool = false) {
    self.init(from: serialized[...], ignoreCache: ignoreCache)
  }
  
  init(from serialized: Substring, ignoreCache: Bool = false) {
    if !ignoreCache, let primitive = Primitives.map[serialized] {
      self = primitive
      return
    }
    
    let trimmed = serialized.trimmingCharacters(in: .whitespacesAndNewlines)[...]
    // Handle optionals (which can be wrapped multiple times).
    let firstOptionalIndex: String.Index
    if trimmed.contains("->", excluding: .allGroups) {
      firstOptionalIndex = trimmed.endIndex
    } else {
      firstOptionalIndex = trimmed.firstIndex(of: "?", excluding: .allGroups)
        ?? trimmed.firstIndex(of: "!", excluding: .allGroups)
        ?? trimmed.endIndex
    }
    var optionals = String(trimmed[firstOptionalIndex...])
    var unwrappedType = trimmed[..<firstOptionalIndex]
    guard let tuple = Tuple(from: unwrappedType) else {
      while unwrappedType.hasPrefix("(")
        && unwrappedType.hasSuffix(")")
        && !unwrappedType.contains("->", excluding: .allGroups) {
          unwrappedType = unwrappedType.dropFirst().dropLast()
          guard !unwrappedType.contains("->", excluding: .allGroups) else { break }
          
          // Coalesce unwrapped optionals.
          let firstOptionalIndex = unwrappedType.firstIndex(of: "?", excluding: .allGroups)
            ?? unwrappedType.firstIndex(of: "!", excluding: .allGroups)
            ?? unwrappedType.endIndex
          optionals = String(unwrappedType[firstOptionalIndex...]) + optionals
          unwrappedType = unwrappedType[..<firstOptionalIndex]
      }
      self = .single(Single(from: unwrappedType, ignoreCache: ignoreCache), optionals: optionals)
      return
    }
    self = .tuple(tuple, optionals: optionals)
  }
}
