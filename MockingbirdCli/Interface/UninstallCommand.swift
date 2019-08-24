//
//  UninstallCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import PathKit
import SPMUtility

struct UninstallCommand: Command {
  let command = "uninstall"
  let overview = "Stops automatically generating mocks."
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let targetsArgument: OptionArgument<[String]>
  private let targetArgument: OptionArgument<String>
  private let sourceRootArgument: OptionArgument<PathArgument>
  
  init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    
    projectPathArgument = subparser.addProjectPath()
    targetsArgument = subparser.addTargets()
    targetArgument = subparser.addTarget()
    sourceRootArgument = subparser.addSourceRoot()
  }
  
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment)
    let sourceRoot = try arguments.getSourceRoot(using: sourceRootArgument,
                                                 environment: environment,
                                                 projectPath: projectPath)
    let targets = try arguments.getTargets(using: targetsArgument,
                                           convenienceArgument: targetArgument)
    
    let config = Installer.UninstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      targetNames: targets
    )
    try Installer.uninstall(using: config)
    print("Uninstalled Mockingbird from \(targets.map({ "`\($0)`" }).joined(separator: ", ")) in \(projectPath)")
  }
}
