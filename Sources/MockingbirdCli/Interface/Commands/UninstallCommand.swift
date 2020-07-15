//
//  UninstallCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility

final class UninstallCommand: BaseCommand {
  private enum Constants {
    static let name = "uninstall"
    static let overview = "Remove Mockingbird from a test target."
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let targetsArgument: OptionArgument<[String]>
  private let targetArgument: OptionArgument<[String]>
  private let sourceRootArgument: OptionArgument<PathArgument>
  
  required init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: Constants.name, overview: Constants.overview)
    
    self.projectPathArgument = subparser.addProjectPath()
    self.targetsArgument = subparser.addTargets()
    self.targetArgument = subparser.addTarget()
    self.sourceRootArgument = subparser.addSourceRoot()
    
    super.init(parser: subparser)
  }
  
  override func run(with arguments: ArgumentParser.Result,
                    environment: [String: String],
                    workingPath: Path) throws {
    try super.run(with: arguments, environment: environment, workingPath: workingPath)
    
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment,
                                                   workingPath: workingPath)
    let sourceRoot = arguments.getSourceRoot(using: sourceRootArgument,
                                             environment: environment,
                                             projectPath: projectPath)
    let targets = try arguments.getTargets(using: targetsArgument,
                                           convenienceArgument: targetArgument,
                                           environment: environment)
    
    let config = Installer.UninstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      targetNames: targets
    )
    try Installer.uninstall(using: config)
    logInfo("Uninstalled Mockingbird from \(targets.map({ "`\($0)`" }).joined(separator: ", ")) in \(projectPath)")
  }
}
