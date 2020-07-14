//
//  GenerateCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility

final class GenerateCommand: BaseCommand {
  private enum Constants {
    static var name = "generate"
    static var overview = "Generate mocks for a set of targets in a project."
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  private let projectPathArgument: OptionArgument<PathArgument>
  private let targetsArgument: OptionArgument<[String]>
  private let targetArgument: OptionArgument<[String]>
  private let sourceRootArgument: OptionArgument<PathArgument>
  private let outputsArgument: OptionArgument<[PathArgument]>
  private let outputArgument: OptionArgument<[PathArgument]>
  private let supportPathArgument: OptionArgument<PathArgument>
  private let diagnosticsArgument: OptionArgument<[DiagnosticType]>
  
  private let compilationConditionArgument: OptionArgument<String>
  private let disableModuleImportArgument: OptionArgument<Bool>
  private let onlyMockProtocolsArgument: OptionArgument<Bool>
  private let disableSwiftlintArgument: OptionArgument<Bool>
  private let disableCacheArgument: OptionArgument<Bool>
  private let disableRelaxedLinking: OptionArgument<Bool>
  private let disableThunkStubs: OptionArgument<Bool>
  
  required init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: Constants.name, overview: Constants.overview)
    
    self.projectPathArgument = subparser.addProjectPath()
    self.targetsArgument = subparser.addTargets()
    self.targetArgument = subparser.addTarget()
    self.sourceRootArgument = subparser.addSourceRoot()
    self.outputsArgument = subparser.addOutputs()
    self.outputArgument = subparser.addOutput()
    self.supportPathArgument = subparser.addSupportPath()
    self.diagnosticsArgument = subparser.addDiagnostics()
    
    self.compilationConditionArgument = subparser.addCompilationCondition()
    self.disableModuleImportArgument = subparser.addDisableModuleImport()
    self.onlyMockProtocolsArgument = subparser.addOnlyProtocols()
    self.disableSwiftlintArgument = subparser.addDisableSwiftlint()
    self.disableCacheArgument = subparser.addDisableCache()
    self.disableRelaxedLinking = subparser.addDisableRelaxedLinking()
    self.disableThunkStubs = subparser.addDisableThunkStubs()
    
    super.init(parser: subparser)
  }
  
  override func run(with arguments: ArgumentParser.Result,
                    environment: [String: String],
                    workingPath: Path) throws {
    try super.run(with: arguments, environment: environment, workingPath: workingPath)
    DiagnosticType.enabled.value = Set(arguments.get(diagnosticsArgument) ?? [])
    
    let projectPath = try arguments.getProjectPath(using: projectPathArgument,
                                                   environment: environment,
                                                   workingPath: workingPath)
    let sourceRoot = arguments.getSourceRoot(using: sourceRootArgument,
                                             environment: environment,
                                             projectPath: projectPath)
    let targets = try arguments.getTargets(using: targetsArgument,
                                           convenienceArgument: targetArgument,
                                           environment: environment)
    let outputs = arguments.getOutputs(using: outputsArgument,
                                       convenienceArgument: outputArgument)
    let supportPath = try arguments.getSupportPath(using: supportPathArgument,
                                                   sourceRoot: sourceRoot)
    
    var environmentProjectFilePath: Path? {
      guard let filePath = environment["PROJECT_FILE_PATH"] else { return nil }
      let path = Path(filePath)
      guard path.extension == "xcodeproj" else { return nil }
      return path
    }
    var environmentSourceRoot: Path? {
      guard let sourceRoot = environment["SRCROOT"] ?? environment["SOURCE_ROOT"] else {
        return nil
      }
      let path = Path(sourceRoot)
      return path
    }
    let environmentTargetName = environment["TARGET_NAME"] ?? environment["TARGETNAME"]
    
    let config = Generator.Configuration(
      projectPath: projectPath,
      sourceRoot: sourceRoot,
      inputTargetNames: targets,
      environmentProjectFilePath: environmentProjectFilePath,
      environmentSourceRoot: environmentSourceRoot,
      environmentTargetName: environmentTargetName,
      outputPaths: outputs,
      supportPath: supportPath,
      compilationCondition: arguments.get(compilationConditionArgument),
      shouldImportModule: arguments.get(disableModuleImportArgument) != true,
      onlyMockProtocols: arguments.get(onlyMockProtocolsArgument) == true,
      disableSwiftlint: arguments.get(disableSwiftlintArgument) == true,
      disableCache: arguments.get(disableCacheArgument) == true,
      disableRelaxedLinking: arguments.get(disableRelaxedLinking) == true,
      disableThunkStubs: arguments.get(disableThunkStubs) == true
    )
    try Generator(config).generate()
  }
}
