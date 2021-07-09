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

class ConfigureCommand: InstallCommand {
  private enum Constants {
    static let name = "configure"
    static let overview = "Configure a test target to use mocks (alias of 'install')."
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  required init(parser: ArgumentParser) {
    super.init(parser: parser, name: Constants.name, overview: Constants.overview)
  }
  
  required init(parser: ArgumentParser, name: String, overview: String) {
    super.init(parser: parser, name: name, overview: overview)
  }
}

class InstallCommand: BaseCommand, AliasableCommand {
  private enum Constants {
    static let name = "install"
    static let overview = "Configure a test target to use mocks."
    
    static let launcherEnvironmentKey = "MKB_LAUNCHER"
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let sourceTargetsArgument: OptionArgument<[String]>
  private let sourceTargetArgument: OptionArgument<[String]>
  private let destinationTargetArgument: OptionArgument<String>
  private let sourceRootArgument: OptionArgument<PathArgument>
  private let outputsArgument: OptionArgument<[PathArgument]>
  private let outputArgument: OptionArgument<[PathArgument]>
  private let supportPathArgument: OptionArgument<PathArgument>
  private let headerArgument: OptionArgument<[String]>
  private let compilationConditionArgument: OptionArgument<String>
  private let diagnosticsArgument: OptionArgument<[DiagnosticType]>
  private let logLevelArgument: OptionArgument<LogLevel>
  private let pruningMethod: OptionArgument<PruningMethod>
  
  private let ignoreExistingRunScriptArgument: OptionArgument<Bool>
  private let asynchronousGenerationArgument: OptionArgument<Bool>
  private let onlyMockProtocolsArgument: OptionArgument<Bool>
  private let disableSwiftlintArgument: OptionArgument<Bool>
  private let disableCacheArgument: OptionArgument<Bool>
  private let disableRelaxedLinking: OptionArgument<Bool>
  
  required convenience init(parser: ArgumentParser) {
    self.init(parser: parser, name: Constants.name, overview: Constants.overview)
  }
  
  required init(parser: ArgumentParser, name: String, overview: String) {
    let subparser = parser.add(subparser: name, overview: overview)
    
    self.projectPathArgument = subparser.addProjectPath()
    self.sourceTargetsArgument = subparser.addSourceTargets()
    self.sourceTargetArgument = subparser.addSourceTarget()
    self.destinationTargetArgument = subparser.addDestinationTarget()
    self.sourceRootArgument = subparser.addSourceRoot()
    self.outputsArgument = subparser.addOutputs()
    self.outputArgument = subparser.addOutput()
    self.supportPathArgument = subparser.addSupportPath()
    self.headerArgument = subparser.addHeader()
    self.compilationConditionArgument = subparser.addCompilationCondition()
    self.diagnosticsArgument = subparser.addDiagnostics()
    self.logLevelArgument = subparser.addInstallerLogLevel()
    self.pruningMethod = subparser.addPruningMethod()
    
    self.ignoreExistingRunScriptArgument = subparser.addIgnoreExistingRunScript()
    self.asynchronousGenerationArgument = subparser.addAynchronousGeneration()
    self.onlyMockProtocolsArgument = subparser.addOnlyProtocols()
    self.disableSwiftlintArgument = subparser.addDisableSwiftlint()
    self.disableCacheArgument = subparser.addDisableCache()
    self.disableRelaxedLinking = subparser.addDisableRelaxedLinking()
    
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
    let sourceTargets = try arguments.getSourceTargets(using: sourceTargetsArgument,
                                                       convenienceArgument: sourceTargetArgument)
    let destinationTarget = try arguments.getDestinationTarget(using: destinationTargetArgument)
    let outputs = arguments.getOutputs(using: outputsArgument, convenienceArgument: outputArgument)
    let supportPath = try arguments.getSupportPath(using: supportPathArgument,
                                                   sourceRoot: sourceRoot)
    
    let launcherPath = environment[Constants.launcherEnvironmentKey]
    let realBinaryPath = CommandLine.arguments[0]
    let cliPath = Path(launcherPath ?? realBinaryPath)
    
    let config = Installer.InstallConfiguration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      sourceTargetNames: sourceTargets,
      destinationTargetName: destinationTarget,
      outputPaths: outputs,
      supportPath: supportPath,
      cliPath: cliPath,
      header: arguments.get(headerArgument),
      compilationCondition: arguments.get(compilationConditionArgument),
      diagnostics: arguments.get(diagnosticsArgument),
      logLevel: arguments.get(logLevelArgument),
      pruningMethod: arguments.get(pruningMethod),
      ignoreExisting: arguments.get(ignoreExistingRunScriptArgument) == true,
      asynchronousGeneration: arguments.get(asynchronousGenerationArgument) == true,
      onlyMockProtocols: arguments.get(onlyMockProtocolsArgument) == true,
      disableSwiftlint: arguments.get(disableSwiftlintArgument) == true,
      disableCache: arguments.get(disableCacheArgument) == true,
      disableRelaxedLinking: arguments.get(disableRelaxedLinking) == true
    )
    try Installer.install(using: config)
    logInfo("Installed Mockingbird to \(destinationTarget.singleQuoted) in \(projectPath)")
    
    // Warn users that haven't added supporting source files.
    guard supportPath == nil else { return }
    logInfo("""
    Please add starter supporting source files for basic compatibility with system frameworks.
      $ mockingbird download starter-pack
    See https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files for more information.
    """)
  }
}
