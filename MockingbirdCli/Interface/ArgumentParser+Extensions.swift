//
//  ArgumentParser+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Foundation
import PathKit
import SPMUtility

extension ArgumentParser {
  // MARK: Options
  
  func addProjectPath() -> OptionArgument<PathArgument> {
    return add(option: "--project",
               kind: PathArgument.self,
               usage: "Path to your project’s `.xcodeproj` file.",
               completion: .filename)
  }
  
  func addSourceRoot() -> OptionArgument<PathArgument> {
    return add(option: "--srcroot",
               kind: PathArgument.self,
               usage: "The folder containing your project's source files.",
               completion: .filename)
  }
  
  func addTargets() -> OptionArgument<[String]> {
    return add(option: "--targets",
               kind: [String].self,
               usage: "List of target names to generate mocks for.",
               completion: .filename)
  }
  
  func addTarget() -> OptionArgument<String> {
    return add(option: "--target",
               kind: String.self,
               usage: "(Convenience) A target name to generate mocks for.",
               completion: .filename)
  }
  
  func addOutputs() -> OptionArgument<[PathArgument]> {
    return add(option: "--outputs",
               kind: [PathArgument].self,
               usage: "List of mock output file paths for each target.",
               completion: .filename)
  }
  
  func addOutput() -> OptionArgument<PathArgument> {
    return add(option: "--output",
               kind: PathArgument.self,
               usage: "(Convenience) Mock output file path.",
               completion: .filename)
  }
  
  func addPreprocessorExpression() -> OptionArgument<String> {
    return add(option: "--preprocessor",
               kind: String.self,
               usage: "Preprocessor expression to wrap all generated mocks in, e.g. `DEBUG`.",
               completion: .values([
                (value: "DEBUG", description: "Debug build configuration"),
                (value: "RELEASE", description: "Release build configuration"),
                (value: "TEST", description: "Test build configuration")]))
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
               usage: "Omit `@testable import <module>` from generated mocks.")
  }
  
  func addReinstallRunScript() -> OptionArgument<Bool> {
    return add(option: "--reinstall",
               kind: Bool.self,
               usage: "Overwrite existing Run Script Phases created by Mockingbird CLI.")
  }
  
  func addSynchronousGeneration() -> OptionArgument<Bool> {
    return add(option: "--synchronous",
               kind: Bool.self,
               usage: "Wait until mock generation completes before compiling target sources.")
  }
}

extension ArgumentParser.Result {
  func getProjectPath(using argument: OptionArgument<PathArgument>,
                      environment: [String: String]) throws -> Path {
    let projectPath: Path
    if let rawProjectPath = get(argument)?.path.pathString ?? environment["PROJECT_FILE_PATH"] {
      projectPath = Path(rawProjectPath)
    } else {
      throw ArgumentParserError.expectedValue(option: "--project")
    }
    guard projectPath.isDirectory, projectPath.extension == "xcodeproj" else {
      throw ArgumentParserError.invalidValue(argument: "--project",
                                             error: .custom("Not a valid `.xcodeproj` path"))
    }
    return projectPath
  }
  
  func getSourceRoot(using argument: OptionArgument<PathArgument>,
                     environment: [String: String],
                     projectPath: Path) throws -> Path {
    if let rawSourceRoot = get(argument)?.path.pathString ?? environment["SRCROOT"] {
      return Path(rawSourceRoot)
    } else {
      return projectPath.parent()
    }
  }
  
  func getTargets(using argument: OptionArgument<[String]>,
                  convenienceArgument: OptionArgument<String>,
                  environment: [String: String]) throws -> [String] {
    if let targets = get(argument) {
      return targets
    } else if let target = get(convenienceArgument) ?? environment["TARGET_NAME"] {
      return [target]
    } else {
      throw ArgumentParserError.expectedValue(option: "--targets")
    }
  }
  
  func getOutputs(using argument: OptionArgument<[PathArgument]>,
                  convenienceArgument: OptionArgument<PathArgument>) throws -> [Path]? {
    if let rawOutputs = get(argument)?.map({ $0.path.pathString }) {
      return rawOutputs.map({ Path($0) })
    } else if let rawOutput = get(convenienceArgument)?.path.pathString {
      return [Path(rawOutput)]
    }
    return nil
  }
}
