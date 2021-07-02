//
//  ArgumentParser+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility

extension ArgumentParser {
  // MARK: Options
  
  func addProjectPath() -> OptionArgument<PathArgument> {
    return add(option: "--project",
               kind: PathArgument.self,
               usage: "Path to an '.xcodeproj' file or a JSON project description.",
               completion: .filename)
  }
  
  func addSourceRoot() -> OptionArgument<PathArgument> {
    return add(option: "--srcroot",
               kind: PathArgument.self,
               usage: "The directory containing your project's source files.",
               completion: .filename)
  }
  
  func addTargets() -> OptionArgument<[String]> {
    return add(option: "--targets",
               kind: [String].self,
               usage: "List of target names to generate mocks for.")
  }
  
  /// Convenience for `--targets`. Accepts multiple targets.
  func addTarget() -> OptionArgument<[String]> {
    return add(option: "--target",
               kind: [String].self,
               usage: "A target name to generate mocks for.")
  }
  
  func addSourceTargets() -> OptionArgument<[String]> {
    return add(option: "--sources",
               kind: [String].self,
               usage: "List of target names to generate mocks for.")
  }
  
  /// Convenience for source `--targets`. Accepts multiple targets.
  func addSourceTarget() -> OptionArgument<[String]> {
    return add(option: "--source",
               kind: [String].self,
               usage: "A target name to generate mocks for.")
  }
  
  func addDestinationTarget() -> OptionArgument<String> {
    return add(option: "--target",
               kind: String.self,
               usage: "The name of a test target to configure.")
  }
  
  func addOutputs() -> OptionArgument<[PathArgument]> {
    return add(option: "--outputs",
               kind: [PathArgument].self,
               usage: "List of mock output file paths for each target.",
               completion: .filename)
  }
  
  /// Convenience for `--outputs`. Accepts multiple outputs.
  func addOutput() -> OptionArgument<[PathArgument]> {
    return add(option: "--output",
               kind: [PathArgument].self,
               usage: "Mock output file path.",
               completion: .filename)
  }
  
  /// For installation, only accepts a single output.
  func addInstallationOutput() -> OptionArgument<PathArgument> {
    return add(option: "--output",
               kind: PathArgument.self,
               usage: "Mock output file path.",
               completion: .filename)
  }
  
  func addSupportPath() -> OptionArgument<PathArgument> {
    return add(option: "--support",
               kind: PathArgument.self,
               usage: "The directory containing supporting source files.",
               completion: .filename)
  }
  
  func addTestBundle() -> OptionArgument<String> {
    return add(option: "--testbundle",
               kind: String.self,
               usage: "The name of the test bundle using the mocks.")
  }
  
  func addHeader() -> OptionArgument<[String]> {
    return add(option: "--header",
               kind: [String].self,
               usage: "Content to add at the beginning of each generated mock file.")
  }
  
  func addCompilationCondition() -> OptionArgument<String> {
    return add(option: "--condition",
               kind: String.self,
               usage: "Compilation condition to wrap all generated mocks in, e.g. 'DEBUG'.",
               completion: .values([
                (value: "DEBUG", description: "Debug build configuration"),
                (value: "RELEASE", description: "Release build configuration"),
                (value: "TEST", description: "Test build configuration")]))
  }
  
  func addInstallerLogLevel() -> OptionArgument<LogLevel> {
    return add(option: "--loglevel",
               kind: LogLevel.self,
               usage: "The log level to use when generating mocks.")
  }
  
  func addPruningMethod() -> OptionArgument<PruningMethod> {
    return add(option: "--prune",
               kind: PruningMethod.self,
               usage: "The pruning method to use on unreferenced types.")
  }
  
  func addMetagenerateOutput() -> OptionArgument<PathArgument> {
    return add(option: "--output",
               kind: PathArgument.self,
               usage: "Output directory to generate source files.",
               completion: .filename)
  }
  
  func addMetagenerateCount() -> OptionArgument<Int> {
    return add(option: "--count",
               kind: Int.self,
               usage: "Number of source files to generate.")
  }
  
  func addDiagnostics() -> OptionArgument<[DiagnosticType]> {
    return add(option: "--diagnostics",
               kind: [DiagnosticType].self,
               usage: "List of diagnostic generator warnings to enable.")
  }
    
  func addBaseUrl() -> OptionArgument<String> {
    return add(option: "--url",
               kind: String.self,
               usage: "The base URL containing downloadable asset bundles.")
  }
  
  // MARK: Global Options
  
  func addVerboseLogLevel() -> OptionArgument<Bool> {
    return add(option: "--verbose",
               kind: Bool.self,
               usage: "Log all errors, warnings, and debug messages.")
  }
  
  func addQuietLogLevel() -> OptionArgument<Bool> {
    return add(option: "--quiet",
               kind: Bool.self,
               usage: "Only log error messages.")
  }
  
