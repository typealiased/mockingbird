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
  private(set) var shouldMock: Bool // Setter used for cloning `MockableType` objects.
  let attributes: Attributes
  private(set) var containedTypes = [MockableType]()
  let isContainedType: Bool
  
  private let sortableIdentifier: String
  static func < (lhs: MockableType, rhs: MockableType) -> Bool {
    return lhs.sortableIdentifier < rhs.sortableIdentifier
  }
  
  /// Creates a `MockableType` from a set of partial `RawType` objects.
  ///
  /// - Parameters:
  ///   - rawTypes: A set of partial `RawType` objects that should include the base declaration.
  ///   - mockableTypes: All currently known `MockableType` objects used for inheritence flattening.
  init?(from rawTypes: [RawType],
        mockableTypes: [String: MockableType],
        isContainedType: Bool = false) {
    guard let baseRawType = rawTypes.first(where: { $0.kind.isMockable }),
      let substructure = baseRawType.dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary],
      let accessLevel = AccessLevel(from: baseRawType.dictionary), accessLevel.isMockable
      else { return nil }
    
    var attributes = Attributes()
    rawTypes.forEach({ attributes.formUnion(Attributes.create(from: $0.dictionary)) })
    self.attributes = attributes
    guard !attributes.contains(.final) else { return nil }
    
    self.name = baseRawType.name
    self.moduleName = baseRawType.parsedFile.moduleName
    self.kind = baseRawType.kind
    var methods = Set<Method>()
    var variables = Set<Variable>()
    var inheritedTypes = Set<MockableType>()
    for rawType in rawTypes {
      guard let substructure = rawType.dictionary[SwiftDocKey.substructure.rawValue]
        as? [StructureDictionary] else { continue }
      // Cannot override declarations in extensions for classes.
      guard baseRawType.kind != .class || rawType.kind != .extension else { continue }
      for structure in substructure {
        if let method = Method(from: structure, rootKind: kind, rawType: rawType) {
          methods.insert(method)
        }
        if let variable = Variable(from: structure, rootKind: kind, rawType: rawType) {
          variables.insert(variable)
        }
      }
    }
    let rawInheritedTypes = rawTypes
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
    for type in rawInheritedTypes {
      guard let typeName = type[SwiftDocKey.name.rawValue] as? String,
        let mockableType = mockableTypes[typeName] else { continue }
      methods = methods.union(mockableType.methods)
      variables = variables.union(mockableType.variables)
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
      guard let genericType = GenericType(from: structure, rawType: baseRawType) else { return nil }
      return genericType
    })
    
    var genericConstraints = [String]()
    if baseRawType.kind == .class {
      let source = baseRawType.parsedFile.file.contents
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
    
    // Contained types can inherit from their containing types!
    self.isContainedType = isContainedType
    var attributedMockableTypes = mockableTypes
    attributedMockableTypes[self.name] = self
    self.containedTypes = rawTypes
      .flatMap({ $0.containedTypes })
      .compactMap({ MockableType(from: [$0],
                                 mockableTypes: attributedMockableTypes,
                                 isContainedType: true) })
  }
  
  static func clone(_ other: MockableType, shouldMock: Bool) -> MockableType {
    var clone = other
    clone.shouldMock = shouldMock
    return clone
  }
}
