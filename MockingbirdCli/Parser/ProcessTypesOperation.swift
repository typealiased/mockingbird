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
    fileprivate(set) var mockableTypes = [String: MockableType]()
  }
  
  let result = Result()
  
  init(parseFilesResult: ParseFilesOperation.Result) {
    self.parseFilesResult = parseFilesResult
  }
  
  override func run() {
    parseFilesResult.parsedFiles.forEach({
      processStructureDictionary($0.structure.dictionary, in: $0)
    })
    result.rawTypes.forEach({ flattenInheritence(for: $0.value) })
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
  
  private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
  private func flattenInheritence(for rawType: RawType) {
    guard result.mockableTypes[rawType.name] == nil else { return }
    if let memoized = ProcessTypesOperation.memoizedMockbleTypes.value[rawType.name] {
      result.mockableTypes[rawType.name] =
        MockableType.clone(memoized, shouldMock: rawType.parsedFile.shouldMock)
      return
    }
    defer {
      let mockableType = MockableType(from: rawType, mockableTypes: result.mockableTypes)
      result.mockableTypes[rawType.name] = mockableType
      ProcessTypesOperation.memoizedMockbleTypes.update { $0[rawType.name] = mockableType }
    }
    
    // Base case where the type doesn't inherit from anything.
    guard let inheritedTypes = rawType.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary],
      inheritedTypes.count > 0 else { return }
    
    let rawInheritedTypes = inheritedTypes
      .compactMap({ $0[SwiftDocKey.name.rawValue] as? String }) // Get type name
      .compactMap({ result.rawTypes[$0] }) // Get stored raw type
    
    // All inherited types are flattened.
    guard rawInheritedTypes.filter({ result.mockableTypes[$0.name] == nil }).count > 0 else { return }
    rawInheritedTypes.forEach({ flattenInheritence(for: $0) }) // Flatten inherited
  }
}
