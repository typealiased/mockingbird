//
//  ExternalModuleTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import MockingbirdModuleTestsHost
import MockingbirdShadowedTestsHost

protocol LocalPublicExternalProtocol: PublicExternalProtocol {}

/// Cannot be mocked because `ExternalClass` doesn't define any publicly accessible initializers.
class SubclassingExternalClass: ExternalClass {
  var internalVariable = true
  func internalMethod() {}
}

// MARK: - Inherited external initializer

class SubclassingExternalClassWithInheritedIntializer: ExternalClassWithInitializer {
  var internalVariable = true
  func internalMethod() {}
}

class SubclassingExternalSubclassWithInheritedInitializer: ExternalSubclassWithInitializer {
  var internalVariable = true
  func internalMethod() {}
}

// MARK: - Designated local initializer

class SubclassingExternalClassWithDesignatedIntializer: ExternalClassWithInitializer {
  var internalVariable = true
  func internalMethod() {}
  
  init(param1: Bool) {
    super.init()
  }
}

class SubclassingExternalSubclassWithDesignatedInitializer: ExternalSubclassWithInitializer {
  var internalVariable = true
  func internalMethod() {}
  
  init(param1: Bool) {
    super.init()
  }
}

// MARK: - Class constrained protocols

protocol ConformingExternalClassConstrainedProtocol: ExternalClassConstrainedProtocol {}
protocol ConformingInitializableOpenClassConstrainedProtocol: InitializableOpenClassConstrainedProtocol {}
protocol ConformingUninitializableOpenClassConstrainedProtocol: UninitializableOpenClassConstrainedProtocol {}
protocol ConformingUnmockablePublicClassConstrainedProtocol: UnmockablePublicClassConstrainedProtocol {}

// MARK: - Module name shadowing

class ConformingExternalShadowedProtocol: MockingbirdShadowedTestsHost {
  func referencingShadowedType(param: MockingbirdShadowedTestsHost) {}
}
