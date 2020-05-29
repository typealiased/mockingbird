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
  let compilationDirectives: [CompilationDirective]
  let isOverridable: Bool
  let hasSelfConstraint: Bool
  
  private let rawType: RawType
  
  struct Reduced: Hashable {
    let name: String
    let isInstance: Bool
    init(from variable: Variable) {
      self.name = variable.name
      self.isInstance = variable.kind.typeScope == .instance
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(typeName) // This is used to generate availability attributes on conflicts.
    hasher.combine(kind.typeScope == .instance)
  }
  
  static func == (lhs: Variable, rhs: Variable) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  static func < (lhs: Variable, rhs: Variable) -> Bool {
    return (lhs.kind.typeScope, lhs.name) < (rhs.kind.typeScope, rhs.name)
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
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String else { return nil }
    
    let accessLevel = AccessLevel(from: dictionary) ?? .defaultLevel
    guard accessLevel.isMockableMember(in: rootKind,
                                       withinSameModule: rawType.parsedFile.shouldMock)
      else { return nil }
    self.accessLevel = accessLevel
    
    let source = rawType.parsedFile.data
    var attributes = Attributes(from: dictionary, source: source)
    guard !attributes.contains(.final) else { return nil }
    
    let rawTypeName: String
    if let inferredTypeName = Variable.parseRawTypeName(from: dictionary, source: source) {
      rawTypeName = inferredTypeName
    } else {
      logWarning(
        "Unable to infer type of property \(name.singleQuoted) from complex expression",
        diagnostic: .typeInference,
        filePath: rawType.parsedFile.path,
        line: SourceSubstring.key
          .extractLinesNumbers(from: dictionary, contents: rawType.parsedFile.file.contents)?.start
      )
      return nil
    }
    let declaredType = DeclaredType(from: rawTypeName)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository)
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: serializationContext,
                                                        options: .standard)
    let qualifiedTypeName = declaredType.serialize(with: qualifiedTypeNameRequest)
    self.typeName = qualifiedTypeName
    self.hasSelfConstraint =
      qualifiedTypeName.contains(SerializationRequest.Constants.selfTokenIndicator)
    
    self.name = name
    self.kind = kind
    self.isOverridable = rootKind == .class
    self.rawType = rawType
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
    
    // Parse any containing preprocessor macros.
    if let offset = dictionary[SwiftDocKey.offset.rawValue] as? Int64 {
      self.compilationDirectives = rawType.parsedFile.compilationDirectives.filter({
        $0.range.contains(offset)
      })
    } else {
      self.compilationDirectives = []
    }
  }
  
  private static func parseRawTypeName(from dictionary: StructureDictionary,
                                       source: Data?) -> String? {
    if let explicitTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String {
      return explicitTypeName // The type was explicitly declared, hooray!
    }
    
    // Try to infer the type from the raw declaration.
    guard let declaration = SourceSubstring.nameSuffix
      .extract(from: dictionary, contents: source)?.trimmingCharacters(in: .whitespaces),
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

extension Variable: Specializable {
  private init(from variable: Variable, typeName: String) {
    self.name = variable.name
    self.typeName = typeName
    self.kind = variable.kind
    self.accessLevel = variable.accessLevel
    self.setterAccessLevel = variable.setterAccessLevel
    self.attributes = variable.attributes
    self.compilationDirectives = variable.compilationDirectives
    self.isOverridable = variable.isOverridable
    self.hasSelfConstraint = variable.hasSelfConstraint
    self.rawType = variable.rawType
  }
  
  func specialize(using context: SpecializationContext,
                  moduleNames: [String],
                  genericTypeContext: [[String]],
                  excludedGenericTypeNames: Set<String>,
                  rawTypeRepository: RawTypeRepository,
                  typealiasRepository: TypealiasRepository) -> Variable {
    guard !context.specializations.isEmpty else { return self }
    
    let declaredType = DeclaredType(from: typeName)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository,
               typealiasRepository: typealiasRepository)
    let attributedSerializationContext = SerializationRequest
      .Context(from: serializationContext,
               genericTypeContext: genericTypeContext + serializationContext.genericTypeContext,
               excludedGenericTypeNames: excludedGenericTypeNames,
               specializationContext: context)
    let options: SerializationRequest.Options = [.standard, .shouldSpecializeTypes]
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: attributedSerializationContext,
                                                        options: options)
    let specializedTypeName = declaredType.serialize(with: qualifiedTypeNameRequest)

    return Variable(from: self, typeName: specializedTypeName)
  }
}
