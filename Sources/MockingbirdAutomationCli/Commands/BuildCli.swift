import ArgumentParser
import Foundation
import MockingbirdAutomation
import PathKit

extension Build {
  struct BuildCli: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "cli",
      abstract: "Build the command line interface.")
    
    @Option(name: .customLong("sign"), help: "Identity used to sign the built binary.")
    var signingIdentity: String?
    
    @Option(help: "File path containing the designated requirement for codesigning.")
    var requirements: String =
      "./Sources/MockingbirdAutomationCli/Resources/CodesigningRequirements/mockingbird.txt"
    
    @OptionGroup()
    var globalOptions: Options
    
    func getVersionString() throws -> String {
      return try PlistBuddy.printValue(key: "CFBundleShortVersionString",
                                       plist: Path("./Sources/MockingbirdCli/Info.plist"))
    }
    
    func fixupRpaths(binary: Path) throws {
      let version = try getVersionString()
      
      // Get rid of toolchain-dependent rpaths which aren't guaranteed to have a compatible version
      // of the internal SwiftSyntax parser lib.
      let developerDirectory = try XcodeSelect.printPath()
      let swiftToolchainPath = developerDirectory
        + "Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"
      try? InstallNameTool.deleteRpath(swiftToolchainPath.absolute().string, binary: binary)
      // Swift 5.5 is only present in Xcode 13.2+
      let swift5_5ToolchainPath = developerDirectory
        + "Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.5/macosx"
      try? InstallNameTool.deleteRpath(swift5_5ToolchainPath.absolute().string, binary: binary)
      
      // Add new rpaths in descending order of precedence.
      try InstallNameTool.addRpath("/usr/lib/mockingbird/\(version)", binary: binary)
      // Support environments with restricted write permissions to system resources.
      try InstallNameTool.addRpath("/var/tmp/lib/mockingbird/\(version)", binary: binary)
      try InstallNameTool.addRpath("/tmp/lib/mockingbird/\(version)", binary: binary)
    }
    
    func run() throws {
      let packagePath = Path("./Package.swift")
      let cliPath = try SwiftPackage.build(target: .product(name: "mockingbird"),
                                           configuration: .release,
                                           packageConfiguration: .executables,
                                           package: packagePath)
      try fixupRpaths(binary: cliPath)
      if let identity = signingIdentity {
        try Codesign.sign(binary: cliPath, identity: identity)
        try Codesign.verify(binary: cliPath, requirements: Path(requirements))
      }
      if let location = globalOptions.archiveLocation {
        let libRoot = Path("./Sources/MockingbirdCli/Resources/Libraries")
        let libPaths = libRoot.glob("*.dylib") + [libRoot + "LICENSE.txt"]
        try archive(artifacts: [("", cliPath)] + libPaths.map({ ("Libraries", $0) }),
                    destination: Path(location))
      }
    }
  }
}
