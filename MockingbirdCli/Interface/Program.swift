//
//  Program.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Basic
import Foundation
import MockingbirdGenerator
import SPMUtility
import os.log

protocol Command {
  var command: String { get }
  var overview: String { get }
  init(parser: ArgumentParser)
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws
}

/// Represents a CLI that can parse arguments and run the appropriate `Command`.
struct Program {
  private let parser: ArgumentParser
  private let commands: [Command]
  
  init(usage: String, overview: String, commands: [Command.Type]) {
    let parser = ArgumentParser(usage: usage, overview: overview)
    self.parser = parser
    self.commands = commands.map({ $0.init(parser: parser) })
  }
  
  func run(with arguments: [String]) {
    time(.runProgram) {
      do {
        var parsedArguments: ArgumentParser.Result!
        try time(.parseArguments) {
          let arguments = Array(arguments.dropFirst())
          parsedArguments = try parser.parse(arguments)
        }
        try process(arguments: parsedArguments)
      }
      catch let error as ArgumentParserError {
        print(error.description)
      }
      catch let error {
        print(error.localizedDescription)
      }
    }
  }
  
  private func process(arguments: ArgumentParser.Result) throws {
    guard let subparser = arguments.subparser(parser),
      let command = commands.last(where: { $0.command == subparser }) else {
        parser.printUsage(on: stdoutStream)
        return
    }
    try command.run(with: arguments, environment: ProcessInfo.processInfo.environment)
  }
}
