//
//  Typealias.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/29/19.
//

import Foundation
import SourceKittenFramework

struct Typealias: Hashable {
  let name: String
  let typeName: String // Possible that this references another typealias.
  
  init?(from dictionary: StructureDictionary, rawType: RawType) {
    guard let kind = SwiftDeclarationKind(from: dictionary), kind == .typealias,
      let name = dictionary[SwiftDocKey.name.rawValue] as? String
      else { return nil }
    self.name = name
    
    let source = rawType.parsedFile.file.contents
    guard let typeName = SourceSubstring.nameSuffix.extract(from: dictionary, contents: source),
      let declarationIndex = typeName.firstIndex(of: "=") else { return nil }
    let declaration = typeName[typeName.index(after: declarationIndex)...]
    self.typeName = declaration.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
