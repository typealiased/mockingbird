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

  func getStoredVariableWithExplicitType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setStoredVariableWithExplicitType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func getWeakVariable()
    -> Mockable<VariableDeclaration, () -> VariablesContainer?, VariablesContainer?>
  func setWeakVariable(_ newValue: @escaping @autoclosure () -> VariablesContainer?)
    -> Mockable<VariableDeclaration, (VariablesContainer?) -> Void, Void>
  
  func getLazyVariableWithImplicitType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setLazyVariableWithImplicitType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
  
  func getLazyVariableWithExplicitType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool>
  func setLazyVariableWithExplicitType(_ newValue: @escaping @autoclosure () -> Bool)
  -> Mockable<VariableDeclaration, (Bool) -> Void, Void>
}
extension VariablesContainerMock: StubbableVariablesContainer {}

// MARK: Non-stubbable declarations

extension VariablesContainerMock {
  func setComputedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { return any() }
  
  func getConstantVariableWithImplicitType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool> { fatalError() }
  
  func getConstantVariableWithExplicitType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool> { fatalError() }
  
  func getLazyVariableWithComplexImplicitType()
    -> Mockable<VariableDeclaration, () -> Bool, Bool> { fatalError() }
  func setLazyVariableWithComplexImplicitType(_ newValue: @escaping @autoclosure () -> Bool)
  -> Mockable<VariableDeclaration, (Bool) -> Void, Void> { fatalError() }
}
