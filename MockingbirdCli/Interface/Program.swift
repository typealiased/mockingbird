//
//  Program.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Basic
import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility
import os.log

protocol Command {
  var name: String { get }
  var overview: String { get }
  var subparser: ArgumentParser { get }
  init(parser: ArgumentParser)
  func run(with arguments: ArgumentParser.Result,
           environment: [String: String],
           workingPath: Path) throws
}

protocol AliasableCommand: BaseCommand {
  init(parser subparser: ArgumentParser, name: String, overview: String)
}

class BaseCommand: Command {
  var name: String { fatalError() }
  var overview: String { fatalError() }
  let subparser: ArgumentParser
  
  let verboseOption: OptionArgument<Bool>
  let quietOption: OptionArgument<Bool>
  
  required init(parser subparser: ArgumentParser) {
    self.subparser = subparser
    self.verboseOption = subparser.addVerboseLogLevel()
    self.quietOption = subparser.addQuietLogLevel()
  }
  
  func run(with arguments: ArgumentParser.Result,
           environment: [String: String],
           workingPath: Path) throws {
    let logLevel = try arguments.getLogLevel(verboseOption: verboseOption, quietOption: quietOption)
    LogLevel.default.value = logLevel
  }
}

/// Represents a CLI that can parse arguments and run the appropriate `Command`.
struct Program {
  private let parser: ArgumentParser
  private let commands: [Command]
  private let environment: [String: String]
  private let fileManager: FileManager
  
  init(usage: String,
       overview: String,
       commands: [Command.Type],
       environment: [String: String] = ProcessInfo.processInfo.environment,
       fileManager: FileManager = FileManager.default) {
    let parser = ArgumentParser(usage: usage, overview: overview)
    self.parser = parser
    self.commands = commands.map({ $0.init(parser: parser) })
    self.environment = environment
    self.fileManager = fileManager
  }
  
  func run(with arguments: [String]) -> Int32 {
    var exitStatus: Int32 = 0
    time(.runProgram) {
      do {
        var parsedArguments: ArgumentParser.Result!
        try time(.parseArguments) {
          let arguments = Array(arguments.dropFirst())
          parsedArguments = try parser.parse(arguments)
        }
        try process(arguments: parsedArguments)
      }
      catch let error {
        log(error)
        exitStatus = 1
      }
    }
    return exitStatus
  }
  
  private func process(arguments: ArgumentParser.Result) throws {
    guard let subparser = arguments.subparser(parser),
      let command = commands.last(where: { $0.name == subparser }) else {
        parser.printUsage(on: stdoutStream)
        return
    }
    try command.run(with: arguments,
                    environment: environment,
                    workingPath: Path(fileManager.currentDirectoryPath))

  }
}

func exit(_ exitStatus: Int32) -> Never {
  flushLogs()
  Darwin.exit(exitStatus)
}
