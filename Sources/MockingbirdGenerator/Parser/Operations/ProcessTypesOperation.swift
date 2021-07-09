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
  let checkCacheResult: CheckCacheOperation.Result?
  let useRelaxedLinking: Bool
  
  public class Result {
    fileprivate(set) var mockableTypes = [MockableType]()
    fileprivate(set) var parsedFiles = [ParsedFile]()
  }
  
  public let result = Result()
  let rawTypeRepository = RawTypeRepository()
  let typealiasRepository = TypealiasRepository()
  
  public override var description: String { "Process Types" }
  
  public init(parseFilesResult: ParseFilesOperation.Result,
              checkCacheResult: CheckCacheOperation.Result?,
              useRelaxedLinking: Bool) {
    self.parseFilesResult = parseFilesResult
    self.checkCacheResult = checkCacheResult
    self.useRelaxedLinking = useRelaxedLinking
    retainForever(rawTypeRepository)
    retainForever(typealiasRepository)
  }
  
  override func run() {
    guard checkCacheResult?.isCached != true else { return }
    time(.processTypes) {
      let queue = OperationQueue.createForActiveProcessors()
      let processStructuresOperations = parseFilesResult.parsedFiles
        .map({ parsedFile -> ProcessStructuresOperation in
          let structureDictionary = parsedFile.structure.dictionary
          let operation = ProcessStructuresOperation(structureDictionary: structureDictionary,
                                                     parsedFile: parsedFile)
          retainForever(operation)
          return operation
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
        .map({ rawType -> FlattenInheritanceOperation in
          let operation = FlattenInheritanceOperation(
            rawType: rawType,
            moduleDependencies: parseFilesResult.moduleDependencies,
            rawTypeRepository: rawTypeRepository,
            typealiasRepository: typealiasRepository,
            useRelaxedLinking: useRelaxedLinking
          )
          retainForever(operation)
          return operation
        })
      queue.addOperations(flattenInheritanceOperations, waitUntilFinished: true)
      result.mockableTypes = flattenInheritanceOperations
        .compactMap({ $0.result.mockableType })
        .filter({ !$0.isContainedType })
      result.parsedFiles = parseFilesResult.parsedFiles
      log("Created \(result.mockableTypes.count) mockable type\(result.mockableTypes.count != 1 ? "s" : "")")
    }
  }
}
