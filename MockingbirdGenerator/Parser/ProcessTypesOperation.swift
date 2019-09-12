//
//  ProcessTypesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

public class ProcessTypesOperation: BasicOperation {
  let parseFilesResult: ParseFilesOperation.Result
  
  public class Result {
    fileprivate(set) var mockableTypes = [MockableType]()
    fileprivate(set) var imports = Set<String>()
  }
  
  public let result = Result()
  let rawTypeRepository = RawTypeRepository()
  let typealiasRepository = TypealiasRepository()
  
  public init(parseFilesResult: ParseFilesOperation.Result) {
    self.parseFilesResult = parseFilesResult
  }
  
  override func run() {
    let queue = OperationQueue.createForActiveProcessors()
    let processStructuresOperations = parseFilesResult.parsedFiles.map({
      ProcessStructuresOperation(structureDictionary: $0.structure.dictionary, parsedFile: $0)
    })
    queue.addOperations(processStructuresOperations, waitUntilFinished: true)
    processStructuresOperations.forEach({
      $0.result.rawTypes.forEach({
        rawTypeRepository.addRawType($0)
        if let typeAlias = Typealias(from: $0) { typealiasRepository.addTypealias(typeAlias) }
      })
    })
    
    let flattenInheritanceOperations = rawTypeRepository.rawTypes
      .flatMap({ $0.value })
      .map({ $0.value })
      .filter({ $0.first(where: { $0.kind.isMockable })?.parsedFile.shouldMock == true })
      .filter({ $0.first?.isContainedType != true })
      .map({ FlattenInheritanceOperation(rawType: $0,
                                         moduleDependencies: parseFilesResult.moduleDependencies,
                                         rawTypeRepository: rawTypeRepository,
                                         typealiasRepository: typealiasRepository) })
    queue.addOperations(flattenInheritanceOperations, waitUntilFinished: true)
    result.mockableTypes = flattenInheritanceOperations
      .compactMap({ $0.result.mockableType })
      .filter({ !$0.isContainedType })
    result.imports = parseFilesResult.imports
  }
}

private class ProcessStructuresOperation: BasicOperation {
  let structureDictionary: StructureDictionary
  let parsedFile: ParsedFile
  
  class Result {
    fileprivate(set) var rawTypes = [RawType]()
  }
  
  let result = Result()
  
  init(structureDictionary: StructureDictionary, parsedFile: ParsedFile) {
    self.structureDictionary = structureDictionary
    self.parsedFile = parsedFile
  }
  
  override func run() throws {
    result.rawTypes.append(contentsOf: processStructureDictionary(structureDictionary,
                                                                  parsedFile: parsedFile,
                                                                  containingTypeNames: []))
  }
  
  /// Create a `RawType` object from a parsed file's `StructureDictionary`.
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          parsedFile: ParsedFile,
                                          containingTypeNames: [String]) -> [RawType] {
    let typeName = dictionary[SwiftDocKey.name.rawValue] as? String
    let attributedContainingTypeNames: [String] // Containing types plus the current type.
    if let name = typeName {
      attributedContainingTypeNames = containingTypeNames + [name]
    } else {
      attributedContainingTypeNames = containingTypeNames
    }
    
    let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] ?? []
    let containedTypes = substructure.flatMap({
      processStructureDictionary($0,
                                 parsedFile: parsedFile,
                                 containingTypeNames: attributedContainingTypeNames)
    })
    guard let name = typeName else { return containedTypes } // Base case where this isn't a type.
    
    // For inheritance, contained types are stored in the root namespace as fully qualified types.
    containedTypes.forEach({ result.rawTypes.append($0) })
    
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isParsable,
      let accessLevel = AccessLevel(from: dictionary), accessLevel.isMockable else { return [] }
    let fullyQualifiedName = attributedContainingTypeNames.joined(separator: ".")
    return [RawType(dictionary: dictionary,
                    name: name,
                    fullyQualifiedName: fullyQualifiedName,
                    containedTypes: containedTypes,
                    containingTypeNames: containingTypeNames,
                    kind: kind,
                    parsedFile: parsedFile)]
  }
}

private class FlattenInheritanceOperation: BasicOperation {
  let rawType: [RawType]
  let moduleDependencies: [String: Set<String>]
  let rawTypeRepository: RawTypeRepository
  let typealiasRepository: TypealiasRepository
  
