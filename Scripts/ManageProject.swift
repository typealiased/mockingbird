#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import PathKit  // @kylef == 1.0.1
import Foundation

struct ManageProject: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "Manage the project environment.",
    subcommands: [
      LoadSchemes.self,
      UnloadSchemes.self,
      SaveSchemes.self,
    ])
  
  struct LoadSchemes: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "load")
    
    @Flag(help: "Overwrite existing schemes.")
    var overwrite: Bool = false
    
    func run() throws {
      let schemes = try Path("Scripts/Resources/XcodeSchemes").glob("*.xcscheme")
      logInfo("Found \(schemes.count) scheme\(schemes.count != 1 ? "s" : "") to load")
      try schemes.forEach({ scheme in
        let destination = Path("Mockingbird.xcodeproj/xcshareddata/xcschemes")
          + scheme.lastComponent
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
      let schemes = try Path("Mockingbird.xcodeproj/xcshareddata/xcschemes").glob("*.xcscheme")
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
    static var configuration = CommandConfiguration(commandName: "save")
    func run() throws {
      let schemes = try Path("Mockingbird.xcodeproj/xcshareddata/xcschemes").glob("*.xcscheme")
      logInfo("Found \(schemes.count) scheme\(schemes.count != 1 ? "s" : "") to save")
      try schemes.forEach({ scheme in
        let destination = Path("Scripts/Resources/XcodeSchemes") + scheme.lastComponent
        try? destination.delete()
        try scheme.copy(destination)
        logInfo("Copied scheme to \(destination.abbreviate())")
      })
    }
  }
}

ManageProject.main()
