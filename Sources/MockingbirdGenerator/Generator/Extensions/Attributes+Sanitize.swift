//
//  Attributes+Sanitize.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 2/22/20.
//

import Foundation

private enum Constants {
  /// Ignore certain attributes that are implicitly applied through inheritance.
  static let attributeNameBlacklist: Set<String> = [
    "objc",
  ]
}

extension Attributes {
  var safeDeclarations: [String] {
    return declarations.filter({ declaration in
      guard
        declaration.hasPrefix("@"),
        let name = declaration.components(separatedBy: "(").first?.dropFirst()
        else { return false }
      return !Constants.attributeNameBlacklist.contains(String(name))
    })
  }
}
