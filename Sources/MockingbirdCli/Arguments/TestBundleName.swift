//
//  TestBundleName.swift
//  MockingbirdCli
//
//  Created by typealias on 8/13/21.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

struct TestBundleName: ExpressibleByArgument {
  var name: String
  var defaultValueDescription: String { name }
  
  init?(argument: String) {
    self.name = argument
  }
}

extension TestBundleName: Encodable {
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(name)
  }
}

extension TestBundleName: InferableArgument {
  init?(context: ArgumentContext) throws {
    guard let targetName =
            context.environment["TARGET_NAME"] ??
            context.environment["TARGETNAME"] else {
      return nil
    }
    
    log("Using inferred test bundle name \(singleQuoted: targetName)")
    self.init(argument: targetName)
  }
}
