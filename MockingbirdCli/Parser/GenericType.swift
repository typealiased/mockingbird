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
  
  struct Reduced: Hashable {
    let name: String
    init(from genericType: GenericType) {
      self.name = genericType.name
    }
  }
  
  init?(from dictionary: StructureDictionary, rawType: RawType) {
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind),
      kind == .genericTypeParam || kind == .associatedtype,
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
    
    if kind == .associatedtype { // Need to manually parse any associated type constraint.
      let source = rawType.parsedFile.file.contents
      if let declaration = SourceSubstring.key.extract(from: dictionary, contents: source),
        let inferredType = declaration.substringComponents(separatedBy: ":").get(1) {
        inheritedTypes.insert(String(inferredType.trimmingCharacters(in: .whitespacesAndNewlines)))
      }
    }
    
    self.inheritedTypes = inheritedTypes
  }
}
