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
  let parsedFile: ParsedFile
  
  init(dictionary: StructureDictionary, name: String, parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
    self.parsedFile = parsedFile
  }
}

class ProcessTypesOperation: BasicOperation {
  let parseFilesResult: ParseFilesOperation.Result
  
  class Result {
    fileprivate(set) var rawTypes = [String: RawType]()
    fileprivate(set) var mockableTypes = [MockableType]()
    fileprivate(set) var imports = Set<String>()
  }
  
  let result = Result()
  
  class SubOperation: BasicOperation {
    let rawType: RawType
    let rawTypes: [String: RawType]
    
    class Result {
      fileprivate(set) var mockableType: MockableType?
    }
    
    let result = Result()
    
    init(rawType: RawType, rawTypes: [String: RawType]) {
      self.rawType = rawType
      self.rawTypes = rawTypes
    }
    
    override func run() {
      result.mockableType = flattenInheritence(for: rawType)
    }
    
    private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
    private func flattenInheritence(for rawType: RawType) -> MockableType? {
      let memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value
      if let memoized = memoizedMockableTypes[rawType.name] { return memoized }
      let createMockableType: () -> MockableType? = {
        let memoizedMockableTypes = SubOperation.memoizedMockbleTypes.value
        let mockableType = MockableType(from: rawType, mockableTypes: memoizedMockableTypes)
        SubOperation.memoizedMockbleTypes.update { $0[rawType.name] = mockableType }
        return mockableType
      }
      
      // Base case where the type doesn't inherit from anything.
      guard let inheritedTypes =
        rawType.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary],
        inheritedTypes.count > 0 else { return createMockableType() }
      
      let rawInheritedTypes = inheritedTypes
        .compactMap({ $0[SwiftDocKey.name.rawValue] as? String }) // Get type name.
        .compactMap({ rawTypes[$0] }) // Get stored raw type.
      
      if rawInheritedTypes.filter({ memoizedMockableTypes[$0.name] == nil }).count > 0 {
        rawInheritedTypes.forEach({ _ = flattenInheritence(for: $0) }) // Flatten inherited types.
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
      .filter({ $0.value.parsedFile.shouldMock })
      .map({ SubOperation(rawType: $0.value, rawTypes: result.rawTypes) })
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
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind.isMockable else { return }
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String else { return }
    result.rawTypes[name] = RawType(dictionary: dictionary, name: name, parsedFile: parsedFile)
  }
}
