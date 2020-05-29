//
//  Primitives.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/7/19.
//

import Foundation

/// Static cache for primative `DeclaredType` objects.
enum Primitives {
  static let map: [Substring: DeclaredType] = [
    "Bool": DeclaredType(from: "Bool", ignoreCache: true),
    "Bool?": DeclaredType(from: "Bool?", ignoreCache: true),
    "[Bool]": DeclaredType(from: "[Bool]", ignoreCache: true),
    
    // String
    "String": DeclaredType(from: "String", ignoreCache: true),
    "String?": DeclaredType(from: "String?", ignoreCache: true),
    "[String]": DeclaredType(from: "[String]", ignoreCache: true),
    "Substring": DeclaredType(from: "Substring", ignoreCache: true),
    "Substring?": DeclaredType(from: "Substring?", ignoreCache: true),
    "[Substring]": DeclaredType(from: "[Substring]", ignoreCache: true),
    "Character": DeclaredType(from: "Character", ignoreCache: true),
    "Character?": DeclaredType(from: "Character?", ignoreCache: true),
    "[Character]": DeclaredType(from: "[Character]", ignoreCache: true),
    
    // Numeric
    "Int": DeclaredType(from: "Int", ignoreCache: true),
    "Int?": DeclaredType(from: "Int?", ignoreCache: true),
    "[Int]": DeclaredType(from: "[Int]", ignoreCache: true),
    "UInt": DeclaredType(from: "UInt", ignoreCache: true),
    "UInt?": DeclaredType(from: "UInt?", ignoreCache: true),
    "[UInt]": DeclaredType(from: "[UInt]", ignoreCache: true),
    "Float": DeclaredType(from: "Float", ignoreCache: true),
    "Float?": DeclaredType(from: "Float?", ignoreCache: true),
    "[Float]": DeclaredType(from: "[Float]", ignoreCache: true),
    "Double": DeclaredType(from: "Double", ignoreCache: true),
    "Double?": DeclaredType(from: "Double?", ignoreCache: true),
    "[Double]": DeclaredType(from: "[Double]", ignoreCache: true),
    "Int8": DeclaredType(from: "Int8", ignoreCache: true),
    "Int8?": DeclaredType(from: "Int8?", ignoreCache: true),
    "[Int8]": DeclaredType(from: "[Int8]", ignoreCache: true),
    "UInt8": DeclaredType(from: "UInt8", ignoreCache: true),
    "UInt8?": DeclaredType(from: "UInt8?", ignoreCache: true),
    "[UInt8]": DeclaredType(from: "[UInt8]", ignoreCache: true),
    "Int32": DeclaredType(from: "Int32", ignoreCache: true),
    "Int32?": DeclaredType(from: "Int32?", ignoreCache: true),
    "[Int32]": DeclaredType(from: "[Int32]", ignoreCache: true),
    "UInt32": DeclaredType(from: "UInt32", ignoreCache: true),
    "UInt32?": DeclaredType(from: "UInt32?", ignoreCache: true),
    "[UInt32]": DeclaredType(from: "[UInt32]", ignoreCache: true),
    "Int64": DeclaredType(from: "Int64", ignoreCache: true),
    "Int64?": DeclaredType(from: "Int64?", ignoreCache: true),
    "[Int64]": DeclaredType(from: "[Int64]", ignoreCache: true),
    "UInt64": DeclaredType(from: "UInt64", ignoreCache: true),
    "UInt64?": DeclaredType(from: "UInt64?", ignoreCache: true),
    "[UInt64]": DeclaredType(from: "[UInt64]", ignoreCache: true),
  ]
}
