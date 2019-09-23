//
//  InstallCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility

final class InstallCommand: BaseCommand {
  private enum Constants {
    static let name = "install"
    static let overview = "Set up a destination (unit test) target."
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  private let walkthroughOption: OptionArgument<Bool>
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
  
  required init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: Constants.name, overview: Constants.overview)
    
    self.walkthroughOption = subparser.addWalkthrough()
    self.projectPathArgument = subparser.addProjectPath()
    self.sourceTargetsArgument = subparser.addSourceTargets()
    self.sourceTargetArgument = subparser.addSourceTarget()
    self.destinationTargetArgument = subparser.addDestinationTarget()
    self.sourceRootArgument = subparser.addSourceRoot()
    self.outputsArgument = subparser.addOutputs()
    self.outputArgument = subparser.addOutput()
    self.preprocessorExpressionArgument = subparser.addPreprocessorExpression()
    self.ignoreExistingRunScriptArgument = subparser.addIgnoreExistingRunScript()
    self.asynchronousGenerationArgument = subparser.addAynchronousGeneration()
    self.onlyMockProtocolsArgument = subparser.addOnlyProtocols()
    self.disableSwiftlintArgument = subparser.addDisableSwiftlint()
    super.init(parser: subparser)
  }
  
  override func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    try super.run(with: arguments, environment: environment)
    
    var projectPath: Path
    var sourceTargets: [String]
    var destinationTarget: String
    
    if arguments.hasWalkthroughOption(using: walkthroughOption) {
        let result = try arguments.getWalkthroughResult(environment: environment)
        projectPath = result.project
        sourceTargets = result.sources
        destinationTarget = result.destination
        
    } else {
        projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment)
        sourceTargets = try arguments.getSourceTargets(using: sourceTargetsArgument,
                                                       convenienceArgument: sourceTargetArgument)
        destinationTarget = try arguments.getDestinationTarget(using: destinationTargetArgument)
    }
    
    let sourceRoot = try arguments.getSourceRoot(using: sourceRootArgument,
                                                 environment: environment,
                                                 projectPath: projectPath)
    
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
