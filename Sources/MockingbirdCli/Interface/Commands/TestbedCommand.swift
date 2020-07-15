//
//  TestbedCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 9/7/19.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility

final class TestbedCommand: BaseCommand {
  private enum Constants {
    static let name = "testbed"
    static let overview = "Generate source files for benchmarking Mockingbird."
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  private let outputArgument: OptionArgument<PathArgument>
  private let countArgument: OptionArgument<Int>
  
  required init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: Constants.name, overview: Constants.overview)
    self.outputArgument = subparser.addMetagenerateOutput()
    self.countArgument = subparser.addMetagenerateCount()
    super.init(parser: subparser)
  }
  
  override func run(with arguments: ArgumentParser.Result,
                    environment: [String: String],
                    workingPath: Path) throws {
    try super.run(with: arguments, environment: environment, workingPath: workingPath)
    
    let outputDirectory = try arguments.getOutputDirectory(using: outputArgument)
    let count = try arguments.getCount(using: countArgument) ?? 1000
    for i in 0..<count { try generateSourceFile(to: outputDirectory, index: i) }
    
    logInfo("Generated \(count) source file\(count > 1 ? "s" : "") to \(outputDirectory.absolute())")
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
