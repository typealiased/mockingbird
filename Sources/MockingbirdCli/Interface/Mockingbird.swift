//
//  Mockingbird.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import ArgumentParser
import Foundation
import MockingbirdCommon
import MockingbirdGenerator
import PathKit

/// Represents a CLI that can parse arguments and run the appropriate `Command`.
struct Mockingbird: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "A convenient Swift mocking framework.",
    version: "\(mockingbirdVersion)",
    subcommands: [
      Configure.self,
      Generate.self,
      Version.self,
    ]
  )
  
  struct Options: ParsableArguments {
    @Flag(help: "Log all errors, warnings, and debug messages.")
    var verbose = false
    
    @Flag(help: "Only log error messages.")
    var quiet = false
  }
  
  @OptionGroup() var globalOptions: Options
  
  func validate() throws {
    if globalOptions.verbose {
      LogLevel.default.value = .verbose
    } else if globalOptions.quiet {
      LogLevel.default.value = .quiet
    }
  }
}

extension Mockingbird.Options: EncodableArguments {
  enum CodingKeys: String, CodingKey {
    case verbose
    case quiet
  }
  
  func encode(to encoder: Encoder) throws {
    try encodeOptions(to: encoder)
    try encodeFlags(to: encoder)
    try encodeOptionGroups(to: encoder)
  }
  
  func encodeOptions(to encoder: Encoder) throws {}
  
  func encodeFlags(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(verbose, forKey: .verbose)
    try container.encode(quiet, forKey: .quiet)
  }
  
  func encodeOptionGroups(to encoder: Encoder) throws {}
}