  // MARK: Flags
  
  func addOnlyProtocols() -> OptionArgument<Bool> {
    return add(option: "--only-protocols",
               kind: Bool.self,
               usage: "Only generate mocks for protocols.")
  }
  
  func addDisableModuleImport() -> OptionArgument<Bool> {
    return add(option: "--disable-module-import",
               kind: Bool.self,
               usage: "Omit '@testable import <module>' from generated mocks.")
  }
  
  func addIgnoreExistingRunScript() -> OptionArgument<Bool> {
    return add(option: "--preserve-existing",
               kind: Bool.self,
               usage: "Don’t overwrite previously installed configurations.")
  }
  
  func addAynchronousGeneration() -> OptionArgument<Bool> {
    return add(option: "--asynchronous",
               kind: Bool.self,
               usage: "Generate mocks asynchronously in the background when building.")
  }
  
  func addDisableSwiftlint() -> OptionArgument<Bool> {
    return add(option: "--disable-swiftlint",
               kind: Bool.self,
               usage: "Disable all SwiftLint rules in generated mocks.")
  }
  
  func addDisableCache() -> OptionArgument<Bool> {
    return add(option: "--disable-cache",
               kind: Bool.self,
               usage: "Ignore cached mock information stored on disk.")
  }
  
  func addDisableRelaxedLinking() -> OptionArgument<Bool> {
    return add(option: "--disable-relaxed-linking",
               kind: Bool.self,
               usage: "Only search explicitly imported modules.")
  }

  // MARK: - Positional
  
  func addAssetBundleType() -> PositionalArgument<AssetBundleType> {
    return add(positional: "asset",
               kind: AssetBundleType.self,
               usage: "An asset bundle to download and unpack.",
               completion: AssetBundleType.completion)
  }
}

extension ArgumentParser.Result {
  func getProjectPath(using argument: OptionArgument<PathArgument>,
                      environment: [String: String],
                      workingPath: Path) throws -> Path {
    let projectPath: Path
    if let rawProjectPath = get(argument)?.path.pathString ?? environment["PROJECT_FILE_PATH"] {
      projectPath = Path(rawProjectPath)
    } else {
      let inferredXcodeProjects = try workingPath.containedXcodeProjects()
      if let firstProject = inferredXcodeProjects.first, inferredXcodeProjects.count == 1 {
        log("Using inferred Xcode project at \(firstProject.absolute())")
        projectPath = firstProject
      } else {
        if inferredXcodeProjects.count > 1 {
          logWarning("Unable to infer Xcode project because there are multiple '.xcodeproj' files in \(workingPath.absolute())")
        }
        throw ArgumentParserError.expectedValue(option: "--project <xcodeproj file path>")
      }
    }
    return projectPath
  }
  
  func getSourceRoot(using argument: OptionArgument<PathArgument>,
                     environment: [String: String],
                     projectPath: Path) -> Path {
    if let rawSourceRoot = get(argument)?.path.pathString ??
      environment["SRCROOT"] ?? environment["SOURCE_ROOT"] {
      return Path(rawSourceRoot)
    } else {
      return projectPath.parent()
    }
  }
  
  func getTargets(using argument: OptionArgument<[String]>,
                  convenienceArgument: OptionArgument<[String]>,
                  environment: [String: String]) throws -> [String] {
    if let targets = get(argument) ?? get(convenienceArgument) {
      return targets
    } else if let target = environment["TARGET_NAME"] {
      return [target]
    } else {
      throw ArgumentParserError.expectedValue(option: "--targets <list of target names>")
    }
  }
  
  func getOutputs(using argument: OptionArgument<[PathArgument]>,
                  convenienceArgument: OptionArgument<[PathArgument]>) -> [Path]? {
    if let rawOutputs = (get(argument) ?? get(convenienceArgument))?.map({ $0.path.pathString }) {
      return rawOutputs.map({ Path($0) })
    }
    return nil
  }
  
  func getSupportPath(using argument: OptionArgument<PathArgument>,
                      sourceRoot: Path) throws -> Path? {
    guard let rawSupportPath = get(argument)?.path.pathString else {
      let defaultSupportPath = sourceRoot + "MockingbirdSupport"
      guard defaultSupportPath.isDirectory else {
        logWarning("Unable to infer support path because no directory exists at \(defaultSupportPath)")
        return nil
      }
      log("Using inferred support path at \(defaultSupportPath)")
      return defaultSupportPath
    }
    let supportPath = Path(rawSupportPath)
    guard supportPath.isDirectory else {
      throw ArgumentParserError.invalidValue(argument: "--support \(supportPath.absolute())",
                                             error: .custom("Not a valid directory"))
    }
    return supportPath
  }
  
