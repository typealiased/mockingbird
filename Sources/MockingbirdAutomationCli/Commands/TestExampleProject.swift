import ArgumentParser
import MockingbirdAutomation
import PathKit
import MockingbirdAutomation
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
          let workspacePath = Path("Examples/CocoaPodsExample/CocoaPodsExample.xcworkspace")
          try CocoaPods.install(workspace: workspacePath)
          try XcodeBuild.test(target: .scheme(name: "CocoaPodsExample"),
                              project: .workspace(path: workspacePath),
                              destination: .iOSSimulator(deviceUUID: uuid))
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
          let projectPath = Path("Examples/CarthageExample/CarthageExample.xcodeproj")
          try Carthage.update(platform: .iOS, project: projectPath)
          try XcodeBuild.test(target: .scheme(name: "CarthageExample"),
                              project: .project(path: projectPath),
                              destination: .iOSSimulator(deviceUUID: uuid))
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
        let packagePath = Path("Examples/SPMPackageExample/Package.swift")
        try SwiftPackage.update(package: packagePath)
        try Subprocess("./gen-mocks.sh", workingDirectory: packagePath.parent()).run()
        try SwiftPackage.test(package: packagePath)
      }
    }
  }
}
