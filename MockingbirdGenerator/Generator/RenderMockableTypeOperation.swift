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
    fileprivate(set) var renderedContents = PartialFileContent.empty
  }
  
  let result = Result()
  
  init(mockableType: MockableType, moduleName: String) {
    self.mockableType = mockableType
    self.moduleName = moduleName
  }
  
  override func run() {
    let mockableTypeTemplate = MockableTypeTemplate(mockableType: mockableType)
    let substructure = [
      mockableTypeTemplate.render(in: .topLevel),
      MockableTypeInitializerTemplate(mockableTypeTemplate: mockableTypeTemplate,
                                      containingTypeNames: []).render(in: .topLevel),
    ]
    result.renderedContents = PartialFileContent(substructure: substructure, delimiter: "\n\n")
  }
}
