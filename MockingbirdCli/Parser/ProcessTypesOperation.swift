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
  let containedTypes: [RawType]
  let kind: SwiftDeclarationKind
  let parsedFile: ParsedFile
  
  init(dictionary: StructureDictionary,
       name: String,
       containedTypes: [RawType],
       kind: SwiftDeclarationKind,
       parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
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
  
  /// Type inheritence flattening can be slow, so it's a concurrent suboperation.
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
      result.mockableType = flattenInheritence(for: rawType)
    }
    
    /// Recursively traverse the inheritence graph from bottom up (children to parents). Note that
    /// `rawType` is actually an unmerged set of all `RawType` declarations found eg in extensions.
    private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
    private func flattenInheritence(for rawType: [RawType]) -> MockableType? {
      let memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value // Reduce lock contention.
      guard let rawTypeName = rawType.first?.name else { return nil }
      if let memoized = memoizedMockableTypes[rawTypeName] { return memoized }
      let createMockableType: () -> MockableType? = {
        let memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value
        let mockableType = MockableType(from: rawType, mockableTypes: memoizedMockableTypes)
        SubOperation.memoizedMockbleTypes.update { $0[rawTypeName] = mockableType }
        return mockableType
      }
      
      // Base case where the type doesn't inherit from anything.
      let inheritedTypes = rawType
        .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
        .flatMap({ $0 })
      guard !inheritedTypes.isEmpty else { return createMockableType() }
      
      let rawInheritedTypes = inheritedTypes
        .compactMap({ $0[SwiftDocKey.name.rawValue] as? String }) // Get type name.
        .compactMap({ allRawTypes[$0] }) // Get stored raw type.
        .flatMap({ $0 })
      
      // If there are inherited types, flatten them first.
      if rawInheritedTypes.filter({ memoizedMockableTypes[$0.name] == nil }).count > 0 {
        rawInheritedTypes.forEach({ _ = flattenInheritence(for: [$0]) })
      }
      
      return createMockableType()
    }
  }
  
  init(parseFilesResult: ParseFilesOperation.Result) {
    self.parseFilesResult = parseFilesResult
  }
  
  override func run() {
    parseFilesResult.parsedFiles.flatMap({
      processStructureDictionary($0.structure.dictionary, parsedFile: $0)
    }).forEach({
      result.rawTypes[$0.name, default: []].append($0)
    })
    let operations = result.rawTypes
      .map({ $0.value })
      .filter({ $0.first(where: { $0.kind.isMockable })?.parsedFile.shouldMock == true })
      .map({ SubOperation(rawType: $0, allRawTypes: result.rawTypes) })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    result.mockableTypes = operations.compactMap({ $0.result.mockableType })
    result.imports = parseFilesResult.importedModuleNames
  }
  
  /// Create a `RawType` object from a parsed file's `StructureDictionary`.
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          parsedFile: ParsedFile) -> [RawType] {
    guard let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary]
      else { return [] }
    
    let containedTypes = substructure.flatMap({
      processStructureDictionary($0, parsedFile: parsedFile)
    })
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String else { return containedTypes }
    guard let kind = SwiftDeclarationKind(from: dictionary), kind.isParsable else { return [] }
    return [RawType(dictionary: dictionary,
                    name: name,
                    containedTypes: containedTypes,
                    kind: kind,
                    parsedFile: parsedFile)]
  }
}
