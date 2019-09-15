//
//  Template.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/14/19.
//

import Foundation

/// Able to be rendered into a `String` using a potentially non-O(1) operation.
protocol Template {
  func render() -> String
}
