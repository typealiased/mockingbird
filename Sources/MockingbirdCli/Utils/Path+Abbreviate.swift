//
//  Path+Abbreviate.swift
//  MockingbirdCli
//
//  Created by typealias on 12/23/21.
//

import Foundation
import PathKit
import MockingbirdGenerator

extension Path {
  func abbreviated(substitutionStyle: SubstitutionStyle = .bash) -> String {
    return substitutionStyle.wrap("HOME") + abbreviate().string.dropFirst()
  }
}
