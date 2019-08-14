//
//  GenericType.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/10/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

struct GenericType: Hashable {
  let name: String
  let inheritedTypes: Set<String>
  
  init?(from dictionary: StructureDictionary) {
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind == .genericTypeParam,
      let name = dictionary[SwiftDocKey.name.rawValue] as? String
      else { return nil }
    self.name = name
    var inheritedTypes = Set<String>()
    if let rawInheritedTypes = dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] {
      for rawInheritedType in rawInheritedTypes {
        guard let name = rawInheritedType[SwiftDocKey.name.rawValue] as? String else { continue }
        inheritedTypes.insert(name)
      }
    }
    self.inheritedTypes = inheritedTypes
  }
}
