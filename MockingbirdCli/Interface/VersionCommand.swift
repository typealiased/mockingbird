//
//  VersionCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation
import MockingbirdGenerator
import SPMUtility

struct VersionCommand: Command {
  let command = "version"
  let overview = "Returns the current CLI generator version."
  
  init(parser: ArgumentParser) {
    _ = parser.add(subparser: command, overview: overview)
  }
  
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    print(mockingbirdVersion)
  }
}
