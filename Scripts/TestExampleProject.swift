#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import PathKit  // @kylef == 1.0.1
import Foundation

struct TestExampleProject: ParsableCommand {
  static var configuration = CommandConfiguration(
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
    static var configuration = CommandConfiguration(commandName: "cocoapods")
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
                            deviceUUID: uuid)
      }
    }
  }
  
  struct TestCarthage: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "carthage")
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
                            deviceUUID: uuid)
      }
    }
  }
  
  struct TestSpmProject: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "spm-project")
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
                            deviceUUID: uuid)
      }
    }
  }
  
  struct TestSpmPackage: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "spm-package")
    func run() throws {
      let packagePath = Path("Examples/SPMPackageExample/Package.swift")
      try SwiftPackage.update(package: packagePath)
      try Subprocess("./gen-mocks.sh", workingDirectory: packagePath.parent()).runWithOutput()
      try SwiftPackage.test(package: packagePath)
    }
  }
}

TestExampleProject.main()