  func getSourceTargets(using argument: OptionArgument<[String]>,
                        convenienceArgument: OptionArgument<[String]>) throws -> [String] {
    if let targets = get(argument) ?? get(convenienceArgument) {
      return targets
    } else {
      throw ArgumentParserError.expectedValue(option: "--sources <list of target names>")
    }
  }
  
  func getDestinationTarget(using argument: OptionArgument<String>) throws -> String {
    if let target = get(argument) {
      return target
    } else {
      throw ArgumentParserError.expectedValue(option: "--target <target name>")
    }
  }
  
  func getOutputDirectory(using argument: OptionArgument<PathArgument>) throws -> Path {
    if let rawOutput = get(argument)?.path.pathString {
      let path = Path(rawOutput)
      guard path.isDirectory else {
        throw ArgumentParserError.invalidValue(argument: "--output \(path.absolute())",
                                               error: .custom("Not a valid directory"))
      }
      return path
    }
    throw ArgumentParserError.expectedValue(option: "--output <list of output file paths>")
  }
  
  func getCount(using argument: OptionArgument<Int>) throws -> Int? {
    if let count = get(argument) {
      guard count > 0 else {
        throw ArgumentParserError.invalidValue(argument: "--count \(count)",
                                               error: .custom("Not a positive number"))
      }
      return count
    }
    return nil
  }
  
  func getLogLevel(verboseOption: OptionArgument<Bool>,
                   quietOption: OptionArgument<Bool>) throws -> LogLevel {
    let isVerbose = get(verboseOption) == true
    let isQuiet = get(quietOption) == true
    guard !isVerbose || !isQuiet else {
      let error = ArgumentConversionError.custom("Cannot specify both --verbose and --quiet")
      throw ArgumentParserError.invalidValue(argument: "--verbose --quiet",
                                             error: error)
    }
    if isVerbose {
      return .verbose
    } else if isQuiet {
      return .quiet
    } else {
      return .normal
    }
  }
}

extension LogLevel: ArgumentKind, CustomStringConvertible {
  public init(argument: String) throws {
    guard LogLevel(rawValue: argument) != nil else {
      let allOptions = LogLevel.allCases.map({ $0.rawValue }).joined(separator: ", ")
      throw ArgumentParserError.invalidValue(
        argument: "--loglevel \(argument)",
        error: .custom("Not a valid log level, expected: \(allOptions)")
      )
    }
    self.init(rawValue: argument)!
  }
  
  public static var completion: ShellCompletion {
    return .values(LogLevel.allCases.map({
      (value: $0.rawValue, description: "\($0)")
    }))
  }
  
  public var description: String {
    switch self {
    case .quiet:
      return "Only log error messages."
    case .normal:
      return "Log errors and warnings."
    case .verbose:
      return "Log all errors, warnings, and debug messages."
    }
  }
}

extension DiagnosticType: ArgumentKind, CustomStringConvertible {
  public init(argument: String) throws {
    guard DiagnosticType(rawValue: argument) != nil else {
      let allOptions = DiagnosticType.allCases.map({ $0.rawValue }).joined(separator: ", ")
      throw ArgumentParserError.invalidValue(
        argument: "--diagnostics \(argument)",
        error: .custom("Not a valid diagnostic type, expected: \(allOptions)")
      )
    }
    self.init(rawValue: argument)!
  }
  
  public static var completion: ShellCompletion {
    return .values(DiagnosticType.allCases.map({
      (value: $0.rawValue, description: "\($0)")
    }))
  }
  
  public var description: String {
    switch self {
    case .all:
      return "Emit all diagnostic warnings."
    case .notMockable:
      return "Warn when skipping declarations that cannot be mocked."
    case .undefinedType:
      return "Warn on external types not defined in a supporting source file."
    case .typeInference:
      return "Warn when skipping complex property assignments in class mocks."
    }
  }
}

extension PruningMethod: ArgumentKind, CustomStringConvertible {
  public init(argument: String) throws {
    guard PruningMethod(rawValue: argument) != nil else {
      let allOptions = PruningMethod.allCases.map({ $0.rawValue }).joined(separator: ", ")
      throw ArgumentParserError.invalidValue(
        argument: "--prune \(argument)",
        error: .custom("Not a valid pruning method, expected: \(allOptions)")
      )
    }
    self.init(rawValue: argument)!
  }
  
  public static var completion: ShellCompletion {
    return .values(PruningMethod.allCases.map({
      (value: $0.rawValue, description: "\($0)")
    }))
  }
  
  public var description: String {
    switch self {
    case .disable:
      return "Always generate full thunks regardless of usage in tests."
    case .stub:
      return "Generate partial definitions filled with 'fatalError'."
    case .omit:
      return "Don’t generate any definitions for unused types."
    }
  }
}

private extension Path {
  func containedXcodeProjects() throws -> [Path] {
    return try children().filter({ $0.isDirectory && $0.extension == "xcodeproj" })
  }
}
