import ArgumentParser
import MockingbirdAutomation
import MockingbirdCommon
import PathKit
import Foundation

extension Test {
  struct TestExampleProject: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "example",
      abstract: "Run an end-to-end example project test.",
      subcommands: [
        TestCocoaPods.self,
        TestCarthage.self,
        TestSpmProject.self,
        TestSpmPackage.self,
      ])
    
    enum ExampleProjectType: String, Codable, ExpressibleByArgument {
      case cocoapods = "cocoapods"
      case carthage = "carthage"
      case spmProject = "spm-project"
      case spmPackage = "spm-package"
    }
    
    static func applyLocallyBuiltCli(binPath: Path) throws {
      try? binPath.delete()
      try binPath.mkpath()
      let cliPath = try SwiftPackage.build(target: .product(name: "mockingbird"),
                                           configuration: .debug,
                                           package: Path("Package.swift"))
      try cliPath.copy(binPath + "mockingbird")
      let cliLibrariesPath = Path("Sources/MockingbirdCli/Resources/Libraries")
      try cliLibrariesPath.copy(binPath + cliLibrariesPath.lastComponent)
    }
    
    static func backup(_ files: [Path], block: () throws -> Void) throws {
      try files.forEach({ try $0.backup() })
      defer { files.forEach({ try? $0.restore() }) }
      try block()
    }
    
    struct TestCocoaPods: ParsableCommand {
      static var configuration = CommandConfiguration(
        commandName: "cocoapods",
        abstract: "Test the CocoaPods example project.")
      func run() throws {
        try Simulator.performInSimulator { uuid in
          guard let uuid = uuid else {
            logError("Unable to create simulator")
            return
          }
          
          let srcroot = Path("Examples/CocoaPodsExample")
          let workspacePath = srcroot + "CocoaPodsExample.xcworkspace"
          let podfilePath = srcroot + "Podfile"
          try backup([podfilePath, srcroot + "Podfile.lock"]) {
            // Point to the local revision.
            let rev = try Git.getHEAD(repository: Path.current)
            let podfileContents = try podfilePath.read()
              .replacingOccurrences(of: #"pod 'MockingbirdFramework', '~> [\d\.]+'"#,
                                    with: "pod 'MockingbirdFramework', " +
                                      ":git => '\(Path.current.absolute())', " +
                                      ":commit => '\(rev)'",
                                    options: [.regularExpression])
            try podfilePath.delete()
            try podfilePath.write(podfileContents)
            
            // Pull and build the framework.
            try CocoaPods.install(workspace: workspacePath)
            
            // Inject the local binary.
            let binPath = srcroot + "Pods/MockingbirdFramework/bin/\(mockingbirdVersion)"
            try applyLocallyBuiltCli(binPath: binPath)
            
            try XcodeBuild.test(target: .scheme(name: "CocoaPodsExample"),
                                project: .workspace(path: workspacePath),
                                destination: .iOSSimulator(deviceUUID: uuid))
          }
        }
      }
    }
    
    struct TestCarthage: ParsableCommand {
      static var configuration = CommandConfiguration(
        commandName: "carthage",
        abstract: "Test the Carthage example project.")
      func run() throws {
        try Simulator.performInSimulator { uuid in
          guard let uuid = uuid else {
            logError("Unable to create simulator")
            return
          }
          
          let srcroot = Path("Examples/CarthageExample")
          let cartfilePath = srcroot + "Cartfile"
          try backup([cartfilePath, srcroot + "Cartfile.resolved"]) {
            // Point to the local revision.
            try cartfilePath.write("""
            git "file://\(Path.current.absolute())" "HEAD"
            """)
            
            // Pull and build the framework.
            try? (srcroot + "Carthage").delete()
            let projectPath = srcroot + "CarthageExample.xcodeproj"
            try Carthage.update(platforms: [.iOS], project: projectPath)
            
            // Inject the local binary.
            let binPath = srcroot + "Carthage/Checkouts/mockingbird/bin/\(mockingbirdVersion)"
            try applyLocallyBuiltCli(binPath: binPath)
            
            try XcodeBuild.test(target: .scheme(name: "CarthageExample"),
                                project: .project(path: projectPath),
                                destination: .iOSSimulator(deviceUUID: uuid))
          }
        }
      }
    }
    
    struct TestSpmProject: ParsableCommand {
      static var configuration = CommandConfiguration(
        commandName: "spm-project",
        abstract: "Test the SwiftPM example project.")
      func run() throws {
        try Simulator.performInSimulator { uuid in
          guard let uuid = uuid else {
            logError("Unable to create simulator")
            return
          }
          let projectPath = Path("Examples/SPMProjectExample/SPMProjectExample.xcodeproj")
          try XcodeBuild.resolvePackageDependencies(project: .project(path: projectPath))
          try XcodeBuild.test(target: .scheme(name: "SPMProjectExample"),
                              project: .project(path: projectPath),
                              destination: .iOSSimulator(deviceUUID: uuid))
        }
      }
    }
    
    struct TestSpmPackage: ParsableCommand {
      static var configuration = CommandConfiguration(
        commandName: "spm-package",
        abstract: "Test the SwiftPM example package.")
      func run() throws {
        let srcroot = Path("Examples/SPMPackageExample")
        let packagePath = srcroot + "Package.swift"
        try backup([packagePath, srcroot + "Package.resolved"]) {
          // Point to the local revision.
          let rev = try Git.getHEAD(repository: Path.current)
          let packageContents = try packagePath.read()
            .replacingOccurrences(of: "https://github.com/birdrides/mockingbird.git",
                                  with: Path.current.absolute().string)
            .replacingOccurrences(of: #"\.upToNextMinor\(from: "[\d\.]+"\)"#,
                                  with: ".revision(\(doubleQuoted: rev))",
                                  options: [.regularExpression])
          try packagePath.delete()
          try packagePath.write(packageContents)
          
          // Pull and build the framework.
          try SwiftPackage.update(package: packagePath, packageConfiguration: .libraries)
          
          // Inject the local binary.
          let binPath = srcroot + ".build/checkouts/mockingbird/bin/\(mockingbirdVersion)"
          try applyLocallyBuiltCli(binPath: binPath)
          
          try Subprocess("./gen-mocks.sh", workingDirectory: packagePath.parent()).run()
          try SwiftPackage.test(packageConfiguration: .libraries, package: packagePath)
        }
      }
    }
  }
}
