import ArgumentParser
import Foundation
import MockingbirdAutomation
import PathKit

struct Build: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Build a project artifact.",
    subcommands: [
      BuildCli.self,
      BuildFramework.self,
      BuildDocumentation.self,
      BuildSupportingSources.self,
    ])
  
  struct Options: ParsableArguments {
    @Option(name: .customLong("archive"), help: "File path to store archived built products.")
    var archiveLocation: String?
  }
  
  @OptionGroup()
  var globalOptions: Options
  
  static func archive(artifacts: [(location: String, path: Path)],
                      destination: Path,
                      includeLicense: Bool = true) throws {
    guard !artifacts.isEmpty else {
      logError("No artifacts to archive")
      return
    }
    guard destination.extension == "zip" else {
      logError("Archive destination is not a ZIP file")
      return
    }
    logInfo("Creating archive at \(destination.abbreviate())")
      
    let stagingPath = Path("./.build/mockingbird/intermediates")
      + destination.lastComponentWithoutExtension
    try? stagingPath.delete()
    try stagingPath.mkpath()
    
    var items = artifacts
    if includeLicense { items.append(("", Path("./LICENSE.md"))) }
    try items.forEach({ artifact in
      let destination = stagingPath + artifact.location + artifact.path.lastComponent
      try destination.parent().mkpath()
      try artifact.path.copy(destination)
    })
    
    try? destination.delete()
    try destination.parent().mkpath()
    try Zip.deflate(input: items.count == 1 ? items[0].path : stagingPath,
                    output: destination)
  }
}

extension Carthage.Platform: ExpressibleByArgument {}
