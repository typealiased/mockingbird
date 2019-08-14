//
//  Variable.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Variable: Hashable {
  let name: String
  let typeName: String
  let kind: SwiftDeclarationKind
  let setterAccessLevel: AccessLevel
  let attributes: Attributes
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(typeName)
    hasher.combine(kind.typeScope == .instance)
  }
  
  static func ==(lhs: Variable, rhs: Variable) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  init?(from dictionary: StructureDictionary, rootKind: SwiftDeclarationKind, rawType: RawType) {
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind.isVariable,
      let name = dictionary[SwiftDocKey.name.rawValue] as? String
      else { return nil }
    guard let rawAccessLevel = dictionary[AccessLevel.accessLevelKey] as? String,
      let accessLevel = AccessLevel(rawValue: rawAccessLevel),
      accessLevel != .fileprivate, accessLevel != .private else { return nil }
    
    var attributes = Attributes.create(from: dictionary)
    guard !attributes.contains(.final) else { return nil }
    
    if let typeName = dictionary[SwiftDocKey.typeName.rawValue] as? String {
      self.typeName = typeName
    } else if let declaration = SourceSubstring.nameSuffix
      .extract(from: dictionary,
               contents: rawType.parsedFile.file.contents)?.trimmingCharacters(in: .whitespaces),
      declaration.hasPrefix("=") {
      
      var cleanedDeclaration = declaration.dropFirst().trimmingCharacters(in: .whitespaces)
      cleanedDeclaration = cleanedDeclaration.components(separatedBy: .newlines)[0]
      
      if cleanedDeclaration.hasSuffix("{") {
        cleanedDeclaration = String(cleanedDeclaration.dropLast()).trimmingCharacters(in: .whitespaces)
      }
      
      let inferredType = inferType(from: cleanedDeclaration)
      self.typeName = inferredType ?? "Any?"
      if inferredType == nil {
        print("Could not infer type for variable \(name): \(cleanedDeclaration)")
      }
    } else {
      self.typeName = "Any?"
      print("Could not extract type info for variable \(name)")
    }
    
    var setterAccessLevel: AccessLevel?
    if let rawAccessLevel = dictionary[AccessLevel.setterAccessLevelKey] as? String,
      let accessLevel = AccessLevel(rawValue: rawAccessLevel) {
      setterAccessLevel = accessLevel
    }
    self.name = name
    
    self.kind = kind
    guard kind.typeScope == .instance
      || kind.typeScope == .class
      || (kind.typeScope == .static && rootKind == .protocol) else {
        return nil // Can't override static variable declarations in classes.
    }
    
    self.setterAccessLevel = setterAccessLevel ?? .internal
    
    let source = rawType.parsedFile.file.contents
    let isConstant = SourceSubstring.key
      .extract(from: dictionary, contents: source)?
      .hasPrefix("let") == true
    guard !isConstant else { return nil } // Can't override constant variables.
    if rootKind == .class {
      var isComputed = (setterAccessLevel == nil && !isConstant)
      if !isComputed && setterAccessLevel != nil {
        let body = SourceSubstring.body.extract(from: dictionary, contents: source) ?? ""
        let hasPropertyObservers = body.hasPrefix("didSet") || body.hasPrefix("willSet")
        isComputed = (!body.isEmpty && !hasPropertyObservers)
      }
      guard isComputed else { return nil } // Can't override non-computed instance variables.
      attributes.insert(.computed)
    }
    self.attributes = attributes
  }
}
