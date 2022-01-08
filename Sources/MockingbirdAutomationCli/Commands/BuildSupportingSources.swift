import ArgumentParser
import Foundation
import MockingbirdAutomation
import PathKit

extension Build {
  struct BuildSupportingSources: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "supporting",
      abstract: "Build a supporting source files bundle.")
    
    @OptionGroup()
    var globalOptions: Options
    
    func run() throws {
      guard let location = globalOptions.archiveLocation else {
        logError("You must specify an archive location when building supporting sources")
        return
      }
      let modules = try Path("Sources/MockingbirdSupport").children()
      try archive(artifacts: modules.map({ ("", $0) }), destination: Path(location))
    }
  }
}
