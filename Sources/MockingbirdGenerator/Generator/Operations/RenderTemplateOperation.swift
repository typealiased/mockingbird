//
//  RenderTemplateOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class RenderTemplateOperation: BasicOperation {
  let template: Template
  
  class Result {
    fileprivate(set) var renderedContents = ""
  }
  
  let result = Result()
  
  init(template: Template) {
    self.template = template
  }
  
  override func run() {
    result.renderedContents = template.render()
  }
}
