//
//  Exceptions.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/14/19.
//

import Foundation

protocol ThrowingProtocol {
  func throwingMethod() throws
  func throwingMethod() throws -> Bool
  func throwingMethod(block: () throws -> Bool) throws
}

protocol RethrowingProtocol {
  // @nocommit
  func rethrowingMethod(block: () throws -> Bool) throws
  func rethrowingMethod(block: () throws -> Bool) throws -> Bool
}
