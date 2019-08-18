//
//  GenerateFileOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit

class GenerateFileOperation: BasicOperation {
  private let processTypesResult: ProcessTypesOperation.Result
  private let moduleName: String
  private let outputPath: Path
  private let preprocessorExpression: String?
  private let shouldImportModule: Bool
  private let onlyMockProtocols: Bool
  
  private(set) var error: Error?
  
  init(processTypesResult: ProcessTypesOperation.Result,
       moduleName: String,
       outputPath: Path,
       preprocessorExpression: String?,
       shouldImportModule: Bool,
       onlyMockProtocols: Bool) {
    self.processTypesResult = processTypesResult
    self.moduleName = moduleName
    self.outputPath = outputPath
    self.shouldImportModule = shouldImportModule
    self.preprocessorExpression = preprocessorExpression
    self.onlyMockProtocols = onlyMockProtocols
  }
  
  override func run() {
    let generator = FileGenerator(processTypesResult.mockableTypes,
                                  moduleName: moduleName,
                                  imports: processTypesResult.imports,
                                  outputPath: outputPath,
                                  preprocessorExpression: preprocessorExpression,
                                  shouldImportModule: shouldImportModule,
                                  onlyMockProtocols: onlyMockProtocols)
    do {
      try generator.generate()
    } catch {
      self.error = error
    }
    print("Generated file to \(String(describing: outputPath.absolute()))") // TODO: logging utility
  }
}
