//
//  CharacterSet+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/30/19.
//

import Foundation

extension CharacterSet {
  static func createOptionalsSet() -> CharacterSet {
    var characterSet = CharacterSet()
    characterSet.insert(charactersIn: "!?")
    return characterSet
  }
}