  class Result {
    fileprivate(set) var mockableType: MockableType?
  }
  
  let result = Result()
  
  init(rawType: [RawType],
       moduleDependencies: [String: Set<String>],
       rawTypeRepository: RawTypeRepository,
       typealiasRepository: TypealiasRepository) {
    precondition(!rawType.isEmpty)
    self.rawType = rawType
    self.moduleDependencies = moduleDependencies
    self.rawTypeRepository = rawTypeRepository
    self.typealiasRepository = typealiasRepository
  }
  
  override func run() throws {
    // Module names are put into an array and sorted so that looking up types is deterministic.
    let moduleNames = Array(Set(rawType.flatMap({
      $0.parsedFile.importedModuleNames.flatMap({ moduleDependencies[$0] ?? [$0] })
        + [$0.parsedFile.moduleName]
    }))).sorted()
    result.mockableType = flattenInheritance(for: rawType, moduleNames: moduleNames)
  }
  
  /// Recursively traverse the inheritance graph from bottom up (children to parents). Note that
  /// `rawType` is actually an unmerged set of all `RawType` declarations found eg in extensions.
  private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
  private func flattenInheritance(for rawType: [RawType], moduleNames: [String]) -> MockableType? {
    // Create a copy of `memoizedMockableTypes` to reduce lock contention.
    let memoizedMockableTypes = FlattenInheritanceOperation.memoizedMockbleTypes.value
    guard let baseRawType = rawType.findBaseRawType() else { return nil }
    
    let fullyQualifiedName = baseRawType.fullyQualifiedModuleName
    if let memoized = memoizedMockableTypes[fullyQualifiedName] { return memoized }
    
    let rawTypeRepository = self.rawTypeRepository
    let typealiasRepository = self.typealiasRepository
    let createMockableType: () -> MockableType? = {
      // Flattening inherited types could have updated `memoizedMockableTypes`.
      var memoizedMockableTypes = FlattenInheritanceOperation.memoizedMockbleTypes.value
      let mockableType = MockableType(from: rawType,
                                      mockableTypes: memoizedMockableTypes,
                                      moduleNames: moduleNames,
                                      rawTypeRepository: rawTypeRepository,
                                      typealiasRepository: typealiasRepository)
      
      // Contained types can inherit from their containing types, so store store this potentially
      // preliminary result first.
      FlattenInheritanceOperation.memoizedMockbleTypes.update {
        $0[fullyQualifiedName] = mockableType
      }
      
      let containedTypes = rawType.flatMap({ $0.containedTypes })
      guard !containedTypes.isEmpty else { return mockableType } // No contained types, early out.
      
      // For each contained type, flatten it before adding it to `mockableType`.
      memoizedMockableTypes[fullyQualifiedName] = mockableType
      mockableType?.containedTypes = containedTypes.compactMap({
        self.flattenInheritance(for: [$0], moduleNames: moduleNames)
      })
      FlattenInheritanceOperation.memoizedMockbleTypes.update {
        $0[fullyQualifiedName] = mockableType
      }
      return mockableType
    }
    
    // Base case where the type doesn't inherit from anything.
    let inheritedTypes = rawType
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
    guard !inheritedTypes.isEmpty else { return createMockableType() }
    
    let rawInheritedTypes = inheritedTypes
      .compactMap({ $0[SwiftDocKey.name.rawValue] as? String }) // Get type name.
      .compactMap({ typeName -> [RawType]? in // Get stored raw type.
        let nearest = rawTypeRepository
          .nearestInheritedType(named: typeName,
                                moduleNames: moduleNames,
                                referencingModuleName: baseRawType.parsedFile.moduleName,
                                containingTypeNames: baseRawType.containingTypeNames[...])
        return nearest
      })
      .flatMap({ $0 })
    
    // If there are inherited types that aren't processed, flatten them first.
    if rawInheritedTypes.filter({ memoizedMockableTypes[$0.fullyQualifiedModuleName] == nil }).count > 0 {
      rawInheritedTypes.forEach({ _ = flattenInheritance(for: [$0], moduleNames: moduleNames) })
    }
    
    return createMockableType()
  }
}
