#!/usr/bin/env xcrun swift sh

import ArgumentParser  // apple/swift-argument-parser == 1.0.2
import MockingbirdAutomation  // ../
import PathKit  // @kylef == 1.0.1
import Foundation

struct TestExampleProject: ParsableCommand {
  static var configuration = CommandConfiguration(abstract: "Run end-to-end example project tests.")
  
  @Argument(help: "The type of example project to test.")
  var type: ExampleProjectType
  
  enum ExampleProjectType: String, Codable, ExpressibleByArgument {
    case cocoapods = "cocoapods"
    case carthage = "carthage"
    case spmProject = "spm-project"
    case spmPackage = "spm-package"
  }
  
  func testCocoaPods(uuid: UUID) throws {
    let workspacePath = Path("Examples/CocoaPodsExample/CocoaPodsExample.xcworkspace")
    try CocoaPods.install(workspace: workspacePath)
    try XcodeBuild.test(target: .scheme(name: "CocoaPodsExample"),
                        project: .workspace(path: workspacePath),
                        deviceUUID: uuid)
  }
  
  func testCarthage(uuid: UUID) throws {
    let projectPath = Path("Examples/CarthageExample/CarthageExample.xcodeproj")
    try Carthage.update(platform: .iOS, project: projectPath)
    try XcodeBuild.test(target: .scheme(name: "CarthageExample"),
                        project: .project(path: projectPath),
                        deviceUUID: uuid)
  }
  
  func testSpmProject(uuid: UUID) throws {
    let projectPath = Path("Examples/SPMProjectExample/SPMProjectExample.xcodeproj")
    try XcodeBuild.resolvePackageDependencies(project: .project(path: projectPath))
    try XcodeBuild.test(target: .scheme(name: "SPMProjectExample"),
                        project: .project(path: projectPath),
                        deviceUUID: uuid)
  }
  
  func testSpmPackage() throws {
    let packagePath = Path("Examples/SPMPackageExample/Package.swift")
    try SwiftPackage.update(package: packagePath)
    try Subprocess("./gen-mocks.sh", workingDirectory: packagePath.parent())
    try SwiftPackage.test(package: packagePath)
  }
  
  func run() throws {
    try Simulator.performInSimulator { uuid in
      guard let uuid = uuid else {
        logError("Unable to create simulator")
        return
      }
      
      logInfo("Testing example project of type \(singleQuoted: type.rawValue)")
      switch type {
      case .cocoapods: try testCocoaPods(uuid: uuid)
      case .carthage: try testCarthage(uuid: uuid)
      case .spmProject: try testSpmProject(uuid: uuid)
      case .spmPackage: try testSpmPackage()
      }
    }
  }
}

TestExampleProject.main()
