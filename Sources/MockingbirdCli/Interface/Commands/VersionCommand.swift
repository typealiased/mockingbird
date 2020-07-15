//
//  VersionCommand.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation
import MockingbirdGenerator
import PathKit
import SPMUtility

final class VersionCommand: BaseCommand {
  private enum Constants {
    static let name = "version"
    static let overview = "Returns the current CLI generator version."
  }
  override var name: String { return Constants.name }
  override var overview: String { return Constants.overview }
  
  required init(parser: ArgumentParser) {
    let subparser = parser.add(subparser: Constants.name, overview: Constants.overview)
    super.init(parser: subparser)
  }
  
  override func run(with arguments: ArgumentParser.Result,
                    environment: [String: String],
                    workingPath: Path) throws {
    try super.run(with: arguments, environment: environment, workingPath: workingPath)
    logInfo("\(mockingbirdVersion)")
  }
}
