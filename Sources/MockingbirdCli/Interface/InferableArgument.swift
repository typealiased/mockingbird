//
//  InferableArgument.swift
//  MockingbirdCli
//
//  Created by typealias on 8/7/21.
//

import Foundation
import PathKit

struct ArgumentContext: Codable {
  let workingPath: Path
  let environment: [String: String]
  let arguments: [String]
  
  static var shared = ArgumentContext(
    workingPath: Path(FileManager.default.currentDirectoryPath),
    environment: ProcessInfo.processInfo.environment,
    arguments: CommandLine.arguments
  )
}

protocol InferableArgument {
  init?(context: ArgumentContext) throws
}

func inferArgument<T: InferableArgument>(_ argument: inout T?,
                                         in context: ArgumentContext = .shared) throws -> T? {
  guard argument == nil else {
    return argument
  }
  argument = try T(context: context)
  return argument
}
