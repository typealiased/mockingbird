//
//  ProcessTypesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdShared
import SourceKittenFramework

struct RawType {
  let dictionary: StructureDictionary
  let name: String
  let kind: SwiftDeclarationKind
  let parsedFile: ParsedFile
  
  init(dictionary: StructureDictionary,
       name: String,
       kind: SwiftDeclarationKind,
       parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
    self.kind = kind
    self.parsedFile = parsedFile
  }
}

class ProcessTypesOperation: BasicOperation {
  let parseFilesResult: ParseFilesOperation.Result
  
  class Result {
    fileprivate(set) var rawTypes = [String: [RawType]]() // Handle multiple extensions.
    fileprivate(set) var mockableTypes = [MockableType]()
    fileprivate(set) var imports = Set<String>()
  }
  
  let result = Result()
  
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
    
    override func run() {
      result.mockableType = flattenInheritence(for: rawType)
    }
    
    private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
    private func flattenInheritence(for rawType: [RawType]) -> MockableType? {
      let memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value
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
      
      if rawInheritedTypes.filter({ memoizedMockableTypes[$0.name] == nil }).count > 0 {
        rawInheritedTypes.forEach({ _ = flattenInheritence(for: [$0]) }) // Flatten inherited types.
      }
      
      // All inherited types are now flattened.
      return createMockableType()
    }
  }
  
  init(parseFilesResult: ParseFilesOperation.Result) {
    self.parseFilesResult = parseFilesResult
  }
  
  override func run() {
    parseFilesResult.parsedFiles.forEach({
      processStructureDictionary($0.structure.dictionary, in: $0)
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
  
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          in parsedFile: ParsedFile) {
    guard let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] else {
      return
    }
    substructure.forEach({ processStructureDictionary($0, in: parsedFile) })
    
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind.isParsable else { return }
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String else { return }
    result.rawTypes[name, default: []].append(RawType(dictionary: dictionary,
                                                      name: name,
                                                      kind: kind,
                                                      parsedFile: parsedFile))
  }
}
