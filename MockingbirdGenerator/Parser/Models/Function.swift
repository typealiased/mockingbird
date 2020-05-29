//
//  Function.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 5/24/20.
//

import Foundation

struct Function: CustomStringConvertible, CustomDebugStringConvertible, SerializableType {
  struct Parameter: CustomStringConvertible, CustomDebugStringConvertible, SerializableType {
    let label: String? // Includes the argument label `_`
    let type: DeclaredType
    let defaultValue: String?
    let attributes: Attributes
    
    var description: String {
      var components = [String]()
      if attributes.contains(.escaping) { components.append("@escaping") }
      if attributes.contains(.autoclosure) { components.append("@autoclosure") }
      if attributes.contains(.inout) { components.append("inout") }
      if attributes.contains(.variadic) {
        components.append("\(type)...")
      } else {
        components.append("\(type)")
      }
      let serializedComponents = components.joined(separator: " ")
      guard let label = self.label else { return serializedComponents }
      return "\(label): \(serializedComponents)"
    }
    
    var debugDescription: String {
      var description: String {
        var components = [String]()
        if attributes.contains(.escaping) { components.append("@escaping") }
        if attributes.contains(.autoclosure) { components.append("@autoclosure") }
        if attributes.contains(.inout) { components.append("inout") }
        if attributes.contains(.variadic) {
          components.append(String(reflecting: type) + "...")
        } else {
          components.append(String(reflecting: type))
        }
        let serializedComponents = components.joined(separator: " ")
        guard let label = self.label else { return serializedComponents }
        return "\(label): \(serializedComponents)"
      }
      return "Parameter(\(description))"
    }
    
    func serialize(with request: SerializationRequest) -> String {
      var components = [String]()
      if attributes.contains(.escaping) { components.append("@escaping") }
      if attributes.contains(.autoclosure) { components.append("@autoclosure") }
      if attributes.contains(.inout) { components.append("inout") }
      if attributes.contains(.variadic) {
        components.append(type.serialize(with: request) + "...")
      } else {
        components.append(type.serialize(with: request))
      }
      let serializedComponents = components.joined(separator: " ")
      guard let label = self.label, !request.options.contains(.shouldExcludeArgumentLabels)
        else { return serializedComponents }
      return "\(label): \(serializedComponents)"
    }
    
    init(from serialized: String) {
      self.init(from: serialized[...])
    }
    
    init(from serialized: Substring) {
      let defaultValueIndex = serialized.firstIndex(of: "=", excluding: .allGroups)
      if let defaultValueIndex = defaultValueIndex {
        self.defaultValue = serialized[serialized.index(after: defaultValueIndex)...]
          .trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
        self.defaultValue = nil
      }
      
      let typeDeclaration: String
      let typeDeclarationEndIndex = defaultValueIndex ?? serialized.endIndex
      if serialized.contains(":", excluding: .allGroups),
        let labelIndex = serialized.firstIndex(of: ":") {
        self.label = serialized[..<labelIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        typeDeclaration = serialized[serialized.index(after: labelIndex)..<typeDeclarationEndIndex]
          .trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
        self.label = nil
        typeDeclaration = serialized[..<typeDeclarationEndIndex]
          .trimmingCharacters(in: .whitespacesAndNewlines)
      }
      
      var attributes = Attributes()
      var parameterTypeComponents = [Substring]()
      typeDeclaration[...].components(separatedBy: .whitespacesAndNewlines, excluding: .allGroups)
        .filter({ !$0.isEmpty })
        .forEach({ component in
          if component == "@escaping" {
            attributes.insert(.escaping)
          } else if component == "@autoclosure" {
            attributes.insert(.autoclosure)
          } else if component.hasPrefix("@") { // Unknown parameter attribute.
            logWarning("Ignoring unknown parameter attribute \(String(component).singleQuoted) in function type declaration \(String(serialized).singleQuoted)")
          } else if component == "inout" {
            attributes.insert(.inout)
          } else if component == "..." {
            attributes.insert(.variadic)
          } else { // Probably part of the parameter type.
            guard component.hasSuffix("...") else {
              parameterTypeComponents.append(component)
              return
            }
            // Handle variadic components that are "stuck" to a parameter type component.
            attributes.insert(.variadic)
            parameterTypeComponents.append(
              component[..<component.index(component.endIndex, offsetBy: -3)]
            )
          }
        })
      self.attributes = attributes
      let parameterType = parameterTypeComponents.joined(separator: " ")
      self.type = DeclaredType(from: parameterType)
    }
  }
  
  let parameters: [Parameter]
  let returnType: DeclaredType
  let isThrowing: Bool
  
  var description: String {
    let throwing = isThrowing ? "throws " : ""
    return "(\(parameters.map({ "\($0)" }).joined(separator: ", "))) \(throwing)-> \(returnType)"
  }
  
  var debugDescription: String {
    var description: String {
      let throwing = isThrowing ? "throws " : ""
      return "(\(parameters.map({ String(reflecting: $0) }).joined(separator: ", "))) \(throwing)-> \(String(reflecting: returnType))"
    }
    return "Function(\(description))"
  }
  
  func serialize(with request: SerializationRequest) -> String {
    let throwing = isThrowing ? "throws " : ""
    return "(\(parameters.map({ $0.serialize(with: request) }).joined(separator: ", "))) \(throwing)-> \(returnType.serialize(with: request))"
  }
  
  init?(from serialized: Substring) {
    guard let returnTypeIndex = serialized.firstIndex(of: "->", excluding: .allGroups),
      let parametersStartIndex = serialized.firstIndex(of: "(", excluding: .allGroups),
      let parametersEndIndex = serialized[serialized.index(after: parametersStartIndex)...]
        .firstIndex(of: ")", excluding: .allGroups)
      else { return nil }
    self.parameters = serialized[serialized.index(after: parametersStartIndex)..<parametersEndIndex]
      .components(separatedBy: ",", excluding: .allGroups)
      .filter({ !$0.isEmpty })
      .map({ Parameter(from: $0) })
    
    let returnTypeDeclaration = serialized[serialized.index(returnTypeIndex, offsetBy: 2)...]
      .trimmingCharacters(in: .whitespacesAndNewlines)
    self.returnType = DeclaredType(from: returnTypeDeclaration)
    
    let returnAttributes = serialized[parametersEndIndex..<returnTypeIndex]
      .trimmingCharacters(in: .whitespacesAndNewlines)
    self.isThrowing = !returnAttributes.isEmpty &&
      returnAttributes.range(of: #"\bthrows\b"#, options: .regularExpression) != nil
  }
}
