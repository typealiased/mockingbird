//
//  main.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdGenerator
import PathKit

loadDylibs([swiftSyntaxParserDylib]) {
  do {
    var command = try Mockingbird.parseAsRoot()
    switch command {
    case var subcommand as Mockingbird.Configure:
      try subcommand.run()
    default:
      try command.run()
    }
    flushLogs()
  } catch {
    flushLogs()
    Mockingbird.exit(withError: error)
  }
}
