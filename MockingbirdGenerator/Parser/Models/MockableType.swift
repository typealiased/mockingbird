//
//  MockableType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

/// Classes, protocols, and extensions on either.
class MockableType: Hashable, Comparable {
  let name: String
  let moduleName: String
  let fullyQualifiedModuleName: String
  let accessLevel: AccessLevel?
  let kind: SwiftDeclarationKind
  let methods: Set<Method>
  let methodsCount: [Method.Reduced: UInt] // For de-duping generic methods.
  let variables: Set<Variable>
  let inheritedTypes: Set<MockableType>
  let allInheritedTypeNames: [String] // Includes opaque inherited types, in declaration order.
  let selfConformanceTypes: Set<MockableType>
  let allSelfConformanceTypeNames: [String] // Includes opaque conformance type names.
  let genericTypes: [GenericType]
  let whereClauses: [WhereClause]
  let shouldMock: Bool
  let attributes: Attributes
  var compilationDirectives: [CompilationDirective]
  var containedTypes = [MockableType]()
  let isContainedType: Bool
  let subclassesExternalType: Bool
  let hasOpaqueInheritedType: Bool
  let hasSelfConstraint: Bool
  
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
        hasOpaqueInheritedType: Bool,
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
    self.fullyQualifiedModuleName = baseRawType.fullyQualifiedModuleName
    self.accessLevel = baseRawType.accessLevel
    self.kind = baseRawType.kind
    self.isContainedType = !baseRawType.containingTypeNames.isEmpty
    self.hasOpaqueInheritedType = hasOpaqueInheritedType
    
    // Parse top-level declared methods and variables.
    var (methods, variables) = MockableType
      .parseDeclaredTypes(rawTypes: rawTypes,
                          baseRawType: baseRawType,
                          moduleNames: moduleNames,
                          rawTypeRepository: rawTypeRepository,
                          typealiasRepository: typealiasRepository)
    
    // Parse top-level declared generics.
    var genericTypes = substructure
      .compactMap({ structure -> GenericType? in
        guard let genericType = GenericType(from: structure,
                                            rawType: baseRawType,
                                            moduleNames: moduleNames,
                                            rawTypeRepository: rawTypeRepository) else { return nil }
        return genericType
      })
    var whereClauses = genericTypes.flatMap({ $0.whereClauses })

