//
//  MockableType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework
import PathKit

/// Classes, protocols, and extensions on either.
class MockableType: Hashable, Comparable {
  let name: String
  let moduleName: String
  let fullyQualifiedName: String
  let fullyQualifiedModuleName: String
  let kind: SwiftDeclarationKind
  let accessLevel: AccessLevel
  let methods: Set<Method>
  let methodsCount: [Method.Reduced: UInt] // For de-duping generic methods.
  let variables: Set<Variable>
  let inheritedTypes: Set<MockableType>
  let allInheritedTypeNames: [String] // Includes opaque inherited types, in declaration order.
  let opaqueInheritedTypeNames: Set<String>
  let selfConformanceTypes: Set<MockableType> // Types for `Self` constrained protocols.
  let allSelfConformanceTypeNames: [String] // Includes opaque conformance type names.
  let primarySelfConformanceType: MockableType? // Guaranteed to be a class conformance.
  let primarySelfConformanceTypeName: String? // Specialized based on declared inheritance.
  let genericTypeContext: [[String]] // Generic type names defined by containing types.
  let genericTypes: [GenericType] // Generic type declarations are ordered.
  let whereClauses: Set<WhereClause>
  let shouldMock: Bool
  let attributes: Attributes
  var compilationDirectives: [CompilationDirective]
  var containedTypes = [MockableType]()
  let isContainedType: Bool
  let isInGenericContainingType: Bool
  let subclassesExternalType: Bool
  let hasSelfConstraint: Bool
  
  enum Constants {
    static let automaticInheritanceMap: [String: (moduleName: String, typeName: String)] = [
      "Foundation.NSObjectProtocol": (moduleName: "Foundation", typeName: "NSObject"),
    ]
  }
  
  // MARK: Diagnostics
  
