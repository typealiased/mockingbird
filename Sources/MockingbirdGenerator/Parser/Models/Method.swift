//
//  Method.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Method {
  let name: String
  let shortName: String
  let returnType: DeclaredType
  let returnTypeName: String
  let isInitializer: Bool
  let isDesignatedInitializer: Bool
  let accessLevel: AccessLevel
  let kind: SwiftDeclarationKind
  let genericTypes: [GenericType]
  let whereClauses: [WhereClause]
  let parameters: [MethodParameter]
  let attributes: Attributes
  let compilationDirectives: [CompilationDirective]
  let isOverridable: Bool
  let hasSelfConstraint: Bool
  let isMockable: Bool
  
  private let rawType: RawType
  
  init?(from dictionary: StructureDictionary,
        rootKind: SwiftDeclarationKind,
        rawType: RawType,
        moduleNames: [String],
        rawTypeRepository: RawTypeRepository,
        typealiasRepository: TypealiasRepository) {
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isMethod,
      // Can't override static method declarations in classes.
      kind.typeScope == .instance
      || kind.typeScope == .class
      || (kind.typeScope == .static && rootKind == .protocol)
      else { return nil }
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String, name != "deinit"
      else { return nil }
    self.name = name
    let isInitializer = name.hasPrefix("init(")
    self.isInitializer = isInitializer
    
    let accessLevel = AccessLevel(from: dictionary) ?? .defaultLevel
    self.isMockable =
      accessLevel.isMockableMember(in: rootKind, withinSameModule: rawType.parsedFile.shouldMock)
      || (isInitializer && accessLevel.isMockable) // Initializers cannot be `open`.
    self.accessLevel = accessLevel
    
    let source = rawType.parsedFile.data
    let attributes = Attributes(from: dictionary, source: source)
    guard !attributes.contains(.final) else { return nil }
    self.isDesignatedInitializer = isInitializer && !attributes.contains(.convenience)
    
    let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] ?? []
    self.kind = kind
    self.isOverridable = rootKind == .class
    self.rawType = rawType
    
    // Parse declared attributes and parameters.
    let rawParametersDeclaration: Substring?
    (self.attributes,
     rawParametersDeclaration) = Method.parseDeclaration(from: dictionary,
                                                         source: source,
                                                         isInitializer: isInitializer,
                                                         attributes: attributes)
    
    // Parse return type.
    let (returnType, returnTypeName) = Method.parseReturnType(
      from: dictionary,
      rawType: rawType,
      moduleNames: moduleNames,
      rawTypeRepository: rawTypeRepository,
      typealiasRepository: typealiasRepository)
    self.returnType = returnType
    self.returnTypeName = returnTypeName
    
    // Parse generic type constraints and where clauses.
    self.whereClauses = Method.parseWhereClauses(from: dictionary,
                                                 source: source,
                                                 rawType: rawType,
                                                 moduleNames: moduleNames,
                                                 rawTypeRepository: rawTypeRepository)
    self.genericTypes = substructure
      .compactMap({ structure -> GenericType? in
        guard let genericType = GenericType(from: structure,
                                            rawType: rawType,
                                            moduleNames: moduleNames,
                                            rawTypeRepository: rawTypeRepository)
          else { return nil }
        return genericType
      })
    
    // Parse parameters.
    let (shortName, labels) = Method.parseArgumentLabels(name: name,
                                                         parameters: rawParametersDeclaration)
    self.shortName = shortName
    let parameters = Method.parseParameters(labels: labels,
                                            substructure: substructure,
                                            rawParametersDeclaration: rawParametersDeclaration,
                                            rawType: rawType,
                                            moduleNames: moduleNames,
                                            rawTypeRepository: rawTypeRepository,
                                            typealiasRepository: typealiasRepository)
    self.parameters = parameters
    
    // Parse any containing preprocessor macros.
    if let offset = dictionary[SwiftDocKey.offset.rawValue] as? Int64 {
      self.compilationDirectives = rawType.parsedFile.compilationDirectives.filter({
        $0.range.contains(offset)
      })
    } else {
      self.compilationDirectives = []
    }
    
    // Check whether this method has any `Self` type constraints.
    self.hasSelfConstraint =
      returnTypeName.contains(SerializationRequest.Constants.selfTokenIndicator)
      || parameters.contains(where: { $0.hasSelfConstraints })
  }
  
  private static func parseDeclaration(from dictionary: StructureDictionary,
                                       source: Data?,
                                       isInitializer: Bool,
                                       attributes: Attributes) -> (Attributes, Substring?) {
    guard let declaration = SourceSubstring.key.extract(from: dictionary, contents: source)
      else { return (attributes, nil) }
    
    var fullAttributes = attributes
    var rawParametersDeclaration: Substring?
    
    // Parse parameter attributes.
    let startIndex = declaration.firstIndex(of: "(")
    let parametersEndIndex =
      declaration[declaration.index(after: (startIndex ?? declaration.startIndex))...]
        .firstIndex(of: ")", excluding: .allGroups)
    if let startIndex = startIndex, let endIndex = parametersEndIndex {
      rawParametersDeclaration = declaration[declaration.index(after: startIndex)..<endIndex]
      
      if isInitializer { // Parse failable initializers.
        let genericsStart = declaration[..<startIndex].firstIndex(of: "<") ?? startIndex
        let failable = declaration[declaration.index(before: genericsStart)..<genericsStart]
        if failable == "?" {
          fullAttributes.insert(.failable)
        } else if failable == "!" {
          fullAttributes.insert(.unwrappedFailable)
        }
      }
    }
    
    // Parse return type attributes.
    let returnAttributesStartIndex = parametersEndIndex ?? declaration.startIndex
    let returnAttributesEndIndex = declaration.firstIndex(of: "-", excluding: .allGroups)
      ?? declaration.endIndex
    let returnAttributes = declaration[returnAttributesStartIndex..<returnAttributesEndIndex]
    if returnAttributes.range(of: #"\bthrows\b"#, options: .regularExpression) != nil {
      fullAttributes.insert(.throws)
    }
    
    return (fullAttributes, rawParametersDeclaration)
  }
  
  private static func parseArgumentLabels(name: String, parameters: Substring?)
  -> (shortName: String, labels: [String?]) {
    let (shortName, labels) = name.extractArgumentLabels()
    guard parameters?.isEmpty == false else {
      return (shortName, labels)
    }
    let declarationLabels = parameters?.components(separatedBy: ",", excluding: .allGroups)
      .map({ $0.components(separatedBy: ":", excluding: .allGroups)[0]
            .trimmingCharacters(in: .whitespacesAndNewlines) })
      .map({ $0.components(separatedBy: " ", excluding: .allGroups)[0]
            .trimmingCharacters(in: .whitespacesAndNewlines) })
      .map({ $0 != "_" ? $0 : nil })
    return (shortName, declarationLabels ?? labels)
  }
  
  private static func parseWhereClauses(from dictionary: StructureDictionary,
                                        source: Data?,
                                        rawType: RawType,
                                        moduleNames: [String],
                                        rawTypeRepository: RawTypeRepository) -> [WhereClause] {
    guard let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: dictionary,
                                                                      contents: source),
      let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression)
      else { return [] }
    return nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
      .components(separatedBy: ",", excluding: .allGroups)
      .compactMap({ WhereClause(from: String($0)) })
      .map({ GenericType.qualifyWhereClause($0,
                                            containingType: rawType,
                                            moduleNames: moduleNames,
                                            rawTypeRepository: rawTypeRepository) })
  }
  
  private static func parseReturnType(
    from dictionary: StructureDictionary,
    rawType: RawType,
    moduleNames: [String],
    rawTypeRepository: RawTypeRepository,
    typealiasRepository: TypealiasRepository
  ) -> (DeclaredType, String) {
    guard let rawReturnTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String else {
      return (DeclaredType(from: "Void"), "Void")
    }
    let declaredType = DeclaredType(from: rawReturnTypeName)
    let serializationContext = SerializationRequest
      .Context(moduleNames: moduleNames,
               rawType: rawType,
               rawTypeRepository: rawTypeRepository,
               typealiasRepository: typealiasRepository)
    let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                        context: serializationContext,
                                                        options: .standard)
    return (declaredType, declaredType.serialize(with: qualifiedTypeNameRequest))
  }
  
  private static func parseParameters(labels: [String?],
                                      substructure: [StructureDictionary],
                                      rawParametersDeclaration: Substring?,
                                      rawType: RawType,
                                      moduleNames: [String],
                                      rawTypeRepository: RawTypeRepository,
                                      typealiasRepository: TypealiasRepository) -> [MethodParameter] {
    guard !labels.isEmpty else { return [] }
    var parameterIndex = 0
    let rawDeclarations = rawParametersDeclaration?
      .components(separatedBy: ",", excluding: .allGroups)
      .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
    return substructure.compactMap({
      let rawDeclaration = rawDeclarations?.get(parameterIndex)
      guard let parameter = MethodParameter(from: $0,
                                            argumentLabel: labels.get(parameterIndex) ?? nil,
                                            parameterIndex: parameterIndex,
                                            rawDeclaration: rawDeclaration,
                                            rawType: rawType,
                                            moduleNames: moduleNames,
                                            rawTypeRepository: rawTypeRepository,
                                            typealiasRepository: typealiasRepository)
        else { return nil }
      parameterIndex += 1
      return parameter
    })
  }
}

