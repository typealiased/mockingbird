//
//  InstallCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import PathKit
import SPMUtility

struct InstallCommand: Command {
  let command = "install"
  let overview = "Starts automatically generating mocks by adding a custom Run Script Phase to each target."
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let targetsArgument: OptionArgument<[String]>
  private let targetArgument: OptionArgument<String>
  private let sourceRootArgument: OptionArgument<PathArgument>
  private let outputsArgument: OptionArgument<[PathArgument]>
  private let outputArgument: OptionArgument<PathArgument>
  
  private let preprocessorExpressionArgument: OptionArgument<String>
  private let reinstallArgument: OptionArgument<Bool>
  private let synchronousGenerationArgument: OptionArgument<Bool>
  private let onlyMockProtocolsArgument: OptionArgument<Bool>
  
  init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    
    projectPathArgument = subparser.addProjectPath()
    targetsArgument = subparser.addTargets()
    targetArgument = subparser.addTarget()
    sourceRootArgument = subparser.addSourceRoot()
    outputsArgument = subparser.addOutputs()
    outputArgument = subparser.addOutput()
    preprocessorExpressionArgument = subparser.addPreprocessorExpression()
    reinstallArgument = subparser.addReinstallRunScript()
    synchronousGenerationArgument = subparser.addSynchronousGeneration()
    onlyMockProtocolsArgument = subparser.addOnlyProtocols()
  }
  
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment)
    let sourceRoot = try arguments.getSourceRoot(using: sourceRootArgument,
                                                 environment: environment,
                                                 projectPath: projectPath)
    let targets = try arguments.getTargets(using: targetsArgument,
                                           convenienceArgument: targetArgument)
    let outputs = try arguments.getOutputs(using: outputsArgument,
                                           convenienceArgument: outputArgument)
    
    let config = Installer.InstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      targetNames: targets,
      outputPaths: outputs,
      cliPath: Path(CommandLine.arguments[0]),
      shouldReinstall: arguments.get(reinstallArgument) == true,
      synchronousGeneration: arguments.get(synchronousGenerationArgument) == true,
      preprocessorExpression: arguments.get(preprocessorExpressionArgument)
    )
    try Installer.install(using: config)
    print("Installed Mockingbird to \(targets.map({ "`\($0)`" }).joined(separator: ", ")) in \(projectPath)")
  }
}
