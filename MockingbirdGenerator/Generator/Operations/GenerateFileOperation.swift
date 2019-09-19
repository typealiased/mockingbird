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
  private let processTypesResult: ProcessTypesOperation.Result
  private let moduleName: String
  private let outputPath: Path
  private let compilationCondition: String?
  private let shouldImportModule: Bool
  private let onlyMockProtocols: Bool
  private let disableSwiftlint: Bool
  
  public init(processTypesResult: ProcessTypesOperation.Result,
              moduleName: String,
              outputPath: Path,
              compilationCondition: String?,
              shouldImportModule: Bool,
              onlyMockProtocols: Bool,
              disableSwiftlint: Bool) {
    self.processTypesResult = processTypesResult
    self.moduleName = moduleName
    self.outputPath = outputPath
    self.shouldImportModule = shouldImportModule
    self.compilationCondition = compilationCondition
    self.onlyMockProtocols = onlyMockProtocols
    self.disableSwiftlint = disableSwiftlint
  }
  
  override func run() throws {
    var contents: PartialFileContent!
    time(.renderMocks) {
      let generator = FileGenerator(processTypesResult.mockableTypes,
                                    moduleName: moduleName,
                                    imports: processTypesResult.imports,
                                    outputPath: outputPath,
                                    compilationCondition: compilationCondition,
                                    shouldImportModule: shouldImportModule,
                                    onlyMockProtocols: onlyMockProtocols,
                                    disableSwiftlint: disableSwiftlint)
      contents = generator.generate()
    }
    
    try time(.writeFiles) {
      try outputPath.writeUtf8Strings(contents)
    }
    
    print("Generated file to \(String(describing: outputPath.absolute()))")
  }
}