extension Method: Hashable {
  /// A hashable version of Method that's unique according to Swift generics when subclassing.
  /// https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
  struct Reduced: Hashable {
    let name: String
    let returnTypeName: String
    let parameters: [MethodParameter]
    let attributes: Attributes
    init(from method: Method) {
      self.name = method.name
      self.returnTypeName = method.returnTypeName
      self.parameters = method.parameters
      
      var reducedAttributes = Attributes()
      if method.attributes.contains(.unwrappedFailable) {
        reducedAttributes.insert(.unwrappedFailable)
      }
      self.attributes = reducedAttributes
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(returnTypeName)
    hasher.combine(kind.typeScope == .instance)
    hasher.combine(genericTypes)
    hasher.combine(whereClauses)
    hasher.combine(parameters)
  }
  
  static func == (lhs: Method, rhs: Method) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

extension Method: Comparable {
  static func < (lhs: Method, rhs: Method) -> Bool {
    return (
      lhs.whereClauses,
      lhs.returnTypeName,
      lhs.kind.typeScope,
      lhs.parameters,
      lhs.genericTypes,
      lhs.name
    ) < (
      rhs.whereClauses,
      rhs.returnTypeName,
      rhs.kind.typeScope,
      rhs.parameters,
      rhs.genericTypes,
      rhs.name
    )
  }
}

extension Method: Specializable {
  private init(from method: Method, returnTypeName: String, parameters: [MethodParameter]) {
    self.name = method.name
    self.shortName = method.shortName
    self.returnType = DeclaredType(from: returnTypeName)
    self.returnTypeName = returnTypeName
    self.isInitializer = method.isInitializer
    self.isDesignatedInitializer = method.isDesignatedInitializer
    self.accessLevel = method.accessLevel
    self.kind = method.kind
    self.genericTypes = method.genericTypes
    self.whereClauses = method.whereClauses
    self.parameters = parameters
    self.attributes = method.attributes
    self.compilationDirectives = method.compilationDirectives
    self.isOverridable = method.isOverridable
    self.hasSelfConstraint = method.hasSelfConstraint
    self.isMockable = method.isMockable
    self.rawType = method.rawType
  }
  
