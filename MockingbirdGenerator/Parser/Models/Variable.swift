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
  let accessLevel: AccessLevel
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
    return lhs.name + lhs.kind.typeScope.rawValue < rhs.name + rhs.kind.typeScope.rawValue
  }
  
  init?(from dictionary: StructureDictionary,
        rootKind: SwiftDeclarationKind,
        rawType: RawType,
        moduleNames: [String],
        rawTypeRepository: RawTypeRepository) {
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isVariable,
      // Can't override static variable declarations in classes.
      kind.typeScope == .instance
        || kind.typeScope == .class
        || (kind.typeScope == .static && rootKind == .protocol) else { return nil }
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String,
      let accessLevel = AccessLevel(from: dictionary),
      accessLevel.isMockableMember(in: rootKind, withinSameModule: rawType.parsedFile.shouldMock)
      else { return nil }
    self.accessLevel = accessLevel
    
    let source = rawType.parsedFile.data
    var attributes = Attributes(from: dictionary, source: source)
    guard !attributes.contains(.final) else { return nil }
    
    let rawTypeName: String
    if let inferredTypeName = Variable.parseRawTypeName(from: dictionary, source: source) {
      rawTypeName = inferredTypeName
    } else {
      fputs("Unable to infer type for variable `\(name)` in module `\(rawType.parsedFile.moduleName)`. You should explicitly declare the variable type in the source file \(rawType.parsedFile.path.absolute())\n", stderr)
      // Use an editor placeholder to trigger a compiler error if this type is ever generated.
      rawTypeName = "<#__UnknownType__#>"
    }
    let declaredType = DeclaredType(from: rawTypeName)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository)
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: serializationContext,
                                                        options: .standard)
    self.typeName = declaredType.serialize(with: qualifiedTypeNameRequest)
    
    self.name = name
    self.kind = kind
    let setterAccessLevel = AccessLevel(setter: dictionary)
    
    // Determine if the variable type is computed, stored, or constant.
    let isConstant = SourceSubstring.key
      .extract(from: dictionary, contents: source)?
      .hasPrefix("let") == true
    guard !isConstant else { return nil } // Can't override constant variables.
    
    if rootKind == .class {
      let isComputed = setterAccessLevel == nil // && !isConstant (but we don't mock constant vars).
      var isMutable = !isComputed
      if !isComputed { // && setterAccessLevel != nil
        let body = SourceSubstring.body.extract(from: dictionary, contents: source) ?? ""
        let hasSetter = body.hasPrefix("didSet") || body.hasPrefix("willSet")
          || body.contains("set", excluding: ["{": "}"])
        isMutable = (body.isEmpty || hasSetter)
      }
      if isComputed && !isMutable { attributes.insert(.readonly) }
    } else {
      if setterAccessLevel == nil { attributes.insert(.readonly) }
    }
    self.attributes = attributes
    self.setterAccessLevel = setterAccessLevel ?? .internal
  }
  
  private static func parseRawTypeName(from dictionary: StructureDictionary,
                                       source: Data?) -> String? {
    if let explicitTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String {
      return explicitTypeName // The type was explicitly declared, hooray!
    }
    
    // Try to infer the type from the raw declaration.
    guard let declaration = SourceSubstring.nameSuffix.extract(from: dictionary,
                                                               contents: source)?.stripped(),
      declaration.hasPrefix("=") else { return nil }
    
    var cleanedDeclaration = declaration.dropFirst().trimmingCharacters(in: .whitespaces)
    cleanedDeclaration = cleanedDeclaration.components(separatedBy: .newlines)[0]
    
    if cleanedDeclaration.hasSuffix("{") {
      cleanedDeclaration = cleanedDeclaration.dropLast().trimmingCharacters(in: .whitespaces)
    }
    
    // Use a slightly modified version of Sourcery's type inference system.
    return inferType(from: cleanedDeclaration)
  }
}
