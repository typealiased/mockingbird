//
//  main.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit

loadDylibs([swiftSyntaxParserDylib]) {
  do {
    switch try Mockingbird.parseAsRoot() {
    case var command as Mockingbird.Configure:
      try command.run()
    default:
      break // TODO
    }
  } catch {
    Mockingbird.exit(withError: error)
  }
}
