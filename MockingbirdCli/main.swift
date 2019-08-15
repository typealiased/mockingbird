//
//  main.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import XcodeProj
import PathKit
import SourceKittenFramework
import Commander

enum MockingbirdCliConstants {
  static let generatedFileNameSuffix = "Mocks.generated.swift"
}

extension ArgumentParser {
  var environment: [String: String] { return ProcessInfo.processInfo.environment }
  
  func projectPath() throws -> Path {
    let projectPath: Path
    if let rawProjectPath = try shiftValue(for: "project") ?? environment["PROJECT_FILE_PATH"] {
      projectPath = Path(rawProjectPath)
    } else {
      throw ArgumentError.missingValue(argument: "project")
    }
    guard projectPath.isDirectory, projectPath.extension == "xcodeproj" else {
      throw ArgumentError.invalidType(value: String(describing: projectPath.absolute()),
                                      type: String(describing: Path.self),
                                      argument: nil)
    }
    return projectPath
  }
  
  func sourceRoot(for projectPath: Path) throws -> Path {
    if let rawSourceRoot = try shiftValue(for: "srcroot") ?? environment["SRCROOT"] {
      return Path(rawSourceRoot)
    } else {
      return projectPath.parent()
    }
  }
  
  func targets() throws -> [String] {
    if let targets = try shiftValue(for: "targets")?.components(separatedBy: ",") {
      return targets
    } else if let target = try shiftValue(for: "target") ?? environment["TARGET_NAME"] {
      return [target]
    } else {
      throw ArgumentError.missingValue(argument: "targets")
    }
  }
  
  func outputs() throws -> [Path]? {
    if let rawOutputs = try shiftValue(for: "outputs")?.components(separatedBy: ",") {
      return rawOutputs.map({ Path($0) })
    } else if let output = try shiftValue(for: "output") {
      return [Path(output)]
    }
    return nil
  }
}

Group {
  $0.command("generate") { (parser: ArgumentParser) in
    let projectPath = try parser.projectPath()
    let sourceRoot = try parser.sourceRoot(for: projectPath)
    let targets = try parser.targets()
    let outputs = try parser.outputs()
    
    let preprocessorExpression: String? = try parser.shiftValue(for: "preprocessor")
    let shouldImportModule = !(parser.hasOption("disable-module-import"))
    
    let config = MockingbirdCliGenerator.Configuration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      inputTargetNames: targets,
      outputPaths: outputs,
      preprocessorExpression: preprocessorExpression,
      shouldImportModule: shouldImportModule
    )
    try MockingbirdCliGenerator.generate(using: config)
  }
  
  $0.command("install") { (rawProjectPath: String, parser: ArgumentParser) in
    let projectPath = try parser.projectPath()
    let sourceRoot = try parser.sourceRoot(for: projectPath)
    let targets = try parser.targets()
    let outputs = try parser.outputs()
    
    let shouldOverride = parser.hasOption("override")
    let synchronousGeneration = parser.hasOption("synchronous")
    let preprocessorExpression: String? = try parser.shiftValue(for: "preprocessor")
    
    let config = MockingbirdCliInstaller.InstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      targetNames: targets,
      outputPaths: outputs,
      cliPath: Path(CommandLine.arguments[0]),
      shouldOverride: shouldOverride,
      synchronousGeneration: synchronousGeneration,
      preprocessorExpression: preprocessorExpression
    )
    try MockingbirdCliInstaller.install(using: config)
  }
  
  $0.command("uninstall") { (rawProjectPath: String, parser: ArgumentParser) in
    let projectPath = try parser.projectPath()
    let sourceRoot = try parser.sourceRoot(for: projectPath)
    let targets = try parser.targets()
    
    let config = MockingbirdCliInstaller.UninstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      targetNames: targets
    )
    try MockingbirdCliInstaller.uninstall(using: config)
  }
}.run()
