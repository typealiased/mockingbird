//
//  ClassOnlyProtocols.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 10/1/19.
//

import Foundation

// MARK: - Deprecated class conformance

protocol DeprecatedClassOnlyProtocol: class {
  var variable: Bool { get }
}

protocol DeprecatedClassOnlyProtocolWithInheritance: class, ChildProtocol {
  var variable: Bool { get }
}


// MARK: - AnyObject conformance

protocol ClassOnlyProtocol: AnyObject {
  var variable: Bool { get }
}

protocol ClassOnlyProtocolWithInheritance: AnyObject, ChildProtocol {
  var variable: Bool { get }
}


// MARK: - Initializers

class ClassWithoutDesignatedInitializer {
  var variable: Bool = true
}

protocol InitializableClassOnlyProtocol: ClassWithoutDesignatedInitializer {
  init(param1: Bool, param2: Int)
}

class ClassWithDesignatedInitializer {
  required init(param: Bool) {}
  init(param: Int) {}
  
  @available(*, deprecated, message: "This class initializer is deprecated")
  init(param1: Bool) {}
}

protocol InitializableClassOnlyProtocolWithInheritedInitializer: ClassWithDesignatedInitializer {
  init(param1: Bool, param2: Int)
  
  @available(*, deprecated, message: "This protocol initializer is deprecated")
  init(param2: Bool, param3: Int)
}

extension InitializableClassOnlyProtocolWithInheritedInitializer {
  init(param1: Bool, param2: Int, param3: String) { self.init(param: param1) }
}
