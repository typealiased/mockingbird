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
  private let preprocessorExpression: String?
  private let shouldImportModule: Bool
  private let onlyMockProtocols: Bool
  private let disableSwiftlint: Bool
  
  public init(processTypesResult: ProcessTypesOperation.Result,
              moduleName: String,
              outputPath: Path,
              preprocessorExpression: String?,
              shouldImportModule: Bool,
              onlyMockProtocols: Bool,
              disableSwiftlint: Bool) {
    self.processTypesResult = processTypesResult
    self.moduleName = moduleName
    self.outputPath = outputPath
    self.shouldImportModule = shouldImportModule
    self.preprocessorExpression = preprocessorExpression
    self.onlyMockProtocols = onlyMockProtocols
    self.disableSwiftlint = disableSwiftlint
  }
  
  override func run() throws {
    var contents: PartialFileContents!
    time(.generateMocks) {
      let generator = FileGenerator(processTypesResult.mockableTypes,
                                    moduleName: moduleName,
                                    imports: processTypesResult.imports,
                                    outputPath: outputPath,
                                    preprocessorExpression: preprocessorExpression,
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
