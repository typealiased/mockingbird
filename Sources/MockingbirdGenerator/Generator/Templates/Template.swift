import Foundation

/// Able to be rendered into a `String` using a potentially non-O(1) operation.
protocol Template: CustomStringConvertible {
  func render() -> String
}

extension Template {
  var description: String { render() }
}
