import ArgumentParser
import Foundation
import MockingbirdAutomation
import PathKit

extension Build {
  struct BuildFramework: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "framework",
      abstract: "Build a fat XCFramework bundle.")
    
    @Option(name: [.customLong("platform"),
                   .customLong("platforms")],
            parsing: .upToNextOption,
            help: "List of target platforms to build against.")
    var platforms: [Carthage.Platform] = [.all]
    
    @OptionGroup()
    var globalOptions: Options
    
    func getVersionString() throws -> String {
      return try PlistBuddy.printValue(key: "CFBundleShortVersionString",
                                       plist: Path("./Sources/MockingbirdFramework/Info.plist"))
    }
    
    func run() throws {
      // Carthage with `--no-skip-current` searches for matching schemes in all nested Xcode
      // projects and workspaces, even with `--project-directory` specified. To avoid building the
      // framework via the example project dependencies, we lock the Example directory by making it
      // write-only until the build completes.
      logInfo("Locking the example projects directory")
      let exampleProjects = Path("./Examples")
      let fileManager = FileManager()
      let originalAttributes = try fileManager.attributesOfItem(atPath: exampleProjects.string)
      try fileManager.setAttributes([.posixPermissions: FileManager.PosixPermissions.writeOnly],
                                    ofItemAtPath: exampleProjects.string)
      defer {
        logInfo("Unlocking the example projects directory")
        try? fileManager.setAttributes([.posixPermissions: originalAttributes[.posixPermissions]
                                          ?? FileManager.PosixPermissions.readWrite],
                                       ofItemAtPath: exampleProjects.string)
      }

      let projectPath = Path("./Mockingbird.xcodeproj")
      try Carthage.build(platforms: platforms, project: projectPath)
      
      // Carthage doesn't provide a way to query for the built product path, so this is inferred.
      let frameworkPath = projectPath.parent() + "Carthage/Build/Mockingbird.xcframework"
      
      if let location = globalOptions.archiveLocation {
        try archive(artifacts: [("", frameworkPath)],
                    destination: Path(location),
                    includeLicense: false)
      }
    }
  }
}
