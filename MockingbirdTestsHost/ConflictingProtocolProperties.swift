//
//  ConflictingProtocolProperties.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 5/4/20.
//

import Foundation

protocol InheritedConflictingProtocolProperties {
  var foo: Bool { get set }
  var bar: Bool { get set }
}

// Not possible to create a class conforming to any of the protocols below.

protocol SingleConflictingProtocolProperties: InheritedConflictingProtocolProperties {
  var foo: String { get set }
}

protocol MultipleConflictingProtocolProperties: SingleConflictingProtocolProperties {
  var foo: Int { get set }
  var bar: Int { get set }
}
