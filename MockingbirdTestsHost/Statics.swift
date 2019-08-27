//
//  Statics.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation

protocol StaticsContainerProtocol {
  static var staticVariable: Bool { get set }
  static var staticReadOnlyVariable: Bool { get }
  
  static func staticMethod() -> Bool
}

class StaticsContainerClass {
  class var classComputedVariable: Bool { return true }
  
  static var staticStoredVariableWithImplicitType = true
  static var staticStoredVariableWithExplicitType: Bool = true
  static var staticComputedVariable: Bool { return true }
}
