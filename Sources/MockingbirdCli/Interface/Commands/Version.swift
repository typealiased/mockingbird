//
//  Version.swift
//  MockingbirdCli
//
//  Created by typealias on 12/20/21.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

extension Mockingbird {
  struct Version: ParsableCommand {
    func run() throws {
      logInfo("\(mockingbirdVersion)")
    }
  }
}
