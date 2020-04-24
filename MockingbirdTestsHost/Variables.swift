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
  var storedVariableWithImplicitTupleType = (true, true)
  var storedVariableWithConstructedImplicitType = Bool(booleanLiteral: true)
  var storedVariableWithComplexConstructedImplicitType = Array<(String, String)>(arrayLiteral: ("Test", "Test"))

  var storedVariableWithExplicitType: Bool = true
  
  let constantVariableWithImplicitType = true
  let constantVariableWithExplicitType: Bool = true

  weak var weakVariable: VariablesContainer?
  
  lazy var lazyVariableWithImplicitType = true

  lazy var lazyVariableWithExplicitType: Bool = { return true }()

  lazy var lazyVariableWithComplexImplicitType = weakVariable.map { $0 === self }
  
  init() {
    self.readonlyVariableOverwrittenAsReadwrite = true
    self.uninitializedVariable = true
    self.computedVariableWithDidSetObserver = true
    self.computedVariableWithWillSetObserver = true
  }
}
