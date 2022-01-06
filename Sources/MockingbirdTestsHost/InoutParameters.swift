import Foundation

protocol InoutProtocol {
  func parameterizedMethod(object: inout String)
}

class InoutClass {
  func parameterizedMethod(object: inout String) {}
}
