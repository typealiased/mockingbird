//
//  Renderable.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/14/19.
//

import Foundation

/// Parsed models are passed to a `Renderable` which serializes it as a `String`.
protocol Renderable {
  func render() -> String
}
