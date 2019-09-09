//
//  VariablesTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/9/19.
//

import Foundation

// MARK: - Mockable declarations

private protocol MockableVariablesContainer {
  var readonlyVariableOverwrittenAsReadwrite: Bool { get set }
  var uninitializedVariable: Bool { get set }
  
  var computedVariable: Bool { get }
  
  var computedVariableWithDidSetObserver: Bool { get set }
  var computedVariableWithWillSetObserver: Bool { get set }
}
extension VariablesContainerMock: MockableVariablesContainer {}
