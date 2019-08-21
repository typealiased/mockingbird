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
  
  init?(from dictionary: StructureDictionary, argumentLabel: String?) {
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind == .varParameter
      else { return nil }
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String,
      let typeName = dictionary[SwiftDocKey.typeName.rawValue] as? String
      else { return nil }
    self.name = name
    self.typeName = typeName
    self.kind = kind
    self.argumentLabel = argumentLabel
    self.attributes = Attributes.create(from: dictionary)
  }
}

struct Method: Hashable, Comparable {
  let name: String
  let returnTypeName: String
  let isInitializer: Bool
  let kind: SwiftDeclarationKind
  let genericTypes: [GenericType]
  let parameters: [MethodParameter]
  let attributes: Attributes
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(returnTypeName)
    hasher.combine(kind.typeScope == .instance)
    hasher.combine(genericTypes)
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
    
    let source = rawType.parsedFile.file.contents
    if let declaration = SourceSubstring.key.extract(from: dictionary, contents: source) {
      let startIndex = declaration.firstIndex(of: ")") ?? declaration.startIndex
      if declaration[startIndex..<declaration.endIndex].contains("throws") {
        attributes.insert(.throws)
      }
    }
    self.attributes = attributes
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
      parameters = substructure.compactMap({
        guard let parameter = MethodParameter(from: $0, argumentLabel: labels[parameterIndex])
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
