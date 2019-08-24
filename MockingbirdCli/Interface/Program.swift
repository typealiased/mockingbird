//
//  Program.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/23/19.
//

import Basic
import Foundation
import SPMUtility

protocol Command {
  var command: String { get }
  var overview: String { get }
  init(parser: ArgumentParser)
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws
}

class Program {
  private let parser: ArgumentParser
  private var commands = [Command]()
  
  init(usage: String, overview: String, commands: [Command.Type]? = nil) {
    parser = ArgumentParser(usage: usage, overview: overview)
    commands?.forEach({ self.commands.append($0.init(parser: parser)) })
  }
  
  func add(command: Command.Type) {
    commands.append(command.init(parser: parser))
  }
  
  func run(with arguments: [String]) {
    do {
      let arguments = Array(arguments.dropFirst())
      let parsedArguments = try parser.parse(arguments)
      try process(arguments: parsedArguments)
    }
    catch let error as ArgumentParserError {
      print(error.description)
    }
    catch let error {
      print(error.localizedDescription)
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
