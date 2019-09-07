//
//  DeclaredType.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/1/19.
//

import Foundation

/// Fully qualifies tokenized `DeclaredType` objects given a declaration context.
struct SerializationRequest {
  enum Constants {
    static let selfToken = "{#Self#}"
  }
  
  enum Method: String {
    case contextQualified = "contextQualified"
    case moduleQualified = "moduleQualified"
    case actualTypeName = "actualTypeName"
  }
  
  struct Options: OptionSet, Hashable {
    let rawValue: Int
    init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    static let shouldTokenizeSelf = Options(rawValue: 1 << 0)
    static let shouldExcludeArgumentLabels = Options(rawValue: 1 << 1)
    
    static let standard: Options = [.shouldTokenizeSelf, .shouldExcludeArgumentLabels]
  }
  
  class Context {
    let moduleNames: [String]
    let referencingModuleName: String // The module referencing the type in some declaration.
    let containingTypeNames: ArraySlice<String>
    let containingScopes: ArraySlice<String>
    let rawTypeRepository: RawTypeRepository
    let typealiasRepository: TypealiasRepository?
    init(moduleNames: [String],
         rawType: RawType,
         rawTypeRepository: RawTypeRepository,
         typealiasRepository: TypealiasRepository? = nil) {
      self.moduleNames = moduleNames
      self.referencingModuleName = rawType.parsedFile.moduleName
      self.containingTypeNames = rawType.containingTypeNames[...] + [rawType.name]
      self.containingScopes = rawType.containingScopes[...] + [rawType.name]
      self.rawTypeRepository = rawTypeRepository
      self.typealiasRepository = typealiasRepository
    }
    
    init(moduleNames: [String],
         referencingModuleName: String,
         containingTypeNames: ArraySlice<String>,
         containingScopes: ArraySlice<String>,
         rawTypeRepository: RawTypeRepository,
         typealiasRepository: TypealiasRepository? = nil) {
      self.moduleNames = moduleNames
      self.referencingModuleName = referencingModuleName
      self.containingTypeNames = containingTypeNames
      self.containingScopes = containingScopes
      self.rawTypeRepository = rawTypeRepository
      self.typealiasRepository = typealiasRepository
    }
    
    /// typeName => method => serialized
    fileprivate var memoizedTypeNames = [String: [String: String]]()
  }
  
  let method: Method
  let context: Context
  let options: Options
}

protocol SerializableType {
  func serialize(with request: SerializationRequest) -> String
}

private extension SerializationRequest {
  /// Given a `typeName`, serialize it based on the current request context and method.
  func serialize(_ typeName: String) -> String {
    guard typeName != "Self" else { // `Self` can never be typealiased away.
      return (options.contains(.shouldTokenizeSelf) ? Constants.selfToken : typeName)
    }
    
    if let memoized = context.memoizedTypeNames[typeName]?[method.rawValue] {
      return memoized
    }
    
    guard let qualifiedTypeNames = context.rawTypeRepository
      .nearestInheritedType(named: typeName,
                            trimmedName: typeName.removingGenericTyping(),
                            moduleNames: context.moduleNames,
                            referencingModuleName: context.referencingModuleName,
                            containingTypeNames: context.containingTypeNames)?
      .findBaseRawType()?
      .qualifiedModuleNames(from: typeName, context: context.containingScopes)
      else { return typeName }
    context.memoizedTypeNames[typeName]?[Method.contextQualified.rawValue] =
      qualifiedTypeNames.contextQualified
    context.memoizedTypeNames[typeName]?[Method.moduleQualified.rawValue] =
      qualifiedTypeNames.moduleQualified
    switch method {
    case .contextQualified: return qualifiedTypeNames.contextQualified
    case .moduleQualified: return qualifiedTypeNames.moduleQualified
    case .actualTypeName:
      guard let typealiasRepository = context.typealiasRepository else { return typeName }
      let actualTypeName = typealiasRepository
        .actualTypeName(for: qualifiedTypeNames.moduleQualified,
                        rawTypeRepository: context.rawTypeRepository,
                        moduleNames: context.moduleNames,
                        referencingModuleName: context.referencingModuleName,
                        containingTypeNames: context.containingTypeNames)
      context.memoizedTypeNames[typeName]?[Method.actualTypeName.rawValue] = actualTypeName
      return actualTypeName
    }
  }
}

/// Tokenizes type declarations.
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
    case let .single(single, optionals): return "\(single)\(optionals)"
    case let .tuple(tuple, optionals): return "\(tuple)\(optionals)"
    }
  }
  
  var debugDescription: String {
    var description: String {
      switch self {
      case let .single(single, optionals): return "\(String(reflecting: single))\(optionals)"
      case let .tuple(tuple, optionals): return "\(String(reflecting: tuple))\(optionals)"
      }
    }
    return "DeclaredType(\(description))"
  }
  
  func serialize(with request: SerializationRequest) -> String {
    switch self {
    case let .single(single, optionals):
      return single.serialize(with: request) + optionals
    case let .tuple(tuple, optionals):
      return tuple.serialize(with: request) + optionals
    }
  }
}

extension DeclaredType {
  init(from serialized: String) {
    self.init(from: serialized[...])
  }
  
  init(from serialized: Substring) {
    let trimmed = serialized.trimmingCharacters(in: .whitespacesAndNewlines)[...]
    // Handle optionals (which can be wrapped multiple times).
    let firstOptionalIndex = trimmed.firstIndex(of: "?", excluding: .allGroups) ?? trimmed.endIndex
    let optionals = String(trimmed[firstOptionalIndex...])
    let unwrappedType = trimmed[..<firstOptionalIndex]
    guard let tuple = Tuple(from: unwrappedType) else {
      self = .single(Single(from: unwrappedType), optionals: optionals)
      return
    }
    self = .tuple(tuple, optionals: optionals)
  }
}

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
  init(from serialized: Substring) {
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
        .map({ DeclaredType(from: $0) })
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
      self = .map(key: DeclaredType(from: keyTypeName[...]),
                  value: DeclaredType(from: valueTypeName[...]))
    } else {
      self = .list(element: DeclaredType(from: flattened))
    }
  }
}

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
    self.elements = labeledElements
  }
}

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
            fputs("Unknown parameter attribute `\(component)` in function type declaration `\(serialized)`.\n", stderr)
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
  
  var description: String {
    return "(\(parameters.map({ "\($0)" }).joined(separator: ", "))) -> \(returnType)"
  }
  
  var debugDescription: String {
    var description: String {
      return "(\(parameters.map({ String(reflecting: $0) }).joined(separator: ", "))) -> \(String(reflecting: returnType))"
    }
    return "Function(\(description))"
  }
  
  func serialize(with request: SerializationRequest) -> String {
    return "(\(parameters.map({ $0.serialize(with: request) }).joined(separator: ", "))) -> \(returnType.serialize(with: request))"
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
  }
}
