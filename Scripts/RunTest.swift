#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import PathKit  // @kylef == 1.0.1
import Foundation

struct RunTest: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Run end-to-end tests.",
    subcommands: [
      
    ])
  
  struct
}

RunTest.main()
