import ArgumentParser
import MockingbirdAutomation
import PathKit
import MockingbirdAutomation
import Foundation

struct Configure: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Configure the project environment.",
    subcommands: [
      LoadSchemes.self,
      UnloadSchemes.self,
      SaveSchemes.self,
    ])
  
  enum Constants {
    static let resourcesPath = Path("./Sources/MockingbirdAutomation/Resources")
    static let projectPath = Path("./Mockingbird.xcodeproj")
  }
  
  struct LoadSchemes: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "load",
      abstract: "Apply shared schemes to the Xcode project.")
    
    @Flag(help: "Overwrite existing schemes.")
    var overwrite: Bool = false
    
    func run() throws {
      let schemes = (Constants.resourcesPath + "XcodeSchemes").glob("*.xcscheme")
      logInfo("Found \(schemes.count) scheme\(schemes.count != 1 ? "s" : "") to load")
      try schemes.forEach({ scheme in
        let destination = Constants.projectPath + "xcshareddata/xcschemes" + scheme.lastComponent
        guard overwrite || !destination.isFile else {
          logInfo("Skipping existing scheme \(singleQuoted: destination.lastComponent)")
          return
        }
        try? destination.delete()
        try scheme.copy(destination)
        logInfo("Copied scheme to \(destination.abbreviate())")
      })
    }
  }

  struct UnloadSchemes: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "unload",
      abstract: "Remove shared schemes.")
    
    @Option(parsing: .upToNextOption, help: "Schemes to keep in the Xcode project.")
    var keep: [String] = []
    
    func run() throws {
      let schemes = (Constants.projectPath + "xcshareddata/xcschemes").glob("*.xcscheme")
      logInfo("Found \(schemes.count) potential scheme\(schemes.count != 1 ? "s" : "") to unload")
      let denyList = Set(keep)
      try schemes.forEach({ scheme in
        guard !denyList.contains(scheme.lastComponentWithoutExtension) else { return }
        try scheme.delete()
        logInfo("Unloaded scheme at \(scheme.abbreviate())")
      })
    }
  }
  
  struct SaveSchemes: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "save",
      abstract: "Save shared Xcode schemes.")
    func run() throws {
      let schemes = (Constants.projectPath + "xcshareddata/xcschemes").glob("*.xcscheme")
      logInfo("Found \(schemes.count) scheme\(schemes.count != 1 ? "s" : "") to save")
      try schemes.forEach({ scheme in
        let destination = Constants.resourcesPath + "XcodeSchemes" + scheme.lastComponent
        try? destination.delete()
        try scheme.copy(destination)
        logInfo("Copied scheme to \(destination.abbreviate())")
      })
    }
  }
}
