//
//  Variable.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Variable: Hashable, Comparable {
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
  
  static func < (lhs: Variable, rhs: Variable) -> Bool {
    return lhs.name < rhs.name
  }
  
  init?(from dictionary: StructureDictionary, rootKind: SwiftDeclarationKind, rawType: RawType) {
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isVariable,
      // Can't override static variable declarations in classes.
      kind.typeScope == .instance
        || kind.typeScope == .class
        || (kind.typeScope == .static && rootKind == .protocol) else { return nil }
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String,
      let accessLevel = AccessLevel(from: dictionary), accessLevel.isMockable else { return nil }
    
    var attributes = Attributes.create(from: dictionary)
    guard !attributes.contains(.final) else { return nil }
    
    if let typeName = dictionary[SwiftDocKey.typeName.rawValue] as? String {
      self.typeName = typeName // Type was explicitly declared, hooray!
    } else if let declaration = SourceSubstring.nameSuffix
      .extract(from: dictionary, contents: rawType.parsedFile.file.contents)?.stripped(),
      declaration.hasPrefix("=") { // We might be able to infer the type...
      var cleanedDeclaration = declaration.dropFirst().trimmingCharacters(in: .whitespaces)
      cleanedDeclaration = cleanedDeclaration.components(separatedBy: .newlines)[0]
      
      if cleanedDeclaration.hasSuffix("{") {
        cleanedDeclaration = cleanedDeclaration.dropLast().trimmingCharacters(in: .whitespaces)
      }
      
      // Use a slightly modified version of Sourcery's type inference system.
      let inferredType = inferType(from: cleanedDeclaration)
      self.typeName = inferredType ?? "Any?"
      if inferredType == nil {
        fputs("WARNING: Could not infer type for variable `\(name)`, declaration: `\(cleanedDeclaration)`\n", stderr)
      }
    } else {
      self.typeName = "Any?"
      fputs("WARNING: Could not extract type info for variable `\(name)`\n", stderr)
    }
    
    self.name = name
    self.kind = kind
    self.setterAccessLevel = AccessLevel(setter: dictionary) ?? .internal
    
    // Determine if the variable type is computed, stored, or constant.
    let source = rawType.parsedFile.file.contents
    let isConstant = SourceSubstring.key
      .extract(from: dictionary, contents: source)?
      .hasPrefix("let") == true
    guard !isConstant else { return nil } // Can't override constant variables.
    
    if rootKind == .class {
      var isComputed = setterAccessLevel == nil // && !isConstant (but we don't mock constant vars).
      if !isComputed { // && setterAccessLevel != nil
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
