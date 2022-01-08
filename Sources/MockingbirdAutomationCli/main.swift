import Foundation
import ArgumentParser

struct Automation: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Task runner for Mockingbird.",
    subcommands: [
      Build.self,
      Test.self,
      Configure.self,
    ])
}

Automation.main()
