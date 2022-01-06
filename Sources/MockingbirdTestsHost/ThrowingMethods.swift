import Foundation

protocol ThrowingProtocol {
  func throwingMethod() throws
  func throwingMethod() throws -> Bool
  func throwingMethod(block: () throws -> Bool) throws
}

protocol RethrowingProtocol {
  func rethrowingMethod(block: () throws -> Bool) rethrows
  func rethrowingMethod(block: () throws -> Bool) rethrows -> Bool
}
