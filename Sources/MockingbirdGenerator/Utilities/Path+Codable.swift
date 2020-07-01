//
//  Path+Codable.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 6/10/20.
//

import Foundation
import PathKit

extension Path: Codable {
  public init(from decoder: Decoder) throws {
    let path = try decoder.singleValueContainer().decode(String.self)
    self.init(path)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(absolute())")
  }
}
