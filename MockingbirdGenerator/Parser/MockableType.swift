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
struct MockableType: Hashable, Comparable {
  let name: String
  let moduleName: String
  let kind: SwiftDeclarationKind
  let methods: Set<Method>
  let methodsCount: [Method.Reduced: UInt] // For de-duping generic methods.
  let variables: Set<Variable>
  let inheritedTypes: Set<MockableType>
  let genericTypes: [GenericType]
  let genericConstraints: [String]
  let shouldMock: Bool
  let attributes: Attributes
  var containedTypes = [MockableType]()
  let isContainedType: Bool
  
  private let sortableIdentifier: String
  static func < (lhs: MockableType, rhs: MockableType) -> Bool {
    return lhs.sortableIdentifier < rhs.sortableIdentifier
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
      let substructure = baseRawType.dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary],
      let accessLevel = AccessLevel(from: baseRawType.dictionary), accessLevel.isMockable
      else { return nil }
    
    var attributes = Attributes()
    rawTypes.forEach({ attributes.formUnion(Attributes(from: $0.dictionary)) })
    self.attributes = attributes
    guard !attributes.contains(.final) else { return nil }
    
    self.name = baseRawType.name
    self.moduleName = baseRawType.parsedFile.moduleName
    self.kind = baseRawType.kind
    let containingTypeNames = baseRawType.containingTypeNames
    self.isContainedType = !containingTypeNames.isEmpty
    
    var methods = Set<Method>()
    var variables = Set<Variable>()
    var inheritedTypes = Set<MockableType>()
    for rawType in rawTypes {
      guard let substructure = rawType.dictionary[SwiftDocKey.substructure.rawValue]
        as? [StructureDictionary] else { continue }
      // Cannot override declarations in extensions for classes.
      guard baseRawType.kind != .class || rawType.kind != .extension else { continue }
      for structure in substructure {
        if let method = Method(from: structure,
                               rootKind: kind,
                               rawType: rawType,
                               moduleNames: moduleNames,
                               rawTypeRepository: rawTypeRepository,
                               typealiasRepository: typealiasRepository) {
          methods.insert(method)
        }
        if let variable = Variable(from: structure,
                                   rootKind: kind,
                                   rawType: rawType,
                                   moduleNames: moduleNames,
                                   rawTypeRepository: rawTypeRepository) {
          variables.insert(variable)
        }
      }
    }
    let rawInheritedTypes = rawTypes
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
    for type in rawInheritedTypes {
      guard let typeName = type[SwiftDocKey.name.rawValue] as? String,
        let nearestRawType = rawTypeRepository
          .nearestInheritedType(named: typeName,
                                moduleNames: moduleNames,
                                referencingModuleName: moduleName,
                                containingTypeNames: containingTypeNames[...])?.findBaseRawType(),
        let mockableType = mockableTypes[nearestRawType.fullyQualifiedModuleName]
        else { continue }
      methods = methods.union(mockableType.methods.filter({
        $0.kind.typeScope.isMockable(in: baseRawType.kind)
      }))
      variables = variables.union(mockableType.variables.filter({
        $0.kind.typeScope.isMockable(in: baseRawType.kind)
      }))
      inheritedTypes = inheritedTypes.union([mockableType] + mockableType.inheritedTypes)
    }
    self.methods = methods
    self.variables = variables
    self.inheritedTypes = inheritedTypes
    self.shouldMock = baseRawType.parsedFile.shouldMock
    
    var methodsCount = [Method.Reduced: UInt]()
    methods.forEach({ methodsCount[Method.Reduced(from: $0), default: 0] += 1 })
    self.methodsCount = methodsCount
    
    self.genericTypes = substructure.compactMap({ structure -> GenericType? in
      guard let genericType = GenericType(from: structure,
                                          rawType: baseRawType,
                                          moduleNames: moduleNames,
                                          rawTypeRepository: rawTypeRepository) else { return nil }
      return genericType
    })
    
    var genericConstraints = genericTypes.flatMap({ $0.genericConstraints })
    if baseRawType.kind == .class {
      let source = baseRawType.parsedFile.data
      if let nameSuffix = SourceSubstring.nameSuffixUpToBody.extract(from: baseRawType.dictionary,
                                                                     contents: source),
        let whereRange = nameSuffix.range(of: #"\bwhere\b"#, options: .regularExpression) {
        genericConstraints = nameSuffix[whereRange.upperBound..<nameSuffix.endIndex]
          .substringComponents(separatedBy: ",")
          .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
      }
    }
    self.genericConstraints = genericConstraints
    
    if baseRawType.parsedFile.shouldMock {
      self.sortableIdentifier = [
        self.name,
        self.genericTypes.map({ "\($0.name):\($0.inheritedTypes)" }).joined(separator: ","),
        self.genericConstraints.joined(separator: ",")
      ].joined(separator: "|")
    } else {
      self.sortableIdentifier = name
    }
  }
}
