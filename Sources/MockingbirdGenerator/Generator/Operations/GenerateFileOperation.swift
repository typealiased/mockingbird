//
//  GenerateFileOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit
import os.log

public class GenerateFileOperation: BasicOperation {
  let processTypesResult: ProcessTypesOperation.Result
  let checkCacheResult: CheckCacheOperation.Result?
  let findMockedTypesResult: FindMockedTypesOperation.Result?
  
  let moduleName: String
  let outputPath: Path
  let compilationCondition: String?
  let shouldImportModule: Bool
  let onlyMockProtocols: Bool
  let disableSwiftlint: Bool
  
  public init(processTypesResult: ProcessTypesOperation.Result,
              checkCacheResult: CheckCacheOperation.Result?,
              findMockedTypesResult: FindMockedTypesOperation.Result?,
              moduleName: String,
              outputPath: Path,
              compilationCondition: String?,
              shouldImportModule: Bool,
              onlyMockProtocols: Bool,
              disableSwiftlint: Bool) {
    self.processTypesResult = processTypesResult
    self.checkCacheResult = checkCacheResult
    self.findMockedTypesResult = findMockedTypesResult
    self.moduleName = moduleName
    self.outputPath = outputPath
    self.shouldImportModule = shouldImportModule
    self.compilationCondition = compilationCondition
    self.onlyMockProtocols = onlyMockProtocols
    self.disableSwiftlint = disableSwiftlint
  }
  
  override func run() throws {
    guard checkCacheResult?.isCached != true else { return }
    var contents: PartialFileContent!
    time(.renderMocks) {
      let generator = FileGenerator(
        mockableTypes: processTypesResult.mockableTypes,
        mockedTypeNames: findMockedTypesResult?.allMockedTypeNames,
        moduleName: moduleName,
        imports: processTypesResult.imports,
        outputPath: outputPath,
        compilationCondition: compilationCondition,
        shouldImportModule: shouldImportModule,
        onlyMockProtocols: onlyMockProtocols,
        disableSwiftlint: disableSwiftlint
      )
      contents = generator.generate()
    }
    
    try time(.writeFiles) {
      try outputPath.writeUtf8Strings(contents)
    }
    
    logInfo("Generated file to \(outputPath.absolute())")
  }
}
