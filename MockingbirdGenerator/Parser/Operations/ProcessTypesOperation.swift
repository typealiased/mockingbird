//
//  ProcessTypesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework
import os.log

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
    time(.processTypes) {
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
        .filter({ mockableType -> Bool in
          guard mockableType.kind == .class, mockableType.subclassesExternalType
            else { return true }
          // Ignore any types that simply cannot be initialized because they subclass an externally-
          // defined type without available initializers and don't locally declare any initializers.
          return mockableType.methods.contains(where: { $0.isInitializer })
        })
      result.imports = parseFilesResult.imports
    }
  }
}
