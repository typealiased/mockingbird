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
  let overview = "Set up a destination (unit test) target."
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let sourceTargetsArgument: OptionArgument<[String]>
  private let sourceTargetArgument: OptionArgument<[String]>
  private let destinationTargetArgument: OptionArgument<String>
  private let sourceRootArgument: OptionArgument<PathArgument>
  private let outputsArgument: OptionArgument<[PathArgument]>
  private let outputArgument: OptionArgument<[PathArgument]>
  
  private let preprocessorExpressionArgument: OptionArgument<String>
  private let ignoreExistingRunScriptArgument: OptionArgument<Bool>
  private let asynchronousGenerationArgument: OptionArgument<Bool>
  private let onlyMockProtocolsArgument: OptionArgument<Bool>
  private let disableSwiftlintArgument: OptionArgument<Bool>
  
  init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    
    projectPathArgument = subparser.addProjectPath()
    sourceTargetsArgument = subparser.addSourceTargets()
    sourceTargetArgument = subparser.addSourceTarget()
    destinationTargetArgument = subparser.addDestinationTarget()
    sourceRootArgument = subparser.addSourceRoot()
    outputsArgument = subparser.addOutputs()
    outputArgument = subparser.addOutput()
    preprocessorExpressionArgument = subparser.addPreprocessorExpression()
    ignoreExistingRunScriptArgument = subparser.addIgnoreExistingRunScript()
    asynchronousGenerationArgument = subparser.addAynchronousGeneration()
    onlyMockProtocolsArgument = subparser.addOnlyProtocols()
    disableSwiftlintArgument = subparser.addDisableSwiftlint()
  }
  
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment)
    let sourceRoot = try arguments.getSourceRoot(using: sourceRootArgument,
                                                 environment: environment,
                                                 projectPath: projectPath)
    let sourceTargets = try arguments.getSourceTargets(using: sourceTargetsArgument,
                                                       convenienceArgument: sourceTargetArgument)
    let destinationTarget = try arguments.getDestinationTarget(using: destinationTargetArgument)
    let outputs = try arguments.getOutputs(using: outputsArgument,
                                           convenienceArgument: outputArgument)
    
    let config = Installer.InstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      sourceTargetNames: sourceTargets,
      destinationTargetName: destinationTarget,
      outputPaths: outputs,
      cliPath: Path(CommandLine.arguments[0]),
      ignoreExisting: arguments.get(ignoreExistingRunScriptArgument) == true,
      asynchronousGeneration: arguments.get(asynchronousGenerationArgument) == true,
      preprocessorExpression: arguments.get(preprocessorExpressionArgument),
      onlyMockProtocols: arguments.get(onlyMockProtocolsArgument) == true,
      disableSwiftlint: arguments.get(disableSwiftlintArgument) == true
    )
    try Installer.install(using: config)
    print("Installed Mockingbird to `\(destinationTarget)` in \(projectPath)")
  }
}