  func specialize(using context: SpecializationContext,
                  moduleNames: [String],
                  genericTypeContext: [[String]],
                  excludedGenericTypeNames: Set<String>,
                  rawTypeRepository: RawTypeRepository,
                  typealiasRepository: TypealiasRepository) -> Method {
    guard !context.specializations.isEmpty else { return self }
    
    // Function-level generic types can shadow class-level generics and shouldn't be specialized.
    let excludedGenericTypeNames = excludedGenericTypeNames.union(genericTypes.map({ $0.name }))
    
    // Specialize return type.
    let declaredType = DeclaredType(from: returnTypeName)
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
    let specializedReturnTypeName = declaredType.serialize(with: qualifiedTypeNameRequest)
    
    // Specialize parameters.
    let specializedParameters = parameters.map({
      $0.specialize(using: context,
                    moduleNames: moduleNames,
                    genericTypeContext: genericTypeContext,
                    excludedGenericTypeNames: excludedGenericTypeNames,
                    rawTypeRepository: rawTypeRepository,
                    typealiasRepository: typealiasRepository)
    })
    
    return Method(from: self,
                  returnTypeName: specializedReturnTypeName,
                  parameters: specializedParameters)
  }
}

private extension String {
  func extractArgumentLabels() -> (shortName: String, labels: [String?]) {
    guard let startIndex = firstIndex(of: "("),
      let stopIndex = firstIndex(of: ")") else { return (self, []) }
    let shortName = self[..<startIndex].trimmingCharacters(in: .whitespacesAndNewlines)
    let arguments = self[index(after: startIndex)..<stopIndex]
    let labels = arguments
      .substringComponents(separatedBy: ":")
      .map({ $0 != "_" ? String($0) : nil })
    return (shortName, labels)
  }
}
