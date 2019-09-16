//
//  MockableType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

/// Methods, variables, extensions
class MockableType: Hashable, Comparable {
  let name: String
  let moduleName: String
  let kind: SwiftDeclarationKind
  let methods: Set<Method>
  let methodsCount: [Method.Reduced: UInt] // For de-duping generic methods.
  let variables: Set<Variable>
  let inheritedTypes: Set<MockableType>
  let genericTypes: [GenericType]
  let whereClauses: [WhereClause]
  let shouldMock: Bool
  let attributes: Attributes
  var containedTypes = [MockableType]()
  let isContainedType: Bool
  let subclassesExternalType: Bool
  
  private let sortableIdentifier: String
  static func < (lhs: MockableType, rhs: MockableType) -> Bool {
    return lhs.sortableIdentifier < rhs.sortableIdentifier
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(sortableIdentifier)
  }
  
  static func == (lhs: MockableType, rhs: MockableType) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  /// Creates a `MockableType` from a set of partial `RawType` objects.
  ///
  /// - Parameters:
  ///   - rawTypes: A set of partial `RawType` objects that should include the base declaration.
  ///   - mockableTypes: All currently known `MockableType` objects used for inheritance flattening.
  init?(from rawTypes: [RawType],
        mockableTypes: [String: MockableType],
        moduleNames: [String],
        rawTypeRepository: RawTypeRepository,
        typealiasRepository: TypealiasRepository) {
    guard let baseRawType = rawTypes.findBaseRawType(),
      baseRawType.kind.isMockable,
      let accessLevel = AccessLevel(from: baseRawType.dictionary),
      accessLevel.isMockableType(withinSameModule: baseRawType.parsedFile.shouldMock)
      else { return nil }
    // Handle empty types (declared without any members).
    let substructure = baseRawType.dictionary[SwiftDocKey.substructure.rawValue]
      as? [StructureDictionary] ?? []
    
    var attributes = Attributes()
    rawTypes.forEach({ attributes.formUnion(Attributes(from: $0.dictionary)) })
    self.attributes = attributes
    guard !attributes.contains(.final) else { return nil }
    
    self.name = baseRawType.name
    self.moduleName = baseRawType.parsedFile.moduleName
    self.kind = baseRawType.kind
    self.isContainedType = !baseRawType.containingTypeNames.isEmpty
    
    // Parse top-level declared methods and variables.
    var (methods, variables) = MockableType
      .parseDeclaredTypes(rawTypes: rawTypes,
                          baseRawType: baseRawType,
                          moduleNames: moduleNames,
                          rawTypeRepository: rawTypeRepository,
                          typealiasRepository: typealiasRepository)
    
    // Parse top-level declared generics.
    var genericTypes = substructure.compactMap({ structure -> GenericType? in
      guard let genericType = GenericType(from: structure,
                                          rawType: baseRawType,
                                          moduleNames: moduleNames,
                                          rawTypeRepository: rawTypeRepository) else { return nil }
      return genericType
    })
    var whereClauses = genericTypes.flatMap({ $0.whereClauses })
    if baseRawType.kind == .class {
      let source = baseRawType.parsedFile.data
      if let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: baseRawType.dictionary,
                                                                     contents: source),
        let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression) {
        let topLevelClauses = nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
          .components(separatedBy: ",")
          .compactMap({ WhereClause(from: $0) })
        whereClauses.append(contentsOf: topLevelClauses)
      }
    }
    
    // Parse inherited members and generics.
    let rawInheritedTypes = rawTypes
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
    let (inheritedTypes, subclassesExternalType) = MockableType
      .parseInheritedTypes(rawInheritedTypes: rawInheritedTypes,
                           methods: &methods,
                           variables: &variables,
                           genericTypes: &genericTypes,
                           whereClauses: &whereClauses,
                           mockableTypes: mockableTypes,
                           moduleNames: moduleNames,
                           baseRawType: baseRawType,
                           rawTypeRepository: rawTypeRepository)
    self.inheritedTypes = inheritedTypes
    self.subclassesExternalType = subclassesExternalType
    self.methods = methods
    self.variables = variables
    
    self.shouldMock = baseRawType.parsedFile.shouldMock
    
    var methodsCount = [Method.Reduced: UInt]()
    methods.forEach({ methodsCount[Method.Reduced(from: $0), default: 0] += 1 })
    self.methodsCount = methodsCount
    
    self.genericTypes = genericTypes
    self.whereClauses = whereClauses
    
    if baseRawType.parsedFile.shouldMock {
      self.sortableIdentifier = [
        self.name,
        self.genericTypes.map({ "\($0.name):\($0.constraints)" }).joined(separator: ","),
        self.whereClauses.map({ "\($0)" }).joined(separator: ",")
      ].joined(separator: "|")
    } else {
      self.sortableIdentifier = name
    }
  }
  
  @inlinable
  static func parseDeclaredTypes(rawTypes: [RawType],
                                 baseRawType: RawType,
                                 moduleNames: [String],
                                 rawTypeRepository: RawTypeRepository,
                                 typealiasRepository: TypealiasRepository)
    -> (methods: Set<Method>, variables: Set<Variable>) {
      var methods = Set<Method>()
      var variables = Set<Variable>()
      for rawType in rawTypes {
        guard let substructure = rawType.dictionary[SwiftDocKey.substructure.rawValue]
          as? [StructureDictionary] else { continue }
        // Cannot override declarations in extensions for classes.
        guard baseRawType.kind != .class || rawType.kind != .extension else { continue }
        for structure in substructure {
          if let method = Method(from: structure,
                                 rootKind: baseRawType.kind,
                                 rawType: rawType,
                                 moduleNames: moduleNames,
                                 rawTypeRepository: rawTypeRepository,
                                 typealiasRepository: typealiasRepository) {
            methods.insert(method)
          }
          if let variable = Variable(from: structure,
                                     rootKind: baseRawType.kind,
                                     rawType: rawType,
                                     moduleNames: moduleNames,
                                     rawTypeRepository: rawTypeRepository) {
            variables.insert(variable)
          }
        }
      }
      return (methods, variables)
  }
  
  @inlinable
  static func parseInheritedTypes(rawInheritedTypes: [StructureDictionary],
                                  methods: inout Set<Method>,
                                  variables: inout Set<Variable>,
                                  genericTypes: inout [GenericType],
                                  whereClauses: inout [WhereClause],
                                  mockableTypes: [String: MockableType],
                                  moduleNames: [String],
                                  baseRawType: RawType,
                                  rawTypeRepository: RawTypeRepository)
    -> (inheritedTypes: Set<MockableType>, subclassesExternalType: Bool) {
      var inheritedTypes = Set<MockableType>()
      var subclassesExternalType = false
      let definesDesignatedInitializer = methods.contains(where: { $0.isDesignatedInitializer })
      for type in rawInheritedTypes {
        guard let typeName = type[SwiftDocKey.name.rawValue] as? String,
          let nearestRawType = rawTypeRepository
            .nearestInheritedType(named: typeName,
                                  trimmedName: typeName.removingGenericTyping(),
                                  moduleNames: moduleNames,
                                  referencingModuleName: baseRawType.parsedFile.moduleName,
                                  containingTypeNames: baseRawType.containingTypeNames[...])?
            .findBaseRawType(),
          let mockableType = mockableTypes[nearestRawType.fullyQualifiedModuleName]
          else { continue }
        
        if baseRawType.kind == .class
          && mockableType.kind == .class
          && mockableType.moduleName != baseRawType.parsedFile.moduleName {
          subclassesExternalType = true
        }
        
        // Classes must already implement members in protocols they conform to.
        guard baseRawType.kind != .class || nearestRawType.kind != .protocol else { continue }
        
        methods = methods.union(mockableType.methods.filter({
          $0.kind.typeScope.isMockable(in: baseRawType.kind) &&
            (!definesDesignatedInitializer || !$0.isInitializer)
        }))
        variables = variables.union(mockableType.variables.filter({
          $0.kind.typeScope.isMockable(in: baseRawType.kind)
        }))
        inheritedTypes = inheritedTypes.union([mockableType] + mockableType.inheritedTypes)
        
        genericTypes.append(contentsOf: mockableType.genericTypes)
        whereClauses.append(contentsOf: mockableType.whereClauses)
      }
      return (inheritedTypes, subclassesExternalType)
  }
}
