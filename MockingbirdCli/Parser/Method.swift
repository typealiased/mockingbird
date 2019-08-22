//
//  Method.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct MethodParameter: Hashable {
  let name: String
  let argumentLabel: String?
  let typeName: String
  let kind: SwiftDeclarationKind
  let attributes: Attributes
  
  init?(from dictionary: StructureDictionary, argumentLabel: String?, rawDeclaration: Substring?) {
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind == .varParameter
      else { return nil }
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String,
      let rawTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String
      else { return nil }
    self.name = name
    self.kind = kind
    self.argumentLabel = argumentLabel
    var typeName = rawTypeName
    var attributes = Attributes.create(from: dictionary)
    if typeName.hasPrefix("inout ") {
      attributes.insert(.`inout`)
      typeName = String(typeName.dropFirst(6))
    }
    if rawDeclaration?.hasSuffix("...") == true {
      attributes.insert(.variadic)
    }
    self.typeName = typeName
    self.attributes = attributes
  }
}

struct Method: Hashable, Comparable {
  let name: String
  let returnTypeName: String
  let isInitializer: Bool
  let kind: SwiftDeclarationKind
  let genericTypes: [GenericType]
  let genericConstraints: [String]
  let parameters: [MethodParameter]
  let attributes: Attributes
  
  // A hashable version of Method that's unique according to Swift generics when subclassing.
  // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
  struct Reduced: Hashable {
    let name: String
    let returnTypeName: String
    let genericTypes: [GenericType.Reduced]
    let parameters: [MethodParameter]
    init(from method: Method) {
      self.name = method.name
      self.returnTypeName = method.returnTypeName
      self.genericTypes = method.genericTypes.map({ GenericType.Reduced(from: $0) })
      self.parameters = method.parameters
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(returnTypeName)
    hasher.combine(kind.typeScope == .instance)
    hasher.combine(genericTypes)
    hasher.combine(genericConstraints)
    hasher.combine(parameters)
  }
  
  static func ==(lhs: Method, rhs: Method) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  static func < (lhs: Method, rhs: Method) -> Bool { // TODO: Sort overloaded methods by params.
    return lhs.name < rhs.name
  }
  
  init?(from dictionary: StructureDictionary, rootKind: SwiftDeclarationKind, rawType: RawType) {
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind.isMethod
      else { return nil }
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String, name != "deinit"
      else { return nil }
    guard let rawAccessLevel = dictionary[AccessLevel.accessLevelKey] as? String,
      let accessLevel = AccessLevel(rawValue: rawAccessLevel),
      accessLevel != .fileprivate, accessLevel != .private else { return nil }
    
    var attributes = Attributes.create(from: dictionary)
    guard !attributes.contains(.final) else { return nil }
    let isInitializer = (name == "init" || name.hasPrefix("init("))
    
    var rawParametersDeclaration: Substring?
    var genericConstraints = [String]()
    let source = rawType.parsedFile.file.contents
    if let declaration = SourceSubstring.key.extract(from: dictionary, contents: source) {
      let parametersEndIndex = declaration.firstIndex(of: ")")
      if let startIndex = declaration.firstIndex(of: "("), let endIndex = parametersEndIndex {
        rawParametersDeclaration = declaration[startIndex..<endIndex]
      }
      let returnAttributesStartIndex = parametersEndIndex ?? declaration.startIndex
      let returnAttributesEndIndex = declaration.firstIndex(of: "-") ?? declaration.endIndex
      let returnAttributes = declaration[returnAttributesStartIndex..<returnAttributesEndIndex]
      if returnAttributes.range(of: #"\bthrows\b"#, options: .regularExpression) != nil {
        attributes.insert(.throws)
      }
    }
    if let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: dictionary, contents: source) {
      if let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression) {
        genericConstraints = nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
          .substringComponents(separatedBy: ",")
          .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
      }
    }
    self.attributes = attributes
    self.genericConstraints = genericConstraints
    self.isInitializer = isInitializer
    
    self.name = name
    self.returnTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String ?? "Void"
    self.kind = kind
    guard kind.typeScope == .instance
      || kind.typeScope == .class
      || (kind.typeScope == .static && rootKind == .protocol) else {
        return nil // Can't override static method declarations in classes.
    }
    
    let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] ?? []
    self.genericTypes = substructure.compactMap({ structure -> GenericType? in
      guard let genericType = GenericType(from: structure, rawType: rawType) else { return nil }
      return genericType
    })
    
    var parameters = [MethodParameter]()
    let labels = name.argumentLabels
    if !labels.isEmpty {
      var parameterIndex = 0
      let rawDeclarations = rawParametersDeclaration?.substringComponents(separatedBy: ",")
      parameters = substructure.compactMap({
        let rawDeclaration = rawDeclarations?.get(parameterIndex)
        guard let parameter = MethodParameter(from: $0,
                                              argumentLabel: labels[parameterIndex],
                                              rawDeclaration: rawDeclaration)
          else { return nil }
        parameterIndex += 1
        return parameter
      })
    }
    self.parameters = parameters
  }
}

private extension String {
  var argumentLabels: [String?] {
    guard let startIndex = firstIndex(of: "("),
      let stopIndex = firstIndex(of: ")") else { return [] }
    let arguments = self[index(startIndex, offsetBy: 1)..<stopIndex]
    return arguments.substringComponents(separatedBy: ":").map({ $0 != "_" ? String($0) : nil })
  }
}