    let source = baseRawType.parsedFile.data
    if let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: baseRawType.dictionary,
                                                                   contents: source),
      let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression) {
      let topLevelClauses = nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
        .components(separatedBy: ",", excluding: .allGroups)
        .compactMap({ WhereClause(from: String($0)) })
        .map({ GenericType.qualifyWhereClause($0,
                                              containingType: baseRawType,
                                              moduleNames: moduleNames,
                                              rawTypeRepository: rawTypeRepository) })
        .filter({
          // Superclass `Self` conformance must be done through the inheritance syntax.
          $0.constrainedTypeName
            .contains(SerializationRequest.Constants.selfTokenIndicator) == false
        })
      whereClauses.append(contentsOf: topLevelClauses)
    }
    
    // Parse inherited members and generics.
    let rawInheritedTypeNames = rawTypes
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
      .compactMap({ $0[SwiftDocKey.name.rawValue] as? String })
    let (inheritedTypes, _, allInheritedTypeNames, subclassesExternalType) =
      MockableType
        .parseInheritedTypes(rawInheritedTypeNames: rawInheritedTypeNames,
                             forConformance: false,
                             methods: &methods,
                             variables: &variables,
                             genericTypes: &genericTypes,
                             whereClauses: &whereClauses,
                             mockableTypes: mockableTypes,
                             moduleNames: moduleNames,
                             baseRawType: baseRawType,
                             rawTypeRepository: rawTypeRepository,
                             typealiasRepository: typealiasRepository)
    self.inheritedTypes = inheritedTypes
    self.allInheritedTypeNames = allInheritedTypeNames
    
    let rawConformanceTypeNames = baseRawType.selfConformanceTypeNames
      .union(Set(inheritedTypes.flatMap({ $0.allSelfConformanceTypeNames })))
    let (_, allSelfConformanceTypes, allSelfConformanceTypeNames, conformsToExternalType) =
      MockableType
        .parseInheritedTypes(rawInheritedTypeNames: Array(rawConformanceTypeNames),
                             forConformance: true,
                             methods: &methods,
                             variables: &variables,
                             genericTypes: &genericTypes,
                             whereClauses: &whereClauses,
                             mockableTypes: mockableTypes,
                             moduleNames: moduleNames,
                             baseRawType: baseRawType,
                             rawTypeRepository: rawTypeRepository,
                             typealiasRepository: typealiasRepository)
    self.selfConformanceTypes = allSelfConformanceTypes
    self.allSelfConformanceTypeNames = allSelfConformanceTypeNames
    
    self.subclassesExternalType = subclassesExternalType || conformsToExternalType
    self.methods = methods
    self.variables = variables
    
    self.shouldMock = baseRawType.parsedFile.shouldMock
    
    var methodsCount = [Method.Reduced: UInt]()
    methods.forEach({ methodsCount[Method.Reduced(from: $0), default: 0] += 1 })
    self.methodsCount = methodsCount
    
    self.genericTypes = genericTypes
    self.whereClauses = whereClauses
    
    // Parse any containing preprocessor macros.
    if let offset = baseRawType.dictionary[SwiftDocKey.offset.rawValue] as? Int64 {
      self.compilationDirectives = baseRawType.parsedFile.compilationDirectives.filter({
        $0.range.contains(offset)
      })
    } else {
      self.compilationDirectives = []
    }
    
    // Check if any of the members have `Self` constraints.
    self.hasSelfConstraint = whereClauses.contains(where: { $0.hasSelfConstraint })
      || methods.contains(where: { $0.hasSelfConstraint })
      || variables.contains(where: { $0.hasSelfConstraint })
      || genericTypes.contains(where: { $0.hasSelfConstraint })
    
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
  
  private static func parseDeclaredTypes(rawTypes: [RawType],
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
  
  // TODO: Supporting protocol `Self` conformance has bloated this function. Needs a refactor soon.
  private static func parseInheritedTypes(rawInheritedTypeNames: [String],
                                          forConformance: Bool,
                                          methods: inout Set<Method>,
                                          variables: inout Set<Variable>,
                                          genericTypes: inout [GenericType],
                                          whereClauses: inout [WhereClause],
                                          mockableTypes: [String: MockableType],
                                          moduleNames: [String],
                                          baseRawType: RawType,
                                          rawTypeRepository: RawTypeRepository,
                                          typealiasRepository: TypealiasRepository)
    
    -> (inheritedTypes: Set<MockableType>, // Directly inherited types
    allInheritedTypes: Set<MockableType>, // Includes ancestor inheritance
    allInheritedTypeNames: [String], // Includes ancestor inheritance and opaque type names
    subclassesExternalType: Bool) {
      
      var inheritedTypes = Set<MockableType>()
      var allInheritedTypes = Set<MockableType>()
      var allInheritedTypeNames = [String]()
      var subclassesExternalType = false
      let definesDesignatedInitializer = methods.contains(where: { $0.isDesignatedInitializer })
      
      // Find the correct `MockableType` instances for inheritance based on type name.
      let parsedInheritedTypes = rawInheritedTypeNames.flatMap({ typeName -> [MockableType] in
        guard let nearestRawType = rawTypeRepository
          .nearestInheritedType(named: typeName,
                                trimmedName: typeName.removingGenericTyping(),
                                moduleNames: moduleNames,
                                referencingModuleName: baseRawType.parsedFile.moduleName,
                                containingTypeNames: baseRawType.containingTypeNames[...])?
          .findBaseRawType() else {
            allInheritedTypeNames.append(typeName)
            return []
        }
        
        allInheritedTypeNames.append(nearestRawType.fullyQualifiedModuleName)
        
        // Inherited types could be typealiased, which would hide conformance.
        guard nearestRawType.kind == .typealias else {
          guard let mockableType = mockableTypes[nearestRawType.fullyQualifiedModuleName] else {
            return []
          }
          return [mockableType]
        }
        
        // Resolve typealias to fully qualified root type name.
        let actualTypeNames = typealiasRepository
          .actualTypeNames(for: nearestRawType.fullyQualifiedModuleName,
                           rawTypeRepository: rawTypeRepository,
                           moduleNames: moduleNames,
                           referencingModuleName: baseRawType.parsedFile.moduleName,
                           containingTypeNames: baseRawType.containingTypeNames[...])
        
        // Resolve fully qualified root type name to raw type.
        return actualTypeNames.compactMap({
          guard let nearestRawType = rawTypeRepository
            .nearestInheritedType(named: $0,
                                  trimmedName: $0.removingGenericTyping(),
                                  moduleNames: moduleNames,
                                  referencingModuleName: baseRawType.parsedFile.moduleName,
                                  containingTypeNames: baseRawType.containingTypeNames[...])?
            .findBaseRawType() else { return nil }
          return mockableTypes[nearestRawType.fullyQualifiedModuleName]
        })
      })

      // Merge all inheritable members from the `MockableType` instances.
      for mockableType in parsedInheritedTypes {
        if baseRawType.kind == .class
          && mockableType.kind == .class
          && mockableType.moduleName != baseRawType.parsedFile.moduleName {
          subclassesExternalType = true
        }
        
        let shouldInheritFromType = baseRawType.kind != .class || mockableType.kind != .protocol
        
        methods = methods.union(mockableType.methods.filter({
          guard shouldInheritFromType || $0.attributes.contains(.implicit) else { return false }
          return $0.kind.typeScope.isMockable(in: baseRawType.kind) &&
            // Mocking a subclass with designated initializers shouldn't inherit the superclass'
            // initializers.
            (baseRawType.kind == .protocol || !definesDesignatedInitializer || !$0.isInitializer)
        }))
        variables = variables.union(mockableType.variables.filter({
          guard shouldInheritFromType || $0.attributes.contains(.implicit) else { return false }
          return $0.kind.typeScope.isMockable(in: baseRawType.kind)
        }))
        
        // Classes must already implement generic constraints from protocols they conform to.
        guard shouldInheritFromType else { continue }
        
        let inherited = forConformance
          ? mockableType.selfConformanceTypes : mockableType.inheritedTypes
        inheritedTypes.insert(mockableType)
        allInheritedTypes.formUnion([mockableType] + inherited)
        allInheritedTypeNames.append(contentsOf: inherited.map({ $0.fullyQualifiedModuleName }))
        
        let uniqueGenericTypes = Set<String>(genericTypes.map({ $0.name }))
        genericTypes.append(contentsOf: mockableType.genericTypes.filter({
          !uniqueGenericTypes.contains($0.name)
        }))
        whereClauses.append(contentsOf: mockableType.whereClauses)
      }
      return (inheritedTypes, allInheritedTypes, allInheritedTypeNames, subclassesExternalType)
  }
}
