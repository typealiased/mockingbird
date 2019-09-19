//
//  Method.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct Method: Hashable, Comparable {
  let name: String
  let shortName: String
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
  
  /// A hashable version of Method that's unique according to Swift generics when subclassing.
  /// https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
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
    hasher.combine(whereClauses)
    hasher.combine(parameters)
  }
  
  static func ==(lhs: Method, rhs: Method) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  private var sortableIdentifier: String
  static func < (lhs: Method, rhs: Method) -> Bool {
    return lhs.sortableIdentifier < rhs.sortableIdentifier
  }
  
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
    
    guard let accessLevel = AccessLevel(from: dictionary),
      accessLevel.isMockableMember(in: rootKind, withinSameModule: rawType.parsedFile.shouldMock)
        || isInitializer && accessLevel.isMockable // Initializers cannot be `open`.
      else { return nil }
    self.accessLevel = accessLevel
    
    let source = rawType.parsedFile.data
    let attributes = Attributes(from: dictionary, source: source)
    guard !attributes.contains(.final) else { return nil }
    self.isDesignatedInitializer = isInitializer && !attributes.contains(.convenience)
    
    let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] ?? []
    self.kind = kind
    
    // Parse declared attributes and parameters.
    let rawParametersDeclaration: Substring?
    (self.attributes,
     rawParametersDeclaration) = Method.parseDeclaration(from: dictionary,
                                                         source: source,
                                                         isInitializer: self.isInitializer,
                                                         attributes: attributes)
    
    // Parse return type.
    self.returnTypeName = Method.parseReturnTypeName(from: dictionary,
                                                     rawType: rawType,
                                                     moduleNames: moduleNames,
                                                     rawTypeRepository: rawTypeRepository,
                                                     typealiasRepository: typealiasRepository)
    
    // Parse generic type constraints and where clauses.
    self.whereClauses = Method.parseWhereClauses(from: dictionary,
                                                 source: source,
                                                 rawType: rawType,
                                                 moduleNames: moduleNames,
                                                 rawTypeRepository: rawTypeRepository)
    self.genericTypes = substructure.compactMap({ structure -> GenericType? in
      guard let genericType = GenericType(from: structure,
                                          rawType: rawType,
                                          moduleNames: moduleNames,
                                          rawTypeRepository: rawTypeRepository) else { return nil }
      return genericType
    })
    
    // Parse parameters.
    let (shortName, labels) = name.extractArgumentLabels()
    self.shortName = shortName
    self.parameters = Method.parseParameters(labels: labels,
                                             substructure: substructure,
                                             rawParametersDeclaration: rawParametersDeclaration,
                                             rawType: rawType,
                                             moduleNames: moduleNames,
                                             rawTypeRepository: rawTypeRepository,
                                             typealiasRepository: typealiasRepository)
    
    // Parse any containing preprocessor macros.
    if let offset = dictionary[SwiftDocKey.offset.rawValue] as? Int64 {
      self.compilationDirectives = rawType.parsedFile.compilationDirectives.filter({
        $0.range.contains(offset)
      })
    } else {
      self.compilationDirectives = []
    }
    
    // Create a unique and sortable identifier for this method.
    self.sortableIdentifier = Method.generateSortableIdentifier(name: name,
                                                                genericTypes: genericTypes,
                                                                parameters: parameters,
                                                                returnTypeName: returnTypeName,
                                                                kind: kind,
                                                                whereClauses: whereClauses)
  }
  
  fileprivate static func generateSortableIdentifier(name: String,
                                                     genericTypes: [GenericType],
                                                     parameters: [MethodParameter],
                                                     returnTypeName: String,
                                                     kind: SwiftDeclarationKind,
                                                     whereClauses: [WhereClause]) -> String {
    return [
      name,
      genericTypes.map({ "\($0.name):\($0.constraints)" }).joined(separator: ","),
      parameters
        .map({ "\($0.argumentLabel ?? ""):\($0.name):\($0.typeName)" })
        .joined(separator: ","),
      returnTypeName,
      kind.typeScope.rawValue,
      whereClauses.map({ "\($0)" }).joined(separator: ",")
    ].joined(separator: "|")
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
        let failable = declaration[declaration.index(before: startIndex)..<startIndex]
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
  
  private static func parseReturnTypeName(from dictionary: StructureDictionary,
                                          rawType: RawType,
                                          moduleNames: [String],
                                          rawTypeRepository: RawTypeRepository,
                                          typealiasRepository: TypealiasRepository) -> String {
    guard let rawReturnTypeName = dictionary[SwiftDocKey.typeName.rawValue] as? String else {
      return "Void"
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
    return declaredType.serialize(with: qualifiedTypeNameRequest)
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
                                            argumentLabel: labels[parameterIndex],
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

extension Method {
  static func createEquatableConformance(for type: MockableType) -> Method {
    let parameters = [MethodParameter(name: "lhs",
                                      argumentLabel: "lhs",
                                      typeName: type.name + "Mock"),
                      MethodParameter(name: "rhs",
                                      argumentLabel: "rhs",
                                      typeName: type.name + "Mock")]
    return Method(name: "== (lhs:rhs:)",
                  returnTypeName: "Bool",
                  parameters: parameters,
                  kind: .functionMethodStatic)
  }
  
  static func createComparableConformance(for type: MockableType) -> Method {
    let parameters = [MethodParameter(name: "lhs",
                                      argumentLabel: "lhs",
                                      typeName: type.name + "Mock"),
                      MethodParameter(name: "rhs",
                                      argumentLabel: "rhs",
                                      typeName: type.name + "Mock")]
    return Method(name: "< (lhs:rhs:)",
                  returnTypeName: "Bool",
                  parameters: parameters,
                  kind: .functionMethodStatic)
  }
  
  static func createHashableConformance() -> Method {
    let parameters = [MethodParameter(name: "hasher",
                                      argumentLabel: "into",
                                      typeName: "inout Hasher",
                                      attributes: [.inout])]
    return Method(name: "hash(into:)", parameters: parameters)
  }
}

fileprivate extension Method {
  init(name: String,
       returnTypeName: String = "Void",
       parameters: [MethodParameter],
       isInitializer: Bool = false,
       isDesignatedInitializer: Bool = false,
       accessLevel: AccessLevel = .public,
       kind: SwiftDeclarationKind = .functionMethodInstance,
       genericTypes: [GenericType] = [],
       whereClauses: [WhereClause] = [],
       attributes: Attributes = []) {
    self.name = name
    (self.shortName, _) = name.extractArgumentLabels()
    self.returnTypeName = returnTypeName
    self.isInitializer = isInitializer
    self.isDesignatedInitializer = isDesignatedInitializer
    self.accessLevel = accessLevel
    self.kind = kind
    self.genericTypes = genericTypes
    self.whereClauses = whereClauses
    self.parameters = parameters
    self.attributes = attributes
    self.compilationDirectives = []
    self.sortableIdentifier = Method.generateSortableIdentifier(name: name,
                                                                genericTypes: genericTypes,
                                                                parameters: parameters,
                                                                returnTypeName: returnTypeName,
                                                                kind: kind,
                                                                whereClauses: whereClauses)
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
