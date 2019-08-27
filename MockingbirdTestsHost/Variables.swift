//
//  Variables.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation

class VariablesContainer {
  var computedVariable: Bool { return true }
  
  var computedVariableWithDidSetObserver: Bool {
    didSet {}
  }
  var computedVariableWithWillSetObserver: Bool {
    willSet {}
  }
  
  var storedVariableWithImplicitType = true
  var storedVariableWithExplicitType: Bool = true
  
  let constantVariableWithImplicitType = true
  let constantVariableWithExplicitType: Bool = true
  
  init() {
    self.computedVariableWithDidSetObserver = true
    self.computedVariableWithWillSetObserver = true
  }
}
