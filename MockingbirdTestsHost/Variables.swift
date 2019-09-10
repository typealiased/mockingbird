//
//  Variables.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation

protocol VariablesContainerProtocol {
  var readonlyVariableOverwrittenAsReadwrite: Bool { get }
}

class VariablesContainer: VariablesContainerProtocol {
  var readonlyVariableOverwrittenAsReadwrite: Bool
  
  var uninitializedVariable: Bool
  
  var computedVariable: Bool { return true }
  var computedMutableVariable: Bool {
    get { return true }
    set { }
  }
  
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
    self.readonlyVariableOverwrittenAsReadwrite = true
    self.uninitializedVariable = true
    self.computedVariableWithDidSetObserver = true
    self.computedVariableWithWillSetObserver = true
  }
}
