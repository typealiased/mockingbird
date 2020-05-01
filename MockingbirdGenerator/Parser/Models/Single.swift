//
//  Single.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 3/24/20.
//

import Foundation

indirect enum Single: CustomStringConvertible, CustomDebugStringConvertible, SerializableType {
  case generic(
    typeName: String,
    qualification: String,
    genericTypes: [DeclaredType]
  )
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
    case .generic(_, _, let genericTypes): return genericTypes
    case .list, .map, .function: return []
    }
  }
  
  var description: String {
    switch self {
    case let .generic(typeName, qualification, genericTypes):
      let qualificationPrefix = qualification + (qualification.isEmpty ? "" : ".")
      guard !genericTypes.isEmpty else { return "\(qualificationPrefix)\(typeName)" }
      return "\(qualificationPrefix)\(typeName)<\(genericTypes.map({ "\($0)" }).joined(separator: ", "))>"
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
      case let .generic(typeName, qualification, genericTypes):
        let qualificationPrefix = qualification + (qualification.isEmpty ? "" : ".")
        guard !genericTypes.isEmpty else { return "\(qualificationPrefix)\(typeName)" }
        return "\(qualificationPrefix)\(typeName)<\(genericTypes.map({ String(reflecting: $0) }).joined(separator: ", "))>"
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
    case let .generic(typeName, qualification, genericTypes):
      let qualificationPrefix = qualification + (qualification.isEmpty ? "" : ".")
      guard !genericTypes.isEmpty else { return "\(request.serialize(qualificationPrefix + typeName))" }
      return "\(request.serialize(qualificationPrefix + typeName))<\(genericTypes.map({ $0.serialize(with: request) }).joined(separator: ", "))>"
    case let .list(element):
      return "[\(element.serialize(with: request))]"
    case let .map(key, value):
      return "[\(key.serialize(with: request)): \(value.serialize(with: request))]"
    case let .function(function):
      return "\(function.serialize(with: request))"
    }
  }
}

extension Single {
  init(from serialized: Substring, ignoreCache: Bool = false) {
    guard serialized.hasPrefix("["), serialized.hasSuffix("]") else {
      // Handle type qualifications.
      let components = serialized.components(separatedBy: ".", excluding: .allGroups)
      let qualification = components[..<(components.count-1)].joined(separator: ".")
      let baseType = components.last ?? ""
      
      guard let genericTypesStartIndex = baseType.firstIndex(of: "<", excluding: .allGroups),
        let genericTypesEndIndex = baseType[baseType.index(after: genericTypesStartIndex)...]
          .firstIndex(of: ">", excluding: .allGroups)
        else {
          if let function = Function(from: serialized) {
            self = .function(function)
          } else {
            self = .generic(typeName: String(baseType),
                            qualification: qualification,
                            genericTypes: [])
          }
          return
      }
      
      // Handle types with generic specializations.
      let despecializedTypeName = baseType[..<genericTypesStartIndex]
      let genericTypesRange = baseType.index(after: genericTypesStartIndex)..<genericTypesEndIndex
      let genericTypes = baseType[genericTypesRange]
        .components(separatedBy: ",", excluding: .allGroups)
        .map({ DeclaredType(from: $0, ignoreCache: ignoreCache) })
      self = .generic(typeName: String(despecializedTypeName),
                      qualification: qualification,
                      genericTypes: genericTypes)
      return
    }
    
    // Handle collection types.
    let flattened = serialized.dropFirst().dropLast()
    if let keyIndex = flattened.firstIndex(of: ":", excluding: .allGroups) { // Map type.
      let keyTypeName = flattened[..<keyIndex].trimmingCharacters(in: .whitespacesAndNewlines)
      let valueTypeName = flattened[flattened.index(after: keyIndex)...]
        .trimmingCharacters(in: .whitespacesAndNewlines)
      self = .map(key: DeclaredType(from: keyTypeName[...], ignoreCache: ignoreCache),
                  value: DeclaredType(from: valueTypeName[...], ignoreCache: ignoreCache))
    } else {
      self = .list(element: DeclaredType(from: flattened, ignoreCache: ignoreCache))
    }
  }
}
