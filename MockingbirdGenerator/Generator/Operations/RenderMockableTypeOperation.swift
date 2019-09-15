//
//  RenderMockableTypeOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class RenderMockableTypeOperation: BasicOperation {
  let mockableType: MockableType
  let moduleName: String
  
  class Result {
    fileprivate(set) var renderedContents = ""
  }
  
  let result = Result()
  
  init(mockableType: MockableType, moduleName: String) {
    self.mockableType = mockableType
    self.moduleName = moduleName
  }
  
  override func run() {
    let mockableTypeTemplate = MockableTypeTemplate(mockableType: mockableType)
    let substructure = [
      mockableTypeTemplate.render(),
      MockableTypeInitializerTemplate(mockableTypeTemplate: mockableTypeTemplate,
                                      containingTypeNames: []).render(),
    ]
    result.renderedContents = substructure.joined(separator: "\n\n")
  }
}
