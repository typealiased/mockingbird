//
//  ClassOnlyProtocols.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 10/1/19.
//

import Foundation

protocol DeprecatedClassOnlyProtocol: class {
  var variable: Bool { get }
}

protocol DeprecatedClassOnlyProtocolWithInheritance: class, ChildProtocol {
  var variable: Bool { get }
}

protocol ClassOnlyProtocol: AnyObject {
  var variable: Bool { get }
}

protocol ClassOnlyProtocolWithInheritance: AnyObject, ChildProtocol {
  var variable: Bool { get }
}
