//
//  SwiftFilePath.swift
//  MockingbirdCli
//
//  Created by typealias on 12/23/21.
//

import ArgumentParser
import Foundation
import PathKit
import MockingbirdGenerator

struct SwiftFilePath: ExpressibleByArgument {
  var path: Path
  var defaultValueDescription: String { path.abbreviate().string }
  static var defaultCompletionKind: CompletionKind = .file(extensions: ["swift"])
  
  init?(argument: String) {
    self.path = Path(argument)
  }
}

extension SwiftFilePath: Encodable {
  func encode(to encoder: Encoder) throws {
    try OptionArgumentEncoding.encode(path, with: encoder)
  }
}
