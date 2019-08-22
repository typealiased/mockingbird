//
//  TypeAttributes.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

typealias StructureDictionary = [String: SourceKitRepresentable]

extension SwiftDeclarationKind {
  var isMockable: Bool {
    switch self {
    case .class, .protocol: return true
    default: return false
    }
  }
  
  var isParsable: Bool {
    switch self {
    case .class, .protocol, .extension: return true
    default: return false
    }
  }
  
  var isMethod: Bool {
    switch self {
    case .functionMethodInstance, .functionMethodStatic, .functionMethodClass: return true
    default: return false
    }
  }
  
  var isVariable: Bool {
    switch self {
    case .varInstance, .varStatic, .varClass: return true
    default: return false
    }
  }
  
  var typeScope: TypeScope {
    switch self {
    case .functionMethodClass, .varClass: return .class
    case .functionMethodStatic, .varStatic: return .static
    default: return .instance
    }
  }
}

enum TypeScope {
  case `instance`, `static`, `class`
}

struct Attributes: OptionSet, Hashable {
  let rawValue: Int
  init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  static func create(from kind: SwiftDeclarationAttributeKind) -> Attributes? {
    switch kind {
    case .final: return .final
    case .required: return .required
    case .optional: return .optional
    case .lazy: return .lazy
    case .dynamic: return .dynamic
    case .weak: return .weak
    case .rethrows: return .rethrows
    default: return nil
    }
  }
  
  static func create(from dictionary: StructureDictionary) -> Attributes {
    var attributes: Attributes = []
    guard let rawAttributes = dictionary[Attributes.attributesKey] as? [StructureDictionary] else {
      return attributes
    }
    for rawAttributeDictionary in rawAttributes {
      guard let rawAttribute = rawAttributeDictionary[Attributes.attributeKey] as? String,
        let attributeKind = SwiftDeclarationAttributeKind(rawValue: rawAttribute),
        let attribute = Attributes.create(from: attributeKind) else { continue }
      attributes.insert(attribute)
    }
    return attributes
  }
  
  // SourceKit-provided attributes
  static let final = Attributes(rawValue: 1 << 0)
  static let required = Attributes(rawValue: 1 << 1)
  static let optional = Attributes(rawValue: 1 << 2)
  static let lazy = Attributes(rawValue: 1 << 3)
  static let dynamic = Attributes(rawValue: 1 << 4)
  static let weak = Attributes(rawValue: 1 << 5)
  static let `rethrows` = Attributes(rawValue: 1 << 6)
  
  // Inferred attributes
  static let constant = Attributes(rawValue: 1 << 7)
  static let computed = Attributes(rawValue: 1 << 8)
  static let `throws` = Attributes(rawValue: 1 << 9)
  static let `inout` = Attributes(rawValue: 1 << 10)
  static let variadic = Attributes(rawValue: 1 << 11)
  
  static let attributesKey = "key.attributes"
  static let attributeKey = "key.attribute"
}

enum AccessLevel: String, CustomStringConvertible {
  case `open` = "source.lang.swift.accessibility.open"
  case `public` = "source.lang.swift.accessibility.public"
  case `internal` = "source.lang.swift.accessibility.internal"
  case `fileprivate` = "source.lang.swift.accessibility.fileprivate"
  case `private` = "source.lang.swift.accessibility.private"
  
  static let accessLevelKey = "key.accessibility"
  static let setterAccessLevelKey = "key.setter_accessibility"
  
  var description: String {
    switch self {
    case .open: return "open"
    case .public: return "public"
    case .internal: return "internal"
    case .fileprivate: return "fileprivate"
    case .private: return "private"
    }
  }
}