  private let baseRawType: RawType
  let filePath: Path
  lazy var lineNumber: Int? = {
    return SourceSubstring.key
      .extractLinesNumbers(from: baseRawType.dictionary,
                           contents: baseRawType.parsedFile.file.contents)?.start
  }()
  
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
        specializationContexts: [String: SpecializationContext],
        opaqueInheritedTypeNames: Set<String>,
        rawTypeRepository: RawTypeRepository,
        typealiasRepository: TypealiasRepository) {
    guard let baseRawType = rawTypes.findBaseRawType(),
      baseRawType.kind.isMockable
      else { return nil }
    self.baseRawType = baseRawType
    self.filePath = baseRawType.parsedFile.path
    
    let accessLevel = AccessLevel(from: baseRawType.dictionary) ?? .defaultLevel
    guard accessLevel.isMockableType(withinSameModule: baseRawType.parsedFile.shouldMock)
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
    self.fullyQualifiedName = baseRawType.fullyQualifiedName
    self.fullyQualifiedModuleName = DeclaredType(from: baseRawType.fullyQualifiedModuleName)
      .serialize(
        with: SerializationRequest(
          method: .moduleQualified,
          context: SerializationRequest.Context(
            moduleNames: moduleNames,
            rawType: baseRawType,
            rawTypeRepository: rawTypeRepository),
          options: .standard))
    self.kind = baseRawType.kind
    self.accessLevel = accessLevel
    self.isContainedType = !baseRawType.containingTypeNames.isEmpty
    self.shouldMock = baseRawType.parsedFile.shouldMock
    self.genericTypeContext = baseRawType.genericTypeContext
    self.isInGenericContainingType = baseRawType.genericTypeContext.contains(where: { !$0.isEmpty })
    
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
    let selfConstraintClauses: [WhereClause]

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
      // Note: Superclass `Self` conformance must be done through the inheritance syntax, which is
      // passed via `selfConformanceTypes`.
      whereClauses.append(contentsOf: topLevelClauses.filter({ !$0.hasSelfConstraint }))
      selfConstraintClauses = topLevelClauses.filter({ $0.hasSelfConstraint })
    } else {
      selfConstraintClauses = []
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
                             selfConstraintClauses: selfConstraintClauses,
                             mockableTypes: mockableTypes,
                             moduleNames: moduleNames,
                             genericTypeContext: genericTypeContext,
                             specializationContexts: specializationContexts,
                             baseRawType: baseRawType,
                             rawTypeRepository: rawTypeRepository,
                             typealiasRepository: typealiasRepository)
    self.inheritedTypes = inheritedTypes
    self.allInheritedTypeNames = allInheritedTypeNames
    self.opaqueInheritedTypeNames = opaqueInheritedTypeNames
      .union(Set(inheritedTypes.flatMap({ $0.opaqueInheritedTypeNames })))

    // Parse protocol `Self` conformance.
    let rawConformanceTypeNames = baseRawType.kind == .protocol ?
      baseRawType.selfConformanceTypeNames.union(
        Set(inheritedTypes.map({ $0.fullyQualifiedModuleName }))
      ) : []
    let (_, allSelfConformanceTypes, allSelfConformanceTypeNames, conformsToExternalType) =
      MockableType
        .parseInheritedTypes(rawInheritedTypeNames: Array(rawConformanceTypeNames),
                             forConformance: true,
                             methods: &methods,
                             variables: &variables,
                             genericTypes: &genericTypes,
                             whereClauses: &whereClauses,
                             selfConstraintClauses: selfConstraintClauses,
                             mockableTypes: mockableTypes,
                             moduleNames: moduleNames,
                             genericTypeContext: genericTypeContext,
                             specializationContexts: specializationContexts,
                             baseRawType: baseRawType,
                             rawTypeRepository: rawTypeRepository,
                             typealiasRepository: typealiasRepository)
    self.selfConformanceTypes = allSelfConformanceTypes
    self.allSelfConformanceTypeNames = allSelfConformanceTypeNames
    
    if let inheritedPrimaryType =
      inheritedTypes.sorted() // e.g. `protocol MyProtocol: ClassOnlyProtocol`
        .first(where: { $0.primarySelfConformanceType != nil }) ??
      allSelfConformanceTypes.sorted() // e.g. `protocol MyProtocol where Self: ClassOnlyProtocol`
        .first(where: { $0.primarySelfConformanceType != nil }),
      let primarySelfConformanceType = inheritedPrimaryType.primarySelfConformanceType,
      let primarySelfConformanceTypeName = inheritedPrimaryType.primarySelfConformanceTypeName {
      
      self.primarySelfConformanceType = primarySelfConformanceType
      self.primarySelfConformanceTypeName = primarySelfConformanceTypeName

    } else if let primaryType = allSelfConformanceTypes.sorted()
      .first(where: { $0.kind == .class }) {
      self.primarySelfConformanceType = primaryType
      self.primarySelfConformanceTypeName = MockableType
        .specializedSelfConformanceTypeName(primaryType,
                                            specializationContexts: specializationContexts,
                                            moduleNames: moduleNames,
                                            baseRawType: baseRawType,
                                            rawTypeRepository: rawTypeRepository,
                                            typealiasRepository: typealiasRepository)

    } else {
      self.primarySelfConformanceType = nil
      self.primarySelfConformanceTypeName = nil
    }
    
    self.subclassesExternalType = subclassesExternalType || conformsToExternalType
    self.methods = methods
    self.variables = variables
    
    var methodsCount = [Method.Reduced: UInt]()
    methods.forEach({ methodsCount[Method.Reduced(from: $0), default: 0] += 1 })
    self.methodsCount = methodsCount
    
    self.genericTypes = genericTypes
    self.whereClauses = Set(whereClauses)
    
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
        // Cannot override declarations in extensions as they are statically defined.
        guard rawType.kind != .extension else { continue }
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
                                          selfConstraintClauses: [WhereClause],
                                          mockableTypes: [String: MockableType],
                                          moduleNames: [String],
                                          genericTypeContext: [[String]],
                                          specializationContexts: [String: SpecializationContext],
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
      
      let resolveRawType: (String) -> RawType? = { typeName in
        guard let nearestRawType = rawTypeRepository
          .nearestInheritedType(named: typeName,
                                trimmedName: typeName.removingGenericTyping(),
                                moduleNames: moduleNames,
                                referencingModuleName: baseRawType.parsedFile.moduleName,
                                containingTypeNames: baseRawType.containingTypeNames[...])?
          .findBaseRawType() else { return nil }
        
        // Map unmockable inherited types to other types.
        if baseRawType.kind == .protocol,
          let mappedType = MockableType.Constants.automaticInheritanceMap[
            nearestRawType.fullyQualifiedModuleName
          ],
          let mappedRawType = rawTypeRepository.rawType(named: mappedType.typeName,
                                                        in: mappedType.moduleName) {
          return mappedRawType.findBaseRawType()
        }
        
        return nearestRawType
      }
      
      // Find the correct `MockableType` instances for inheritance based on type name.
      let parsedInheritedTypes = rawInheritedTypeNames.flatMap({ typeName -> [MockableType] in
        guard let nearestRawType = resolveRawType(typeName) else {
          log("Unable to resolve inherited type \(typeName.singleQuoted) for \(baseRawType.name.singleQuoted)")
          allInheritedTypeNames.append(typeName)
          return []
        }
        
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
        
        let shouldInheritFromType = baseRawType.kind == .protocol || mockableType.kind != .protocol
        let specializationContext = specializationContexts[mockableType.fullyQualifiedModuleName]
        
        methods = methods.union(mockableType.methods
          .filter({ method in
            let isImplicitlySynthesized = method.attributes.contains(.implicit)
            guard shouldInheritFromType || isImplicitlySynthesized else { return false }
            return method.kind.typeScope.isMockable(in: baseRawType.kind) &&
              // Mocking a subclass with designated initializers shouldn't inherit the superclass'
              // initializers.
              (baseRawType.kind == .protocol
                || isImplicitlySynthesized
                || !definesDesignatedInitializer
                || !method.isInitializer)
          })
          .map({ method in // Specialize methods from generic types.
            guard let context = specializationContext else { return method }
            return method.specialize(using: context,
                                     moduleNames: moduleNames,
                                     genericTypeContext: genericTypeContext,
                                     excludedGenericTypeNames: [],
                                     rawTypeRepository: rawTypeRepository,
                                     typealiasRepository: typealiasRepository)
          })
        )
        variables = variables.union(mockableType.variables
          .filter({ variable in
            guard shouldInheritFromType || variable.attributes.contains(.implicit)
              else { return false }
            return variable.kind.typeScope.isMockable(in: baseRawType.kind)
          })
          .map({ variable in // Specialize variables from generic types.
            guard let context = specializationContext else { return variable }
            return variable.specialize(using: context,
                                       moduleNames: moduleNames,
                                       genericTypeContext: genericTypeContext,
                                       excludedGenericTypeNames: [],
                                       rawTypeRepository: rawTypeRepository,
                                       typealiasRepository: typealiasRepository)
          })
        )
        
        // Classes must already implement generic constraints from protocols they conform to.
        guard shouldInheritFromType else { continue }
        
        inheritedTypes.insert(mockableType)
        
        // Indirect inheritance.
        if !forConformance {
          allInheritedTypes.formUnion(mockableType.inheritedTypes)
          allInheritedTypeNames.append(contentsOf: mockableType.allInheritedTypeNames)
        } else {
          allInheritedTypes.formUnion(mockableType.selfConformanceTypes)
          allInheritedTypeNames.append(contentsOf: mockableType.allSelfConformanceTypeNames)
        }
        
        let isSelfConstraintType = selfConstraintClauses.contains(where: {
          $0.constrainedTypeName == mockableType.fullyQualifiedModuleName
            || $0.genericConstraint == mockableType.fullyQualifiedModuleName
        })
        let shouldIncludeInheritedType = !forConformance ||
          forConformance && (isSelfConstraintType || mockableType.kind == .class)
        if shouldIncludeInheritedType {
          allInheritedTypes.insert(mockableType)
          allInheritedTypeNames.append(MockableType.specializedSelfConformanceTypeName(
            mockableType,
            specializationContexts: specializationContexts,
            moduleNames: moduleNames,
            baseRawType: baseRawType,
            rawTypeRepository: rawTypeRepository,
            typealiasRepository: typealiasRepository
          ))
        }

        // Only bubble-up generics for protocols from inherited protocols.
        if baseRawType.kind == .protocol && mockableType.kind == .protocol {
          let uniqueGenericTypes = Set<String>(genericTypes.map({ $0.name }))
          genericTypes.append(contentsOf: mockableType.genericTypes.filter({
            !uniqueGenericTypes.contains($0.name)
          }))
          whereClauses.append(contentsOf: mockableType.whereClauses)
        }
      }
      return (inheritedTypes, allInheritedTypes, allInheritedTypeNames, subclassesExternalType)
  }
  
  private static func specializedSelfConformanceTypeName(
    _ type: MockableType,
    specializationContexts: [String: SpecializationContext],
    moduleNames: [String],
    baseRawType: RawType,
    rawTypeRepository: RawTypeRepository,
    typealiasRepository: TypealiasRepository
  ) -> String {
    guard !type.genericTypes.isEmpty, !specializationContexts.isEmpty,
      let context = specializationContexts[type.fullyQualifiedModuleName]
      else { return type.fullyQualifiedModuleName }
    
    let specializedGenericTypes = context.typeList.map({ specialization -> String in
      let serializationContext = SerializationRequest
        .Context(moduleNames: moduleNames,
                 rawType: baseRawType,
                 rawTypeRepository: rawTypeRepository,
                 typealiasRepository: typealiasRepository)
      let qualifiedTypeNameRequest = SerializationRequest(method: .moduleQualified,
                                                          context: serializationContext,
                                                          options: .standard)
      return specialization.serialize(with: qualifiedTypeNameRequest)
    })
    
    let specializedTypeName = type.fullyQualifiedModuleName.removingGenericTyping() +
      "<" + specializedGenericTypes.joined(separator: ", ") + ">"
    return specializedTypeName
  }
}
