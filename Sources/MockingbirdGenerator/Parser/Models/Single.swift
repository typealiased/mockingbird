//
//  Single.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 3/24/20.
//

import Foundation

indirect enum Single: CustomStringConvertible, CustomDebugStringConvertible, SerializableType {
  case nominal(components: [(typeName: String, genericTypes: [DeclaredType])])
  case list(element: DeclaredType)
  case map(key: DeclaredType, value: DeclaredType)
  case function(Function)
  
  var isFunction: Bool {
    switch self {
    case .function: return true
    default: return false
    }
  }
  
  var isCollection: Bool {
    switch self {
    case .list, .map: return true
    default: return false
    }
  }
  
  var genericTypes: [DeclaredType] {
    switch self {
    case .nominal(let components): return components.last?.genericTypes ?? []
    case .list, .map, .function: return []
    }
  }
  
  var description: String {
    switch self {
    case let .nominal(components):
      return components
        .map({ (typeName: String, genericTypes: [DeclaredType]) in
          guard !genericTypes.isEmpty else { return typeName }
          return "\(typeName)<\(genericTypes.map({ "\($0)" }).joined(separator: ", "))>"
        })
        .joined(separator: ".")
    case let .list(element):
      return "[\(element)]"
    case let .map(key, value):
      return "[\(key): \(value)]"
    case let .function(function):
      return "\(function)"
    }
  }
  
  var debugDescription: String {
    var description: String {
      switch self {
      case let .nominal(components):
        return components
          .map({ (typeName: String, genericTypes: [DeclaredType]) in
            guard !genericTypes.isEmpty else { return typeName }
            let reflectedGenericTypes = genericTypes.map({ String(reflecting: $0) })
            return "\(typeName)<\(reflectedGenericTypes.joined(separator: ", "))>"
          })
          .joined(separator: ".")
      case let .list(element):
        return "[\(String(reflecting: element))]"
      case let .map(key, value):
        return "[\(String(reflecting: key)): \(String(reflecting: value))]"
      case let .function(function):
        return String(reflecting: function)
      }
    }
    return "Single(\(description))"
  }
  
  func serialize(with request: SerializationRequest) -> String {
    switch self {
    case .nominal:
      return request.serialize(self.description)
    case let .list(element):
      return "[\(element.serialize(with: request))]"
    case let .map(key, value):
      return "[\(key.serialize(with: request)): \(value.serialize(with: request))]"
    case let .function(function):
      return function.serialize(with: request)
    }
  }
}

extension Single {
  init(from serialized: Substring, ignoreCache: Bool = false) {
    // Handle collection types.
    if serialized.hasPrefix("[") && serialized.hasSuffix("]") {
      let flattened = serialized.dropFirst().dropLast()
      guard let keyIndex = flattened.firstIndex(of: ":", excluding: .allGroups) else {
        // Array type.
        self = .list(element: DeclaredType(from: flattened, ignoreCache: ignoreCache))
        return
      }
      
      // Map type.
      let keyTypeName = flattened[..<keyIndex].trimmingCharacters(in: .whitespacesAndNewlines)
      let valueTypeName = flattened[flattened.index(after: keyIndex)...]
        .trimmingCharacters(in: .whitespacesAndNewlines)
      self = .map(key: DeclaredType(from: keyTypeName[...], ignoreCache: ignoreCache),
                  value: DeclaredType(from: valueTypeName[...], ignoreCache: ignoreCache))
      return
    }
    
    // Handle functions.
    if let function = Function(from: serialized) {
      self = .function(function)
      return
    }
    
    // Handle nominal types which could be nested/qualified.
    let components = serialized
      .components(separatedBy: ".", excluding: .allGroups)
      .map({ component -> (typeName: String, genericTypes: [DeclaredType]) in
        guard
          let genericsStartIndex = component.firstIndex(of: "<", excluding: .allGroups),
          let genericsEndIndex = component[component.index(after: genericsStartIndex)...]
            .firstIndex(of: ">", excluding: .allGroups)
          else {
            return (typeName: String(component), genericTypes: [])
        }
        
        let baseTypeName = component[..<genericsStartIndex]
        let genericsRange = component.index(after: genericsStartIndex)..<genericsEndIndex
        let genericTypes = component[genericsRange]
          .components(separatedBy: ",", excluding: .allGroups)
          .map({ DeclaredType(from: $0, ignoreCache: ignoreCache) })
        return (typeName: String(baseTypeName), genericTypes: genericTypes)
      })
    self = .nominal(components: components)
  }
}
