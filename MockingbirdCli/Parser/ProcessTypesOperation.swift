//
//  ProcessTypesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct RawType {
  let dictionary: StructureDictionary
  let name: String
  let fullyQualifiedName: String // For root-level `RawType` objects contained within another type.
  let containedTypes: [RawType]
  let kind: SwiftDeclarationKind
  let parsedFile: ParsedFile
  
  var isContainedType: Bool { return name != fullyQualifiedName }
  
  init(dictionary: StructureDictionary,
       name: String,
       fullyQualifiedName: String,
       containedTypes: [RawType],
       kind: SwiftDeclarationKind,
       parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
    self.fullyQualifiedName = fullyQualifiedName
    self.containedTypes = containedTypes
    self.kind = kind
    self.parsedFile = parsedFile
  }
}

class ProcessTypesOperation: BasicOperation {
  let parseFilesResult: ParseFilesOperation.Result
  
  class Result {
    /// Stores an array of `RawType` references to handle extensions which we can treat as partial
    /// definitions of a `RawType`. We eventually combine all partials into a final type definition.
    fileprivate(set) var rawTypes = [String: [RawType]]()
    fileprivate(set) var mockableTypes = [MockableType]()
    fileprivate(set) var imports = Set<String>()
  }
  
  let result = Result()
  
  /// Type inheritance flattening can be slow, so it's a concurrent suboperation.
  class SubOperation: BasicOperation {
    let rawType: [RawType]
    let allRawTypes: [String: [RawType]]
    
    class Result {
      fileprivate(set) var mockableType: MockableType?
    }
    
    let result = Result()
    
    init(rawType: [RawType], allRawTypes: [String: [RawType]]) {
      precondition(!rawType.isEmpty)
      self.rawType = rawType
      self.allRawTypes = allRawTypes
    }
    
    override func run() throws {
      result.mockableType = flattenInheritance(for: rawType)
    }
    
    /// Recursively traverse the inheritance graph from bottom up (children to parents). Note that
    /// `rawType` is actually an unmerged set of all `RawType` declarations found eg in extensions.
    private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
    private func flattenInheritance(for rawType: [RawType],
                                    containingTypeNames: [String] = []) -> MockableType? {
      let memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value // Reduce lock contention.
      guard let rawTypeName = rawType.first?.name else { return nil }
      
      let fullyQualifiedName = (containingTypeNames + [rawTypeName]).joined(separator: ".")
      if let memoized = memoizedMockableTypes[fullyQualifiedName] { return memoized }
      let createMockableType: () -> MockableType? = {
        // Flattening inherited types could have updated `memoizedMockableTypes`.
        var memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value
        var mockableType = MockableType(from: rawType,
                                        mockableTypes: memoizedMockableTypes,
                                        containingTypeNames: containingTypeNames)
        
        // Contained types can inherit from their containing types, so store store this potentially
        // preliminary result first.
        SubOperation.memoizedMockbleTypes.update { $0[fullyQualifiedName] = mockableType }
        
        let containedTypes = rawType.flatMap({ $0.containedTypes })
        guard !containedTypes.isEmpty else { return mockableType } // No contained types, early out.
        
        // For each contained type, flatten it before adding it to `mockableType`.
        memoizedMockableTypes[fullyQualifiedName] = mockableType
        mockableType?.containedTypes = containedTypes.compactMap({
          self.flattenInheritance(for: [$0],
                                  containingTypeNames: containingTypeNames + [rawTypeName])
        })
        SubOperation.memoizedMockbleTypes.update { $0[fullyQualifiedName] = mockableType }
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
          let nearest = nearestInheritedType(with: typeName,
                                             in: allRawTypes,
                                             containingTypeNames: containingTypeNames[...])
          return nearest
        })
        .flatMap({ $0 })
      
      // If there are inherited types that aren't processed, flatten them first.
      if rawInheritedTypes.filter({ memoizedMockableTypes[$0.name] == nil }).count > 0 {
        rawInheritedTypes.forEach({ _ = flattenInheritance(for: [$0]) })
      }
      
      return createMockableType()
    }
    
    /// See `MockableType.nearestInheritedType`.
    private func nearestInheritedType(with name: String,
                                      in rawTypes: [String: [RawType]],
                                      containingTypeNames: ArraySlice<String>) -> [RawType]? {
      guard !containingTypeNames.isEmpty else { return rawTypes[name] } // Base case.
      
      let fullyQualifiedName = (containingTypeNames + [name]).joined(separator: ".")
      if let rawType = rawTypes[fullyQualifiedName] { return rawType }
      
      let typeNames = containingTypeNames[0..<(containingTypeNames.count-1)]
      return nearestInheritedType(with: name,
                                  in: rawTypes,
                                  containingTypeNames: typeNames)
    }
  }
  
  init(parseFilesResult: ParseFilesOperation.Result) {
    self.parseFilesResult = parseFilesResult
  }
  
  override func run() {
    parseFilesResult.parsedFiles.flatMap({
      processStructureDictionary($0.structure.dictionary, parsedFile: $0, containingTypeNames: [])
    }).forEach({
      result.rawTypes[$0.fullyQualifiedName, default: []].append($0)
    })
    let operations = result.rawTypes
      .map({ $0.value })
      .filter({ $0.first(where: { $0.kind.isMockable })?.parsedFile.shouldMock == true })
      .filter({ $0.first?.isContainedType != true })
      .map({ SubOperation(rawType: $0, allRawTypes: result.rawTypes) })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    result.mockableTypes = operations
      .compactMap({ $0.result.mockableType })
      .filter({ !$0.isContainedType })
    result.imports = parseFilesResult.importedModuleNames
  }
  
  /// Create a `RawType` object from a parsed file's `StructureDictionary`.
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          parsedFile: ParsedFile,
                                          containingTypeNames: [String]) -> [RawType] {
    guard let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary]
      else { return [] } // Trivial base case where there isn't any substructure.
    
    let typeName = dictionary[SwiftDocKey.name.rawValue] as? String
    let attributedContainingTypeNames: [String] // Containing types plus the current type.
    if let name = typeName {
      attributedContainingTypeNames = containingTypeNames + [name]
    } else {
      attributedContainingTypeNames = containingTypeNames
    }
    
    let containedTypes = substructure.flatMap({
      processStructureDictionary($0,
                                 parsedFile: parsedFile,
                                 containingTypeNames: attributedContainingTypeNames)
    })
    guard let name = typeName else { return containedTypes } // Base case where this isn't a type.
    
    // For inheritance, contained types are stored in the root namespace as fully qualified types.
    containedTypes.forEach({
      result.rawTypes[$0.fullyQualifiedName, default: []].append($0)
    })
    
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isParsable else { return [] }
    let fullyQualifiedName = attributedContainingTypeNames.joined(separator: ".")
    return [RawType(dictionary: dictionary,
                    name: name,
                    fullyQualifiedName: fullyQualifiedName,
                    containedTypes: containedTypes,
                    kind: kind,
                    parsedFile: parsedFile)]
  }
}
