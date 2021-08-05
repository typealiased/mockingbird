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
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setReadonlyVariableOverwrittenAsReadwrite(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func getUninitializedVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setUninitializedVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func getComputedVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>

  func getComputedMutableVariable()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setComputedMutableVariable(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func getComputedVariableWithDidSetObserver()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setComputedVariableWithDidSetObserver(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func getComputedVariableWithWillSetObserver()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setComputedVariableWithWillSetObserver(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>

  func getStoredVariableWithExplicitType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setStoredVariableWithExplicitType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func getWeakVariable()
    -> Mockable<PropertyGetterDeclaration, () -> VariablesContainer?, VariablesContainer?>
  func setWeakVariable(_ newValue: @escaping @autoclosure () -> VariablesContainer?)
    -> Mockable<PropertySetterDeclaration, (VariablesContainer?) -> Void, Void>
  
  func getLazyVariableWithImplicitType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setLazyVariableWithImplicitType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
  
  func getLazyVariableWithExplicitType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool>
  func setLazyVariableWithExplicitType(_ newValue: @escaping @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void>
}
extension VariablesContainerMock: StubbableVariablesContainer {}

// MARK: Non-stubbable declarations

extension VariablesContainerMock {
  func setComputedVariable(_ newValue: @autoclosure () -> Bool)
    -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { return any() }
  
  func getConstantVariableWithImplicitType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  
  func getConstantVariableWithExplicitType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  
  func getLazyVariableWithComplexImplicitType()
    -> Mockable<PropertyGetterDeclaration, () -> Bool, Bool> { fatalError() }
  func setLazyVariableWithComplexImplicitType(_ newValue: @autoclosure () -> Bool)
  -> Mockable<PropertySetterDeclaration, (Bool) -> Void, Void> { fatalError() }
}
