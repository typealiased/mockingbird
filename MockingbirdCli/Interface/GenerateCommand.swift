//
//  GenerateCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import SPMUtility

struct GenerateCommand: Command {
  let command = "generate"
  let overview = "Generate mocks for a set of targets in a project."
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let targetsArgument: OptionArgument<[String]>
  private let targetArgument: OptionArgument<[String]>
  private let sourceRootArgument: OptionArgument<PathArgument>
  private let outputsArgument: OptionArgument<[PathArgument]>
  private let outputArgument: OptionArgument<[PathArgument]>
  
  private let preprocessorExpressionArgument: OptionArgument<String>
  private let disableModuleImportArgument: OptionArgument<Bool>
  private let onlyMockProtocolsArgument: OptionArgument<Bool>
  private let disableSwiftlintArgument: OptionArgument<Bool>
  
  init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    
    projectPathArgument = subparser.addProjectPath()
    targetsArgument = subparser.addTargets()
    targetArgument = subparser.addTarget()
    sourceRootArgument = subparser.addSourceRoot()
    outputsArgument = subparser.addOutputs()
    outputArgument = subparser.addOutput()
    preprocessorExpressionArgument = subparser.addPreprocessorExpression()
    disableModuleImportArgument = subparser.addDisableModuleImport()
    onlyMockProtocolsArgument = subparser.addOnlyProtocols()
    disableSwiftlintArgument = subparser.addDisableSwiftlint()
  }
  
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment)
    let sourceRoot = try arguments.getSourceRoot(using: sourceRootArgument,
                                                 environment: environment,
                                                 projectPath: projectPath)
    let targets = try arguments.getTargets(using: targetsArgument,
                                           convenienceArgument: targetArgument,
                                           environment: environment)
    let outputs = try arguments.getOutputs(using: outputsArgument,
                                           convenienceArgument: outputArgument)
    
    let config = Generator.Configuration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      inputTargetNames: targets,
      outputPaths: outputs,
      preprocessorExpression: arguments.get(preprocessorExpressionArgument),
      shouldImportModule: arguments.get(disableModuleImportArgument) != true,
      onlyMockProtocols: arguments.get(onlyMockProtocolsArgument) == true,
      disableSwiftlint: arguments.get(disableSwiftlintArgument) == true
    )
    try Generator.generate(using: config)
  }
}
