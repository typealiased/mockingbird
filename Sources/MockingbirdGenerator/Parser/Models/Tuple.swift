//
//  Tuple.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 3/24/20.
//

import Foundation

struct Tuple: CustomStringConvertible, CustomDebugStringConvertible, SerializableType {
  let elements: [(label: String, type: DeclaredType)] // Label => Type
  
  var description: String {
    let serializedElements = elements.map({ element -> String in
      guard !element.label.hasPrefix(".") else {
        return "\(element.type)"
      }
      return "\(element.label): \(element.type)"
    }).joined(separator: ", ")
    return "(\(serializedElements))"
  }
  
  var debugDescription: String {
    var description: String {
      let serializedElements = elements.map({ element -> String in
        guard !element.label.hasPrefix(".") else {
          return String(reflecting: element.type)
        }
        return "\(element.label): \(String(reflecting: element.type))"
      }).joined(separator: ", ")
      return "(\(serializedElements))"
    }
    return "Tuple(\(description))"
  }
  
  func serialize(with request: SerializationRequest) -> String {
    let serializedElements = elements.map({ element -> String in
      guard !element.label.hasPrefix(".") else {
        return "\(element.type.serialize(with: request))"
      }
      return "\(element.label): \(element.type.serialize(with: request))"
    }).joined(separator: ", ")
    return "(\(serializedElements))"
  }
  
  init?(from serialized: String) {
    self.init(from: serialized[...])
  }
  
  init?(from serialized: Substring) {
    guard serialized.hasPrefix("("), serialized.hasSuffix(")"),
      !serialized.contains("->", excluding: .allGroups) else { return nil }
    let unwrapped = serialized.dropFirst().dropLast()
    guard !unwrapped.isEmpty else { // Handle empty tuples.
      self.elements = []
      return
    }
    let components = unwrapped.components(separatedBy: ",", excluding: .allGroups)
    var labeledElements = [(label: String, type: DeclaredType)]()
    for (i, component) in components.enumerated() {
      let label: String
      let declaration: Substring
      if component.contains(":", excluding: .allGroups),
        let labelIndex = component.firstIndex(of: ":", excluding: .allGroups) {
        label = component[..<labelIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        declaration = component[component.index(after: labelIndex)...]
      } else {
        label = ".\(i)"
        declaration = component
      }
      labeledElements.append((label: label, type: DeclaredType(from: declaration)))
    }
    
    // Check if this is a parenthesized expression instead of a tuple.
    guard labeledElements.count != 1 else { return nil }
    self.elements = labeledElements
  }
}
