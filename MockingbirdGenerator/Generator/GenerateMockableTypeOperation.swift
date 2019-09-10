//
//  GenerateMockableTypeOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class GenerateMockableTypeOperation: BasicOperation {
  let mockableType: MockableType
  let moduleName: String
  
  class Result {
    fileprivate(set) var generatedContents = ""
  }
  
  let result = Result()
  
  init(mockableType: MockableType, moduleName: String) {
    self.mockableType = mockableType
    self.moduleName = moduleName
  }
  
  override func run() {
    result.generatedContents = mockableType.generate(moduleName: moduleName)
      + "\n\n" + mockableType.generateInitializer(containingTypeNames: [])
  }
}
