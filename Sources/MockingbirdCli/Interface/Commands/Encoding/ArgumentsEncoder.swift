//
//  ArgumentsEncoder.swift
//  MockingbirdCli
//
//  Created by typealias on 12/20/21.
//

import Foundation
import MockingbirdGenerator
import PathKit

protocol EncodableArguments: Encodable {
  func encodeOptions(to encoder: Encoder) throws
  func encodeFlags(to encoder: Encoder) throws
  func encodeOptionGroups(to encoder: Encoder) throws
}

/// Encodes an object into an array of command line option and flag arguments.
class ArgumentsEncoder {
  var sourceRoot: Path?
  var substitutionStyle: SubstitutionStyle = .bash
  
  func encode<T: EncodableArguments>(_ value: T) throws -> [String] {
    var pathConfig: OptionArgumentEncoding.PathConfiguration?
    if let sourceRoot = sourceRoot {
      pathConfig = OptionArgumentEncoding.PathConfiguration(
        sourceRoot: sourceRoot,
        substitutionStyle: substitutionStyle
      )
    }
    
    let optionEncoding = OptionArgumentEncoding(pathConfig: pathConfig)
    try value.encodeOptions(to: optionEncoding)
    
    let flagEncoding = FlagArgumentEncoding()
    try value.encodeFlags(to: flagEncoding)
    
    let optionGroupEncoding = OptionGroupArgumentEncoding()
    try value.encodeOptionGroups(to: optionGroupEncoding)
    
    return optionEncoding.data.arguments
      + flagEncoding.data.arguments
      + optionGroupEncoding.data.arguments
  }
}

extension CodingKey {
  var longArgumentName: String {
    let hyphenatedName = stringValue.unicodeScalars.reduce(into: "") { (name, character) in
      if CharacterSet.uppercaseLetters.contains(character) {
        name += "-" + String(character).localizedLowercase
      } else {
        name += String(character)
      }
    }
    return "--\(hyphenatedName)"
  }
}
