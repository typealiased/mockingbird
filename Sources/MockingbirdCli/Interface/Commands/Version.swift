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
    static var configuration = CommandConfiguration(
      abstract: "Show the version.",
      shouldDisplay: false
    )
    
    func run() throws {
      logInfo("\(mockingbirdVersion)")
    }
  }
}
