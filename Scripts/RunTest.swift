#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import MockingbirdCommon
import PathKit  // @kylef == 1.0.1
import Foundation

struct RunTest: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Run a test suite.",
    subcommands: [
      EndToEnd.self,
    ])
  
  struct EndToEnd: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "e2e",
      abstract: "Run all end-to-end tests.")
    func run() throws {
      var environment = ProcessInfo.processInfo.environment
      environment[BuildType.environmentKey] = String(BuildType.automation.rawValue)
      environment["SRCROOT"] = Path.current.absolute().string
      try SwiftPackage.test(environment: environment, package: Path("./Package.swift"))
    }
  }
}

RunTest.main()
