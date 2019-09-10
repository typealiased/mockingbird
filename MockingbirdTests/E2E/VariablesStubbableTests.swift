//
//  VariablesStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/10/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableVariablesContainer {
  func getReadonlyVariableOverwrittenAsReadwrite()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setReadonlyVariableOverwrittenAsReadwrite(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func getUninitializedVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setUninitializedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func getComputedVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>

  func getComputedMutableVariable()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setComputedMutableVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func getComputedVariableWithDidSetObserver()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setComputedVariableWithDidSetObserver(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func getComputedVariableWithWillSetObserver()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setComputedVariableWithWillSetObserver(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
}
extension VariablesContainerMock: StubbableVariablesContainer {}

// MARK: Non-mockable declarations

extension VariablesContainerMock {
  func setComputedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
}
