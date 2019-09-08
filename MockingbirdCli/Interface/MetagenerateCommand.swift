//
//  MetagenerateCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 9/7/19.
//

import Foundation
import PathKit
import SPMUtility

struct MetagenerateCommand: Command {
  let command = "metagenerate"
  let overview = "Generates source files used for benchmarking."
  
  private let outputArgument: OptionArgument<PathArgument>
  private let countArgument: OptionArgument<Int>
  
  init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: command, overview: overview)
    outputArgument = subparser.addMetagenerateOutput()
    countArgument = subparser.addMetagenerateCount()
  }
  
  func run(with arguments: ArgumentParser.Result, environment: [String: String]) throws {
    let outputDirectory = try arguments.getOutputDirectory(using: outputArgument)
    let count = try arguments.getCount(using: countArgument) ?? 1000
    for i in 0..<count { try generateSourceFile(to: outputDirectory, index: i) }
    print("Generated \(count) source file\(count > 1 ? "s" : "") to \(outputDirectory.absolute())")
  }

  func generateSourceFile(to directory: Path, index: Int) throws {
    let contents = """
    import Foundation

    protocol GeneratedGrandparentProtocol\(index) {
      var grandparentReadOnlyInstanceVariable: Bool { get }
      var grandparentInstanceVariable: Bool { get set }
      func grandparentTrivialInstanceMethod()
      func grandparentParameterizedInstanceMethod(param1: Bool, _ param2: Int)
      func grandparentParameterizedReturningInstanceMethod(param1: Bool, _ param2: Int) -> String
    }

    protocol GeneratedParentProtocol\(index): GeneratedGrandparentProtocol\(index) {
      var parentReadOnlyInstanceVariable: Bool { get }
      var parentInstanceVariable: Bool { get set }
      func parentTrivialInstanceMethod()
      func parentParameterizedInstanceMethod(param1: Bool, _ param2: Int)
      func parentParameterizedReturningInstanceMethod(param1: Bool, _ param2: Int) -> String
    }

    protocol GeneratedChildProtocol\(index): GeneratedParentProtocol\(index) {
      var childReadOnlyInstanceVariable: Bool { get }
      var childInstanceVariable: Bool { get set }
      func childTrivialInstanceMethod()
      func childParameterizedInstanceMethod(param1: Bool, _ param2: Int)
      func childParameterizedReturningInstanceMethod(param1: Bool, _ param2: Int) -> String
    }
    
    """
    
    let filePath = directory + "GeneratedProtocols\(index).generated.swift"
    try filePath.write(contents, encoding: .utf8)
  }
}
