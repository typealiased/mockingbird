//
//  Renderable.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/14/19.
//

import Foundation

struct RenderContext {
  let indentation: UInt
  static let topLevel = RenderContext(indentation: 0)
  
  init(indentation: UInt) {
    self.indentation = indentation
  }
  
  init(nestedIn other: RenderContext) {
    indentation = other.indentation + 1
  }
}

/// Parsed models are passed to a `Renderable` which can render it as a `PartialFileContent`.
protocol Renderable {
  /// Create a `PartialFileContent` that can be written to disk.
  func render(in context: RenderContext) -> PartialFileContent
}
