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

Group {
  $0.command("generate") { (rawProjectPath: String, parser: ArgumentParser) in
    let projectPath = Path(rawProjectPath)
    guard projectPath.isDirectory else {
      throw ArgumentError.invalidType(value: rawProjectPath,
                                      type: String(describing: Path.self),
                                      argument: nil)
    }

    let sourceRoot: Path
    if let rawSourceRoot = try parser.shiftValue(for: "srcroot") {
      sourceRoot = Path(rawSourceRoot)
    } else {
      sourceRoot = projectPath.parent()
    }
    
    guard let targets = try (parser.shiftValue(for: "target") ?? parser.shiftValue(for: "targets"))?
      .components(separatedBy: ",") else {
        throw ArgumentError.missingValue(argument: "targets")
    }
    
    let outputs = try (parser.shiftValue(for: "output") ?? parser.shiftValue(for: "outputs"))?
      .components(separatedBy: ",").map({ Path($0) })
    
    let preprocessorExpression: String? = try parser.shiftValue(for: "preprocessor")
    let shouldImportModule = !(parser.hasOption("no-module-import"))
    
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
    let projectPath = Path(rawProjectPath)
    guard projectPath.isDirectory else {
      throw ArgumentError.invalidType(value: rawProjectPath,
                                      type: String(describing: Path.self),
                                      argument: nil)
    }
    
    let sourceRoot: Path
    if let rawSourceRoot = try parser.shiftValue(for: "srcroot") {
      sourceRoot = Path(rawSourceRoot)
    } else {
      sourceRoot = projectPath.parent()
    }
    
    guard let targets = try (parser.shiftValue(for: "target") ?? parser.shiftValue(for: "targets"))?
      .components(separatedBy: ",") else {
        throw ArgumentError.missingValue(argument: "targets")
    }
    
    let outputs = try (parser.shiftValue(for: "output") ?? parser.shiftValue(for: "outputs"))?
      .components(separatedBy: ",").map({ Path($0) })
    
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
    let projectPath = Path(rawProjectPath)
    guard projectPath.isDirectory else {
      throw ArgumentError.invalidType(value: rawProjectPath,
                                      type: String(describing: Path.self),
                                      argument: nil)
    }
    
    let sourceRoot: Path
    if let rawSourceRoot = try parser.shiftValue(for: "srcroot") {
      sourceRoot = Path(rawSourceRoot)
    } else {
      sourceRoot = projectPath.parent()
    }
    
    guard let targets = try (parser.shiftValue(for: "target") ?? parser.shiftValue(for: "targets"))?
      .components(separatedBy: ",") else {
        throw ArgumentError.missingValue(argument: "targets")
    }
    
    let config = MockingbirdCliInstaller.UninstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      targetNames: targets
    )
    try MockingbirdCliInstaller.uninstall(using: config)
  }
}.run()
