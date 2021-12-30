import ArgumentParser
import MockingbirdAutomation
import PathKit
import Foundation

struct Test: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Run a test suite.",
    subcommands: [
      TestE2E.self,
      TestExampleProject.self,
    ])
  
  struct TestE2E: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "e2e",
      abstract: "Run all end-to-end tests.")
    func run() throws {
      var environment = ProcessInfo.processInfo.environment
      environment["SRCROOT"] = Path.current.absolute().string
      try SwiftPackage.test(environment: environment,
                            packageConfiguration: .executables,
                            package: Path("./Package.swift"))
    }
  }
}
