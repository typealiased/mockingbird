import ArgumentParser
import Foundation
import MockingbirdGenerator

class URLArgument: ExpressibleByArgument {
  var url: URL
  var defaultValueDescription: String { url.absoluteString }
  
  required init?(argument: String) {
    guard let url = URL(string: argument) else { return nil }
    self.url = url
  }
  
  init(_ url: URL) {
    self.url = url
  }
}

extension URLArgument: Encodable {
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(url.absoluteString)
  }
}
