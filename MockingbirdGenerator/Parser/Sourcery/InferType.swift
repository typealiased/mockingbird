//
//  InferType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

func inferType(from string: String) -> String? {
  let string = string.trimmingCharacters(in: .whitespaces)
  // probably lazy property or default value with closure,
  // we expect explicit type, as we don't know return type
  guard !(string.hasPrefix("{") && string.hasSuffix(")")) else { return nil }
  
  var inferredType: String
  if string == "nil" {
    return "Optional"
  } else if string.first == "\"" {
    return "String"
  } else if Bool(string) != nil {
    return "Bool"
  } else if Int(string) != nil {
    return "Int"
  } else if Double(string) != nil {
    return "Double"
  } else if string.isValidTupleName() {
    //tuple
    let string = string.dropFirstAndLast()
    let elements = string.commaSeparated()
    
    var types = [String]()
    for element in elements {
      let nameAndValue = element.colonSeparated()
      if nameAndValue.count == 1 {
        guard let type = inferType(from: element) else { return nil }
        types.append(type)
      } else {
        guard let type = inferType(from: nameAndValue[1]) else { return nil }
        let name = nameAndValue[0].replacingOccurrences(of: "_", with: "").trimmingCharacters(in: .whitespaces)
        if name.isEmpty {
          types.append(type)
        } else {
          types.append("\(name): \(type)")
        }
      }
    }
    
    return "(\(types.joined(separator: ", ")))"
  } else if string.first == "[", string.last == "]" {
    //collection
    let string = string.dropFirstAndLast()
    let items = string.commaSeparated()
    
    func genericType(from itemsTypes: [String]) -> String {
      let genericType: String
      var uniqueTypes = Set(itemsTypes)
      if uniqueTypes.count == 1, let type = uniqueTypes.first {
        genericType = type
      } else if uniqueTypes.count == 2,
        uniqueTypes.remove("Optional") != nil,
        let type = uniqueTypes.first {
        genericType = "\(type)?"
      } else {
        genericType = "Any"
      }
      return genericType
    }
    
    if items[0].colonSeparated().count == 1 {
      var itemsTypes = [String]()
      for item in items {
        guard let type = inferType(from: item) else { return nil }
        itemsTypes.append(type)
      }
      return "[\(genericType(from: itemsTypes))]"
    } else {
      var keysTypes = [String]()
      var valuesTypes = [String]()
      for items in items {
        let keyAndValue = items.colonSeparated()
        guard keyAndValue.count == 2,
          let keyType = inferType(from: keyAndValue[0]),
          let valueType = inferType(from: keyAndValue[1])
          else { return nil }
        
        keysTypes.append(keyType)
        valuesTypes.append(valueType)
      }
      return "[\(genericType(from: keysTypes)): \(genericType(from: valuesTypes))]"
    }
  } else if let initializer = string.range(of: ".init(") {
    //initializer with `init`
    inferredType = String(string[string.startIndex..<initializer.lowerBound])
    return inferredType
  } else {
    // Enums, i.e. `Optional.some(...)` or `Optional.none` should be inferred to `Optional`
    // Contained types, i.e. `Foo.Bar()` should be inferred to `Foo.Bar`
    // But rarely enum cases can also start with capital letters, so we still may wrongly infer them as a type
    func possibleEnumType(_ string: String) -> String? {
      let components = string.components(separatedBy: ".", excludingDelimiterBetween: ("<[(", ")]>"))
      if components.count > 1, let lastComponentFirstLetter = components.last?.first.map(String.init) {
        if lastComponentFirstLetter.lowercased() == lastComponentFirstLetter {
          return components.dropLast().joined(separator: ".")
        }
      }
      return nil
    }
    
    // get everything before `(`
    let components = string.components(separatedBy: "(", excludingDelimiterBetween: ("<[(", ")]>"))
    if components.count > 1 {
      //initializer without `init`
      inferredType = components[0]
      return possibleEnumType(inferredType) ?? inferredType
    } else {
      return possibleEnumType(string)
    }
  }
}
