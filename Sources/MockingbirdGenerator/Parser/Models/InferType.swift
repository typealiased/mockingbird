//
//  InferType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

/// This type inference system is passable but still a bit lacking. We need to modify the type
/// system to parse enums, global functions, and structs in order to not make incorrect guesses for
/// more complex property assignment expressions.
func inferType(from string: String) -> String? {
  let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !string.hasPrefix("{") else { return nil } // Ignore closures.
  
  if (string.first == "\"" && string.last == "\"") || (string.first == "#" && string.last == "#") {
    return "String"
  } else if Bool(string) != nil {
    return "Bool"
  } else if Int(string) != nil {
    return "Int"
  } else if Double(string) != nil {
    return "Double"
  } else if let tuple = parseTuple(from: string) {
    return tuple
  } else if let collection = parseCollection(from: string) {
    return collection
  } else if let initializer = parseInitializer(from: string) {
    return initializer
  } else if let `enum` = parseEnum(from: string) {
    return `enum`
  }
  
  return nil
}

/// Recursively try to parse a tuple literal, e.g. `(true, 1)` => `(Bool, Int)`.
private func parseTuple(from string: String) -> String? {
  guard string.first == "(", string.last == ")" else { return nil }
  let string = String(string.dropFirst().dropLast())
  let elements = string.components(separatedBy: ",", excluding: .allGroups)
  
  var types = [String]()
  for element in elements {
    let elementComponents = element.components(separatedBy: ":", excluding: .allGroups)
    if elementComponents.count == 1 { // Only value.
      guard let type = inferType(from: String(element)) else { return nil }
      types.append(type)
    } else if elementComponents.count == 2 { // Named tuple.
      guard let type = inferType(from: String(elementComponents[1])) else { return nil }
      let name = elementComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
      if name == "_" {
        types.append(type)
      } else {
        types.append("\(name): \(type)")
      }
    } else {
      return nil
    }
  }
  
  return "(\(types.joined(separator: ", ")))"
}

/// Recursively try to parse a collection literal, e.g. `[true, false]` => `[Bool]`.
private func parseCollection(from string: String) -> String? {
  guard string.first == "[", string.last == "]" else { return nil }
  let string = String(string.dropFirst().dropLast())
  let items = string.components(separatedBy: ",", excluding: .allGroups)
  
  func coalescedType(from types: [String]) -> String? {
    let uniqueTypes = Set(types)
    guard uniqueTypes.count == 1, let type = uniqueTypes.first else { return nil }
    return type
  }
  
  if items[0].components(separatedBy: ":", excluding: .allGroups).count == 1 { // Array types.
    var itemsTypes = [String]()
    for item in items {
      guard let type = inferType(from: String(item)) else { return nil }
      itemsTypes.append(type)
    }
    guard let type = coalescedType(from: itemsTypes) else { return nil }
    return "[\(type)]"
  } else { // Dictionary types.
    var keyTypes = [String]()
    var valueTypes = [String]()
    for items in items {
      let keyAndValue = items.components(separatedBy: ":", excluding: .allGroups)
      guard keyAndValue.count == 2,
        let keyType = inferType(from: String(keyAndValue[0])),
        let valueType = inferType(from: String(keyAndValue[1]))
        else { return nil }
      keyTypes.append(keyType)
      valueTypes.append(valueType)
    }
    
    guard let keyType = coalescedType(from: keyTypes),
      let valueType = coalescedType(from: valueTypes)
      else { return nil }
    return "[\(keyType): \(valueType)]"
  }
}

/// Try to parse implicit and explicit type initialization, e.g. `MyType.init()` => `MyType`.
private func parseInitializer(from string: String) -> String? {
  let components = string.components(separatedBy: "(", excluding: .nonParenthesisGroups)
  let postIdentifierComponents = ("(" + components.dropFirst(1).joined(separator: "("))
    .components(separatedBy: ".", excluding: .allGroups)
  guard string.last == ")", postIdentifierComponents.count == 1, let identifier = components.first
    else { return nil }
  
  // Explicit initilization, must end in `.init`.
  if identifier.hasSuffix(".init") {
    return String(identifier.dropLast(5))
  }
  
  // Implicit initialization, all qualifiers must be capitalized.
  if identifier.components(separatedBy: ".", excluding: .allGroups).reduce(into: true, {
    (result, component) in
    result = result && component.first?.isUppercase ?? false
  }) {
    return String(identifier)
  }
  
  return nil
}

/// Try to parse qualified enums, e.g. `MyEnum.someCase(...)` => `MyEnum`.
private func parseEnum(from string: String) -> String? {
  // This can incorrectly infer uncapitalized qualified non-enum types e.g. `MyModule.fooClass`.
  let components = string.components(separatedBy: ".", excluding: .allGroups)
  guard components.count > 1, components.last?.first?.isLowercase ?? false else { return nil }
  
  // All components must be valid. This can incorrectly infer static methods and properties.
  var validCharacterSet = CharacterSet.alphanumerics
  validCharacterSet.insert("_")
  guard components.reduce(into: true, { (result, component) in
    result = result && component.rangeOfCharacter(from: validCharacterSet.inverted) == nil
  }) else { return nil }
  
  // All identifier components must be capitalized.
  let identifierComponents = components.dropLast()
  guard identifierComponents.reduce(into: true, { (result, component) in
    result = result && component.first?.isUppercase ?? false
  }) else { return nil }
  
  return identifierComponents.joined(separator: ".")
}
