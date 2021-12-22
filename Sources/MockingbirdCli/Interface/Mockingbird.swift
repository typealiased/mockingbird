//
//  Mockingbird.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

/// Represents a CLI that can parse arguments and run the appropriate `Command`.
struct Mockingbird: ParsableCommand {
  @Flag(name: [.customLong("verbose"),
               .customShort("v")],
        help: "Log all errors, warnings, and debug messages.")
  var verbose = false
  
  @Flag(name: [.customLong("quiet"),
               .customShort("q")],
        help: "Only log error messages.")
  var quiet = false
  
  static var configuration = CommandConfiguration(
    abstract: "A convenient Swift mocking framework.",
    subcommands: [
      Configure.self,
      Generate.self,
      Version.self,
    ]
  )
  
  func validate() throws {
    if verbose {
      LogLevel.default.value = .verbose
    } else if quiet {
      LogLevel.default.value = .quiet
    }
  }
}
