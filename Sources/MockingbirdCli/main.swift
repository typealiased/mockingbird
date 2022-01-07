//
//  main.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdGenerator

do {
  defer { flushLogs() }
  var command = try Mockingbird.parseAsRoot()
  try command.run()
} catch {
  Mockingbird.exit(withError: error)
}
