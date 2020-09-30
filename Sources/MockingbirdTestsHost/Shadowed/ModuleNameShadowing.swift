//
//  ModuleNameShadowing.swift
//  MockingbirdShadowedTestsHost
//
//  Created by typealias on 9/24/20.
//

import Foundation

// In cases where the module name is shadowed by a type declaration, we need to avoid qualifying
// type references. As of Swift 5.3 there is no syntax to properly fully qualify type references.
public protocol MockingbirdShadowedTestsHost {}

public protocol ShadowedModuleProtocol {
  func referencingShadowedType(param: MockingbirdShadowedTestsHost)
}

class ConformingShadowedModuleProtocol: MockingbirdShadowedTestsHost {
  func referencingShadowedType(param: MockingbirdShadowedTestsHost) {}
}
