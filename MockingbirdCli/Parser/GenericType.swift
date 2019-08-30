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
  let genericConstraints: [String]
  
  struct Reduced: Hashable {
    let name: String
    init(from genericType: GenericType) {
      self.name = genericType.name
    }
  }
  
  init?(from dictionary: StructureDictionary, rawType: RawType) {
    guard let kind = SwiftDeclarationKind(from: dictionary),
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
    
    var genericConstraints = [String]()
    if kind == .associatedtype { // We need to manually parse any associated type constraint.
      let source = rawType.parsedFile.file.contents
      if let declaration = SourceSubstring.key.extract(from: dictionary, contents: source),
        let inferredTypeLowerBound = declaration.firstIndex(of: ":") {
        let inferredTypeStartIndex = declaration.index(after: inferredTypeLowerBound)
        let typeDeclaration = declaration[inferredTypeStartIndex...]
        
        if let whereRange = typeDeclaration.range(of: #"\bwhere\b"#, options: .regularExpression) {
          let inferredType = typeDeclaration[..<whereRange.lowerBound]
          inheritedTypes.insert(String(inferredType.trimmingCharacters(in: .whitespacesAndNewlines)))
          genericConstraints = typeDeclaration[whereRange.upperBound...]
            .substringComponents(separatedBy: ",")
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
          genericConstraints = GenericType.rewriteSelfTypes(constraints: genericConstraints,
                                                            containingType: rawType)
        } else {
          inheritedTypes.insert(String(typeDeclaration.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
      }
    }
    self.genericConstraints = genericConstraints
    self.inheritedTypes = inheritedTypes
  }
  
  static func rewriteSelfTypes(constraints: [String], containingType: RawType) -> [String] {
    return constraints.map({
      let components = $0.substringComponents(separatedBy: "=")
      guard components.count == 3,
        components[2].trimmingCharacters(in: .whitespaces) == "Self" else { return $0 }
      return "\(components[0].trimmingCharacters(in: .whitespaces)) == \(containingType.name)Mock"
    })
  }
}
